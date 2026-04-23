import Foundation
import SwiftUI

enum AssetID: String, Codable, CaseIterable, Identifiable, Sendable {
    case spy
    case voo
    case vti
    case qqq
    case dia
    case aapl
    case msft
    case nvda
    case amzn
    case googl
    case meta
    case tsla

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .googl:
            return "GOOGL"
        default:
            return rawValue.uppercased()
        }
    }

    var displayName: String {
        L10n.assetDisplayName(for: self)
    }

    var categoryLabel: String {
        switch self {
        case .spy, .voo, .vti, .qqq, .dia:
            return L10n.categoryMajorETF
        default:
            return L10n.categoryMagnificent7
        }
    }

    var tint: Color {
        switch self {
        case .spy: return Color(red: 0.14, green: 0.36, blue: 0.72)
        case .voo: return Color(red: 0.08, green: 0.48, blue: 0.54)
        case .vti: return Color(red: 0.35, green: 0.49, blue: 0.22)
        case .qqq: return Color(red: 0.55, green: 0.25, blue: 0.18)
        case .dia: return Color(red: 0.47, green: 0.34, blue: 0.64)
        case .aapl: return Color(red: 0.22, green: 0.24, blue: 0.28)
        case .msft: return Color(red: 0.10, green: 0.44, blue: 0.83)
        case .nvda: return Color(red: 0.29, green: 0.59, blue: 0.19)
        case .amzn: return Color(red: 0.74, green: 0.49, blue: 0.14)
        case .googl: return Color(red: 0.78, green: 0.24, blue: 0.22)
        case .meta: return Color(red: 0.25, green: 0.46, blue: 0.80)
        case .tsla: return Color(red: 0.74, green: 0.16, blue: 0.18)
        }
    }
}

enum InvestmentMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case lumpSum
    case recurringMonthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lumpSum:
            return L10n.modeLumpSumTitle
        case .recurringMonthly:
            return L10n.modeRecurringMonthlyTitle
        }
    }

    var inlineLabel: String {
        switch self {
        case .lumpSum:
            return L10n.modeLumpSumInline
        case .recurringMonthly:
            return L10n.modeRecurringMonthlyInline
        }
    }

    var amountFieldLabel: String {
        switch self {
        case .lumpSum:
            return L10n.modeLumpSumAmountField
        case .recurringMonthly:
            return L10n.modeRecurringMonthlyAmountField
        }
    }
}

struct InvestmentScenario: Codable, Hashable, Identifiable, Sendable {
    var id: UUID = UUID()
    var asset: AssetID
    var startDate: Date
    var mode: InvestmentMode
    var amount: Double

    var normalizedStartDate: Date {
        Calendar.utc.startOfDay(for: startDate)
    }

    var storageKey: String {
        let amountInCents = Int((amount * 100).rounded())
        return "\(asset.rawValue)|\(mode.rawValue)|\(Int(normalizedStartDate.timeIntervalSince1970))|\(amountInCents)"
    }

    static let starter = InvestmentScenario(
        asset: .voo,
        startDate: Calendar.utc.date(from: DateComponents(year: 2014, month: 1, day: 1)) ?? .now,
        mode: .lumpSum,
        amount: 10_000
    )

    static func suggestedComparison(after scenario: InvestmentScenario, excluding existingAssets: [AssetID]) -> InvestmentScenario {
        let assetPreference: [AssetID]
        switch scenario.asset {
        case .voo, .spy, .vti, .dia:
            assetPreference = [.qqq, .nvda, .aapl, .msft]
        case .qqq:
            assetPreference = [.voo, .nvda, .meta]
        default:
            assetPreference = [.voo, .qqq, .msft, .aapl]
        }

        let chosenAsset = assetPreference.first { $0 != scenario.asset && !existingAssets.contains($0) }
            ?? AssetID.allCases.first { $0 != scenario.asset && !existingAssets.contains($0) }
            ?? .qqq

        return InvestmentScenario(
            asset: chosenAsset,
            startDate: scenario.startDate,
            mode: scenario.mode,
            amount: scenario.amount
        )
    }
}

struct MarketPoint: Codable, Hashable, Sendable {
    var date: Date
    var adjustedClose: Double
}

enum MarketBarInterval: Hashable, Sendable {
    case oneMonth
    case sixMonths
    case oneYear

    var monthsPerBar: Int {
        switch self {
        case .oneMonth:
            return 1
        case .sixMonths:
            return 6
        case .oneYear:
            return 12
        }
    }

    func bucketKey(for date: Date) -> Int {
        let year = Calendar.utc.component(.year, from: date)
        let month = Calendar.utc.component(.month, from: date)

        switch self {
        case .oneMonth:
            return year * 12 + month
        case .sixMonths:
            return year * 2 + ((month - 1) / 6)
        case .oneYear:
            return year
        }
    }
}

struct MarketBar: Codable, Hashable, Sendable {
    var date: Date
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var adjustedClose: Double
    var volume: Double?

