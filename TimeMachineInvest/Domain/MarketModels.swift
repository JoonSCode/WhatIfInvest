import Foundation
import SwiftUI

enum AssetID: String, Codable, CaseIterable, Identifiable {
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
        switch self {
        case .spy: return "SPDR S&P 500 ETF"
        case .voo: return "Vanguard S&P 500 ETF"
        case .vti: return "Vanguard Total Stock Market ETF"
        case .qqq: return "Invesco Nasdaq-100 ETF"
        case .dia: return "SPDR Dow Jones ETF"
        case .aapl: return "Apple"
        case .msft: return "Microsoft"
        case .nvda: return "NVIDIA"
        case .amzn: return "Amazon"
        case .googl: return "Alphabet"
        case .meta: return "Meta"
        case .tsla: return "Tesla"
        }
    }

    var categoryLabel: String {
        switch self {
        case .spy, .voo, .vti, .qqq, .dia:
            return "Major ETF"
        default:
            return "Magnificent 7"
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

enum InvestmentMode: String, Codable, CaseIterable, Identifiable {
    case lumpSum
    case recurringMonthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lumpSum:
            return "Lump Sum"
        case .recurringMonthly:
            return "Monthly"
        }
    }

    var inlineLabel: String {
        switch self {
        case .lumpSum:
            return "lump sum"
        case .recurringMonthly:
            return "monthly"
        }
    }

    var amountFieldLabel: String {
        switch self {
        case .lumpSum:
            return "Starting amount"
        case .recurringMonthly:
            return "Monthly amount"
        }
    }
}

struct InvestmentScenario: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var asset: AssetID
    var startDate: Date
    var mode: InvestmentMode
    var amount: Double

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

struct MarketPoint: Codable, Hashable {
    var date: Date
    var adjustedClose: Double
}

struct AssetHistory: Codable, Hashable {
    var asset: AssetID
    var symbol: String
    var displayName: String
    var categoryLabel: String
    var monthlyPoints: [MarketPoint]
}

struct BundledHistoricalData: Codable {
    var generatedAt: Date
    var provider: String
    var interval: String
    var histories: [AssetHistory]
}

struct TimelinePoint: Hashable, Identifiable {
    let date: Date
    let year: Int
    let investedAmount: Double
    let portfolioValue: Double

    var id: String {
        "\(year)-\(date.timeIntervalSince1970)"
    }
}

struct ScenarioResult: Identifiable {
    let scenario: InvestmentScenario
    let investedAmount: Double
    let currentValue: Double
    let totalReturnRatio: Double
    let timeline: [TimelinePoint]

    var id: UUID {
        scenario.id
    }
}

struct SavedScenario: Codable, Hashable, Identifiable {
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

