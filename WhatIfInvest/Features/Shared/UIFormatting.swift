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
            return "\(years.formatted(.number.precision(.fractionLength(1))))y"
        }
        return "\(result.elapsedMonths) mo"
    }
}

struct TrustNotesView: View {
    let providerLabel: String
    let lastUpdatedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("How to read this", systemImage: "checkmark.shield")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Returns use adjusted close, which reflects splits and dividends.")
                Text("Taxes, fees, exchange rates, and inflation are excluded.")
                if let lastUpdatedAt {
                    Text("Latest data snapshot: \(lastUpdatedAt.formatted(.dateTime.year().month().day())) via \(providerLabel).")
                } else {
                    Text("Latest data snapshot unavailable.")
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
