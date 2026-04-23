import Foundation

enum HistoricalDataError: LocalizedError {
    case missingBundledFile
    case invalidResponse
    case emptySeries(String)

    var errorDescription: String? {
        switch self {
        case .missingBundledFile:
            return L10n.errorBundledFileMissing
        case .invalidResponse:
            return L10n.errorInvalidResponse
        case .emptySeries(let symbol):
            return L10n.errorEmptySeries(for: symbol)
        }
    }
}

struct HistoricalDataStore {
    private let fileName: String
    private let fileExtension: String
    private let fileManager: FileManager
    private let bundle: Bundle
    private let bundledPayloadURL: URL?
    private let cacheFileURL: URL?
    private let legacyCacheFileURL: URL?
    private let now: @Sendable () -> Date
    private let historyFetcher: @Sendable (AssetID) async throws -> AssetHistory

    init(
        fileName: String = "bundled_historical_data",
        fileExtension: String = "json",
        fileManager: FileManager = .default,
        bundle: Bundle = .main,
        bundledPayloadURL: URL? = nil,
        cacheFileURL: URL? = nil,
        legacyCacheFileURL: URL? = nil,
        now: @escaping @Sendable () -> Date = { .now },
        historyFetcher: @escaping @Sendable (AssetID) async throws -> AssetHistory = HistoricalDataStore.fetchHistoryFromNetwork
    ) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.fileManager = fileManager
        self.bundle = bundle
        self.bundledPayloadURL = bundledPayloadURL
        self.cacheFileURL = cacheFileURL
        self.legacyCacheFileURL = legacyCacheFileURL
        self.now = now
        self.historyFetcher = historyFetcher
    }

    @MainActor
    func loadHistoricalData() async throws -> BundledHistoricalData {
        let cacheURLs = try cacheURLs()
        let bundledURL = try resolveBundledPayloadURL()

        return try await Task.detached(priority: .userInitiated) {
            for cacheURL in cacheURLs {
                do {
                    if let cached = try Self.loadCachedPayload(at: cacheURL) {
                        return cached
                    }
                } catch {
                    try? Self.clearCache(at: cacheURL)
                }
            }

            return try Self.loadPayload(from: bundledURL)
        }.value
    }

    @MainActor
    func refreshAllData() async throws -> BundledHistoricalData {
        let historyFetcher = self.historyFetcher

        let histories = try await withThrowingTaskGroup(of: AssetHistory.self) { group in
            for asset in AssetID.allCases {
                group.addTask {
                    try await historyFetcher(asset)
                }
            }

            var collected: [AssetHistory] = []
            for try await history in group {
                collected.append(history)
            }
            return collected.sorted { $0.symbol < $1.symbol }
        }

        let payload = BundledHistoricalData(
            generatedAt: now(),
            provider: "Yahoo Finance chart endpoint (monthly OHLC + recent OHLC + derived semiannual/annual OHLC)",
            interval: "1mo+1wk+6mo+1y",
            histories: histories
        )
        try await Self.persist(payload, to: currentCacheURL())
        return payload
    }

    private func resolveBundledPayloadURL() throws -> URL {
        if let bundledPayloadURL {
            return bundledPayloadURL
        }

        let candidates = [
            bundle.url(forResource: fileName, withExtension: fileExtension),
            bundle.url(forResource: fileName, withExtension: fileExtension, subdirectory: "Resources/Historical")
        ]

        guard let url = candidates.compactMap({ $0 }).first else {
            throw HistoricalDataError.missingBundledFile
        }

        return url
    }

    private static func loadPayload(from url: URL) throws -> BundledHistoricalData {
        let data = try Data(contentsOf: url)
        return try decodePayload(from: data)
    }

    private static func loadCachedPayload(at url: URL) throws -> BundledHistoricalData? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try loadPayload(from: url)
    }

    private static func decodePayload(from data: Data) throws -> BundledHistoricalData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BundledHistoricalData.self, from: data)
    }

    private static func persist(_ payload: BundledHistoricalData, to url: URL) async throws {
        try await Task.detached(priority: .utility) {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(payload)
            let fileManager = FileManager.default
            try fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: [.atomic])
        }.value
    }

    private static func clearCache(at url: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    private func currentCacheURL() throws -> URL {
        if let cacheFileURL {
            return cacheFileURL
        }

        return try Self.currentCacheURL(fileManager: fileManager)
    }

    private func cacheURLs() throws -> [URL] {
        if let cacheFileURL {
            if let legacyCacheFileURL {
                return [cacheFileURL, legacyCacheFileURL]
            }
            return [cacheFileURL]
        }

        return try Self.defaultCacheURLs(fileManager: fileManager)
    }

    private static func fetchHistoryFromNetwork(for asset: AssetID) async throws -> AssetHistory {
        let startDate = Calendar.utc.date(from: DateComponents(year: 2010, month: 1, day: 1)) ?? .distantPast
        let recentStartDate = Calendar.utc.date(byAdding: .year, value: -1, to: Date()) ?? startDate
        let period1 = Int(startDate.timeIntervalSince1970)
        let period2 = Int(Date().addingTimeInterval(86_400).timeIntervalSince1970)

        let monthlyBars = try await fetchMarketBars(
            for: asset,
            interval: "1mo",
            period1: period1,
            period2: period2
        )
        let recentBars = try? await fetchMarketBars(
            for: asset,
            interval: "1wk",
            period1: Int(recentStartDate.timeIntervalSince1970),
            period2: period2
        )
        let yearlyBars = AssetHistory.yearlyBars(from: monthlyBars)
        let sixMonthBars = AssetHistory.bars(
            from: monthlyBars,
            monthsPerBar: MarketBarInterval.sixMonths.monthsPerBar
        )
        let monthlyPoints = monthlyBars.map(\.pricePoint)
        let recentPoints = recentBars?.map(\.pricePoint)

        guard !monthlyPoints.isEmpty else {
            throw HistoricalDataError.emptySeries(asset.symbol)
        }

        return AssetHistory(
            asset: asset,
            symbol: asset.symbol,
            displayName: asset.displayName,
            categoryLabel: asset.categoryLabel,
            monthlyPoints: monthlyPoints,
            recentPoints: recentPoints,
            monthlyBars: monthlyBars,
            recentBars: recentBars,
            sixMonthBars: sixMonthBars,
            yearlyBars: yearlyBars
        )
    }

    private static func fetchMarketBars(
        for asset: AssetID,
        interval: String,
        period1: Int,
        period2: Int
    ) async throws -> [MarketBar] {
        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(asset.symbol)?interval=\(interval)&period1=\(period1)&period2=\(period2)&events=div%2Csplits&includeAdjustedClose=true")!
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw HistoricalDataError.invalidResponse
        }

        let decoder = JSONDecoder()
        let payload = try decoder.decode(YahooChartPayload.self, from: data)
        guard
            let result = payload.chart.result?.first,
            let timestamps = result.timestamp,
            let quote = result.indicators.quote.first,
            let opens = quote.open,
            let highs = quote.high,
            let lows = quote.low,
            let closes = quote.close,
            let adjusted = result.indicators.adjclose.first?.adjclose
        else {
            throw HistoricalDataError.invalidResponse
        }

        let bars = timestamps.indices.compactMap { index -> MarketBar? in
            guard
                timestamps.indices.contains(index),
                opens.indices.contains(index),
                highs.indices.contains(index),
                lows.indices.contains(index),
                closes.indices.contains(index),
                adjusted.indices.contains(index),
                let open = opens[index],
                let high = highs[index],
                let low = lows[index],
                let close = closes[index],
                let adjustedClose = adjusted[index],
                open > 0,
                high > 0,
                low > 0,
                close > 0,
                adjustedClose > 0
            else {
                return nil
            }

            let volume = quote.volume?.indices.contains(index) == true ? quote.volume?[index] : nil
            return MarketBar(
                date: Date(timeIntervalSince1970: timestamps[index]),
                open: open,
                high: high,
                low: low,
                close: close,
                adjustedClose: adjustedClose,
                volume: volume ?? nil
            )
        }

        guard !bars.isEmpty else {
            throw HistoricalDataError.emptySeries(asset.symbol)
        }

        return bars
    }

    static func clearPersistedData(fileManager: FileManager = .default) throws {
        for url in try defaultCacheURLs(fileManager: fileManager) where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    private static func defaultCacheURLs(fileManager: FileManager) throws -> [URL] {
        [
            try currentCacheURL(fileManager: fileManager),
            try legacyCacheURL(fileManager: fileManager)
        ]
    }

    private static func currentCacheURL(fileManager: FileManager) throws -> URL {
        try applicationSupportDirectory(fileManager: fileManager)
            .appending(path: AppBrand.internalName, directoryHint: .isDirectory)
            .appending(path: "historical_cache.json")
    }

    private static func legacyCacheURL(fileManager: FileManager) throws -> URL {
        try applicationSupportDirectory(fileManager: fileManager)
            .appending(path: AppBrand.legacyInternalName, directoryHint: .isDirectory)
            .appending(path: "historical_cache.json")
    }

    private static func applicationSupportDirectory(fileManager: FileManager) throws -> URL {
        try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
}

private struct YahooChartPayload: Decodable {
    let chart: YahooChartContainer
}

private struct YahooChartContainer: Decodable {
    let result: [YahooChartResult]?
}

private struct YahooChartResult: Decodable {
    let timestamp: [TimeInterval]?
    let indicators: YahooIndicators
}

private struct YahooIndicators: Decodable {
    let adjclose: [YahooAdjCloseSeries]
    let quote: [YahooQuoteSeries]
}

private struct YahooAdjCloseSeries: Decodable {
    let adjclose: [Double?]
}

private struct YahooQuoteSeries: Decodable {
    let open: [Double?]?
    let high: [Double?]?
    let low: [Double?]?
    let close: [Double?]?
    let volume: [Double?]?
}
