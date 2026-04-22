import SwiftUI

struct ShareCardView: View {
    let primaryResult: ScenarioResult
    let comparisons: [ScenarioResult]
    let lastUpdatedAt: Date?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.92, blue: 0.84),
                    Color(red: 0.93, green: 0.95, blue: 0.98),
                    Color(red: 0.98, green: 0.97, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time Machine Invest")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.18, blue: 0.24))

                    Text("If you had invested then")
                        .font(.system(size: 74, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.24))
                        .minimumScaleFactor(0.7)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(primaryResult.scenario.asset.symbol)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryResult.scenario.asset.tint)

                    Text(primaryResult.currentValue.currencyText)
                        .font(.system(size: 92, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.18, blue: 0.24))

                    Text(UIFormatting.scenarioDescriptor(primaryResult.scenario))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 18) {
                    shareMetric(title: "Invested", value: primaryResult.investedAmount.currencyText)
                    shareMetric(title: "Return", value: primaryResult.totalReturnRatio.percentText)
                    shareMetric(title: "Span", value: UIFormatting.spanDescriptor(for: primaryResult))
                }

                if !comparisons.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Compared against")
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        ForEach(comparisons.prefix(3)) { result in
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(result.scenario.asset.tint)
                                    .frame(width: 18, height: 18)

                                Text("\(result.scenario.asset.symbol)  \(result.currentValue.currencyText)  \(result.totalReturnRatio.percentText)")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.30))
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                    )
                }

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Adjusted close basis. Taxes, fees, FX, and inflation excluded.")
                    if let lastUpdatedAt {
                        Text("Snapshot refreshed \(lastUpdatedAt.formatted(.dateTime.year().month().day())).")
                    }
                }
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            }
            .padding(64)
        }
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
    }

    private func shareMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.24))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.76))
        )
    }
}
