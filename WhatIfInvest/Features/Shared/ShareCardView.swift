import SwiftUI

struct ShareCardView: View {
    let primaryResult: ScenarioResult
    let comparisons: [ScenarioResult]
    let lastUpdatedAt: Date?

    var body: some View {
        ZStack {
            AppTheme.shareGradient

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppBrand.displayName)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.ColorToken.brandPrimary)
                        .lineLimit(2)

                    Text(L10n.shareHeroTitle)
                        .font(.system(size: 74, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.ColorToken.textPrimary)
                        .minimumScaleFactor(0.7)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(primaryResult.scenario.asset.symbol)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryResult.scenario.asset.tint)

                    Text(primaryResult.currentValue.currencyText)
                        .font(.system(size: 92, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.ColorToken.textPrimary)
                        .monospacedDigit()

                    Text(UIFormatting.scenarioDescriptor(primaryResult.scenario))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)
                }

                HStack(spacing: 18) {
                    shareMetric(title: L10n.investedTitle, value: primaryResult.investedAmount.currencyText)
                    shareMetric(title: L10n.returnTitle, value: primaryResult.totalReturnRatio.percentText)
                    shareMetric(title: L10n.spanTitle, value: UIFormatting.spanDescriptor(for: primaryResult))
                }

                if !comparisons.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(L10n.shareComparedAgainstTitle)
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        ForEach(comparisons.prefix(3)) { result in
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(result.scenario.asset.tint)
                                    .frame(width: 18, height: 18)

                                Text("\(result.scenario.asset.symbol)  \(result.currentValue.currencyText)  \(result.totalReturnRatio.percentText)")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.ColorToken.textPrimary)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardSurface(
                        fill: AppTheme.ColorToken.surfaceBase.opacity(0.82),
                        radius: 34
                    )
                }

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.shareDisclaimer)
                    if let lastUpdatedAt {
                        Text(L10n.shareSnapshotRefreshed(lastUpdatedAt.formatted(.dateTime.year().month().day())))
                    }
                }
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
            }
            .padding(64)
        }
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
    }

    private func shareMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .monospacedDigit()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.88),
            radius: 30
        )
    }
}
