import Foundation

enum TimelineVisibleWindow: String, CaseIterable, Identifiable {
    case oneMonth
    case sixMonths
    case oneYear

    var id: String { rawValue }

    var months: Int {
        barInterval.monthsPerBar
    }

    var barInterval: MarketBarInterval {
        switch self {
        case .oneMonth:
            return .oneMonth
        case .sixMonths:
            return .sixMonths
        case .oneYear:
            return .oneYear
        }
    }

    var title: String {
        switch self {
        case .oneMonth:
            return L10n.chartWindowOneMonth
        case .sixMonths:
            return L10n.chartWindowSixMonths
        case .oneYear:
            return L10n.chartWindowOneYear
        }
    }

    func bucketKey(for date: Date) -> Int {
        barInterval.bucketKey(for: date)
    }
}
