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
    static func scenarioDescriptor(_ scenario: InvestmentScenario) -> String {
        "\(scenario.asset.symbol) · \(scenario.startDate.monthYearText) · \(scenario.mode.title) \(scenario.amount.currencyText)"
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
                    Text(
                        L10n.trustLatestSnapshot(
                            date: lastUpdatedAt.formatted(.dateTime.year().month().day()),
                            provider: providerLabel
                        )
                    )
                } else {
                    Text(L10n.trustLatestSnapshotUnavailable)
                }
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textPrimary.opacity(0.82))
        }
        .padding(18)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.88),
            radius: 24
        )
    }
}