    var pricePoint: MarketPoint {
        MarketPoint(date: date, adjustedClose: adjustedClose)
    }
}

struct AssetHistory: Codable, Hashable, Sendable {
    var asset: AssetID
    var symbol: String
    var displayName: String
    var categoryLabel: String
    var monthlyPoints: [MarketPoint]
    var recentPoints: [MarketPoint]?
    var monthlyBars: [MarketBar]? = nil
    var recentBars: [MarketBar]? = nil
    var sixMonthBars: [MarketBar]? = nil
    var yearlyBars: [MarketBar]? = nil

    var pricePoints: [MarketPoint] {
        let monthlySeries = monthlyBars?.map(\.pricePoint) ?? monthlyPoints
        let recentSeries = recentBars?.map(\.pricePoint) ?? (recentPoints ?? [])
        return Self.deduplicatedByDay(monthlySeries + recentSeries)
    }

    var annualBars: [MarketBar] {
        let sourceBars = monthlyBarSeries
        return sourceBars.isEmpty ? (yearlyBars ?? []) : Self.yearlyBars(from: sourceBars)
    }

    func pricePoints(for interval: MarketBarInterval?) -> [MarketPoint] {
        guard let interval else {
            return pricePoints
        }

        return bars(for: interval).map(\.pricePoint)
    }

    func bars(for interval: MarketBarInterval) -> [MarketBar] {
        switch interval {
        case .oneMonth:
            return monthlyBarSeries
        case .sixMonths:
            return sixMonthBars ?? Self.bars(from: monthlyBarSeries, monthsPerBar: interval.monthsPerBar)
        case .oneYear:
            return annualBars
        }
    }

    private static func deduplicatedByDay(_ points: [MarketPoint]) -> [MarketPoint] {
        var keyedPoints: [Date: MarketPoint] = [:]
        for point in points where point.adjustedClose > 0 {
            keyedPoints[Calendar.utc.startOfDay(for: point.date)] = point
        }
        return keyedPoints.values.sorted { $0.date < $1.date }
    }

    static func yearlyBars(from bars: [MarketBar]) -> [MarketBar] {
        self.bars(from: bars, monthsPerBar: MarketBarInterval.oneYear.monthsPerBar)
    }

    static func bars(from bars: [MarketBar], monthsPerBar: Int) -> [MarketBar] {
        guard monthsPerBar > 0 else { return [] }

        let grouped = Dictionary(grouping: bars.filter(\.isValidOHLC)) { bar in
            let year = Calendar.utc.component(.year, from: bar.date)
            let month = Calendar.utc.component(.month, from: bar.date)
            let bucket = (month - 1) / monthsPerBar
            return year * (12 / monthsPerBar) + bucket
        }

        return grouped.keys.sorted().compactMap { key in
            let bucketBars = (grouped[key] ?? []).sorted { $0.date < $1.date }
            guard
                let first = bucketBars.first,
                let last = bucketBars.last,
                let high = bucketBars.map(\.high).max(),
                let low = bucketBars.map(\.low).min()
            else {
                return nil
            }

            let volumes = bucketBars.compactMap(\.volume)
            return MarketBar(
                date: last.date,
                open: first.open,
                high: high,
                low: low,
                close: last.close,
                adjustedClose: last.adjustedClose,
                volume: volumes.isEmpty ? nil : volumes.reduce(0, +)
            )
        }
    }

    private var monthlyBarSeries: [MarketBar] {
        if let monthlyBars, !monthlyBars.isEmpty {
            return monthlyBars
        }

        return monthlyPoints.map { point in
            MarketBar(
                date: point.date,
                open: point.adjustedClose,
                high: point.adjustedClose,
                low: point.adjustedClose,
                close: point.adjustedClose,
                adjustedClose: point.adjustedClose,
                volume: nil
            )
        }
    }
}

private extension MarketBar {
    var isValidOHLC: Bool {
        open > 0 && high > 0 && low > 0 && close > 0 && adjustedClose > 0
    }
}

struct BundledHistoricalData: Codable, Sendable {
    var generatedAt: Date
    var provider: String
    var interval: String
    var histories: [AssetHistory]
}

struct TimelinePoint: Hashable, Identifiable, Sendable {
    let date: Date
    let year: Int
    let investedAmount: Double
    let portfolioValue: Double

    var id: String {
        "\(year)-\(date.timeIntervalSince1970)"
    }
}

struct ScenarioResult: Identifiable, Sendable {
    let scenario: InvestmentScenario
    let investedAmount: Double
    let currentValue: Double
    let totalReturnRatio: Double
    let timeline: [TimelinePoint]

    var id: UUID {
        scenario.id
    }

    var elapsedMonths: Int {
        guard let first = timeline.first, let last = timeline.last else { return 0 }
        return Calendar.utc.dateComponents([.month], from: first.date, to: last.date).month ?? 0
    }
}

struct SavedScenario: Codable, Hashable, Identifiable, Sendable {
    var id: UUID = UUID()
    var scenario: InvestmentScenario
    var savedAt: Date
}

extension Calendar {
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()
}
