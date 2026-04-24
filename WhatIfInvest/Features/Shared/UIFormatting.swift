import Foundation
import SwiftUI

extension Double {
    var currencyText: String {
        formatted(
            .currency(code: "USD")
                .precision(.fractionLength(0...2))
        )
    }

    var percentText: String {
        formatted(.percent.precision(.fractionLength(1)))
    }
}

extension Date {
    var monthYearText: String {
        formatted(.dateTime.year().month(.abbreviated))
    }
}

enum UIFormatting {
    struct ScenarioParts {
        let assetSymbol: String
        let assetName: String
        let startDate: String
        let mode: String
        let amount: String
        let amountTitle: String
    }

    static func scenarioParts(_ scenario: InvestmentScenario) -> ScenarioParts {
        ScenarioParts(
            assetSymbol: scenario.asset.symbol,
            assetName: scenario.asset.displayName,
            startDate: scenario.startDate.monthYearText,
            mode: scenario.mode.title,
            amount: scenario.amount.currencyText,
            amountTitle: scenario.mode.amountFieldLabel
        )
    }

    static func scenarioDescriptor(_ scenario: InvestmentScenario) -> String {
        let parts = scenarioParts(scenario)
        return "\(parts.assetSymbol) · \(parts.startDate) · \(parts.mode) \(parts.amount)"
    }

    static func scenarioMetadataLine(_ scenario: InvestmentScenario) -> String {
        let parts = scenarioParts(scenario)
        return "\(parts.startDate) · \(parts.mode) · \(parts.amount)"
    }

    static func spanDescriptor(for result: ScenarioResult) -> String {
        let years = Double(result.elapsedMonths) / 12
        if years >= 1 {
            return L10n.spanYears(years)
        }
        return L10n.spanMonths(result.elapsedMonths)
    }
}

struct TrustNotesView: View {
    let providerLabel: String
    let lastUpdatedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.trustHowToRead, systemImage: "checkmark.shield")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.trustAdjustedClose)
                Text(L10n.trustExclusions)
                if let lastUpdatedAt {
                    Text(L10n.trustLatestSnapshotDate(lastUpdatedAt.formatted(.dateTime.year().month().day())))
                    Text(L10n.trustLatestSnapshotProvider(providerLabel))
                } else {
                    Text(L10n.trustLatestSnapshotUnavailable)
                }
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textPrimary.opacity(0.82))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.88),
            radius: 24
        )
    }
}
