import XCTest
@testable import TimeMachineInvest

final class HistoricalDataStoreTests: XCTestCase {
    func testLoadHistoricalDataFallsBackToBundledPayloadWhenCacheIsCorrupted() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let bundledURL = directory.appending(path: "bundled.json")
        let cacheURL = directory.appending(path: "historical_cache.json")
        let expectedPayload = makePayload(generatedAt: Self.date(year: 2026, month: 4, day: 22))

        try Self.writePayload(expectedPayload, to: bundledURL)
        try Data("broken".utf8).write(to: cacheURL)

        let store = HistoricalDataStore(
            bundledPayloadURL: bundledURL,
            cacheFileURL: cacheURL
        )

        let loaded = try await store.loadHistoricalData()

        XCTAssertEqual(loaded.provider, expectedPayload.provider)
        XCTAssertEqual(loaded.histories.count, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: cacheURL.path))
    }

    func testRefreshAllDataPersistsFetchedPayload() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let cacheURL = directory.appending(path: "historical_cache.json")
        let generatedAt = Self.date(year: 2026, month: 4, day: 22)

        let store = HistoricalDataStore(
            cacheFileURL: cacheURL,
            now: { generatedAt },
            historyFetcher: { asset in
                AssetHistory(
                    asset: asset,
                    symbol: asset.symbol,
                    displayName: asset.displayName,
                    categoryLabel: asset.categoryLabel,
                    monthlyPoints: [
                        MarketPoint(date: Self.date(year: 2020, month: 1, day: 1), adjustedClose: 100),
                        MarketPoint(date: Self.date(year: 2020, month: 2, day: 1), adjustedClose: 110)
                    ]
                )
            }
        )

        let payload = try await store.refreshAllData()
        let cachedData = try Data(contentsOf: cacheURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let cachedPayload = try decoder.decode(BundledHistoricalData.self, from: cachedData)

        XCTAssertEqual(payload.generatedAt, generatedAt)
        XCTAssertEqual(payload.histories.count, AssetID.allCases.count)
        XCTAssertEqual(cachedPayload.generatedAt, generatedAt)
        XCTAssertEqual(cachedPayload.histories.count, AssetID.allCases.count)
    }

    private func makePayload(generatedAt: Date) -> BundledHistoricalData {
        BundledHistoricalData(
            generatedAt: generatedAt,
            provider: "Test Provider",
            interval: "1mo",
            histories: [
                AssetHistory(
                    asset: .spy,
                    symbol: "SPY",
                    displayName: "SPDR S&P 500 ETF",
                    categoryLabel: "Major ETF",
                    monthlyPoints: [
                        MarketPoint(date: Self.date(year: 2020, month: 1, day: 1), adjustedClose: 100),
                        MarketPoint(date: Self.date(year: 2020, month: 2, day: 1), adjustedClose: 110)
                    ]
                )
            ]
        )
    }

    private static func writePayload(_ payload: BundledHistoricalData, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: [.atomic])
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.utc.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
