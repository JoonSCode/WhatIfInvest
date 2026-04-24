import SwiftUI

struct ShareCardView: View {
    let primaryResult: ScenarioResult
    let comparisons: [ScenarioResult]
    let lastUpdatedAt: Date?

    var body: some View {
        ZStack {
            AppTheme.shareGradient

            VStack(alignment: .leading, spacing: 24) {
                shareHeader

                primaryScenarioBlock

                shareMetrics

                if !comparisons.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(L10n.shareComparedAgainstTitle)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .lineLimit(2)

                        ForEach(comparisons.prefix(3)) { result in
                            ShareComparisonRow(result: result)
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
                        .lineLimit(3)
                    if let lastUpdatedAt {
                        Text(L10n.shareSnapshotRefreshed(lastUpdatedAt.formatted(.dateTime.year().month().day())))
                            .lineLimit(2)
                    }
                }
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(64)
        }
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
    }

    private var shareHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppBrand.displayName)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.brandPrimary)
                .lineLimit(2)

            Text(L10n.shareHeroTitle)
                .font(.system(size: 74, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var primaryScenarioBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(primaryResult.scenario.asset.symbol)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(primaryResult.scenario.asset.tint)
                .lineLimit(1)

            Text(primaryResult.currentValue.currencyText)
                .font(.system(size: 92, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .allowsTightening(true)

            ShareScenarioMetadataView(scenario: primaryResult.scenario)
        }
    }

    private var shareMetrics: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 18) {
                shareMetric(title: L10n.investedTitle, value: primaryResult.investedAmount.currencyText)
                shareMetric(title: L10n.returnTitle, value: primaryResult.totalReturnRatio.percentText)
                shareMetric(title: L10n.spanTitle, value: UIFormatting.spanDescriptor(for: primaryResult))
            }

            VStack(alignment: .leading, spacing: 14) {
                shareMetric(title: L10n.investedTitle, value: primaryResult.investedAmount.currencyText)
                shareMetric(title: L10n.returnTitle, value: primaryResult.totalReturnRatio.percentText)
                shareMetric(title: L10n.spanTitle, value: UIFormatting.spanDescriptor(for: primaryResult))
            }
        }
    }

    private func shareMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.88),
            radius: 30
        )
    }
}

private struct ShareScenarioMetadataView: View {
    let scenario: InvestmentScenario

    var body: some View {
        let parts = UIFormatting.scenarioParts(scenario)

        ViewThatFits(in: .horizontal) {
            HStack(spacing: 14) {
                metadataBlock(title: L10n.startDateFieldTitle, value: parts.startDate)
                metadataBlock(title: L10n.modeFieldTitle, value: parts.mode)
                metadataBlock(title: parts.amountTitle, value: parts.amount)
            }

            VStack(alignment: .leading, spacing: 12) {
                metadataBlock(title: L10n.startDateFieldTitle, value: parts.startDate)
                metadataBlock(title: L10n.modeFieldTitle, value: parts.mode)
                metadataBlock(title: parts.amountTitle, value: parts.amount)
            }
        }
    }

    private func metadataBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.72),
            radius: 22
        )
    }
}

private struct ShareComparisonRow: View {
    let result: ScenarioResult

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(result.scenario.asset.tint)
                .frame(width: 18, height: 18)
                .padding(.top, 5)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    symbol
                    Spacer(minLength: 0)
                    value
                    returnValue
                }

                VStack(alignment: .leading, spacing: 4) {
                    symbol
                    HStack(spacing: 12) {
                        value
                        returnValue
                    }
                }
            }
            .layoutPriority(1)
        }
    }

    private var symbol: some View {
        Text(result.scenario.asset.symbol)
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textPrimary)
            .lineLimit(1)
    }

    private var value: some View {
        Text(result.currentValue.currencyText)
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textPrimary)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.78)
    }

    private var returnValue: some View {
        Text(result.totalReturnRatio.percentText)
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textSecondary)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.78)
    }
}
