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

struct SponsoredBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.badge.ad")
                .font(.title3)
                .foregroundStyle(Color(red: 0.47, green: 0.31, blue: 0.18))

            VStack(alignment: .leading, spacing: 4) {
                Text("Sponsored slot")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("Reserved for a single below-the-fold banner placement.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.06))
                )
        )
    }
}

struct TrustNotesView: View {
    let providerLabel: String
    let lastUpdatedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("How to read this", systemImage: "checkmark.shield")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 8) {
                Text("Returns use adjusted close, which reflects splits and dividends.")
                Text("Taxes, fees, exchange rates, and inflation are excluded.")
                if let lastUpdatedAt {
                    Text("Latest data snapshot: \(lastUpdatedAt.formatted(.dateTime.year().month().day())) via \(providerLabel).")
                } else {
                    Text("Latest data snapshot unavailable.")
                }
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.97, green: 0.95, blue: 0.90))
        )
    }
}
