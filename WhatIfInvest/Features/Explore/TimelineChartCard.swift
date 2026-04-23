import Charts
import SwiftUI

struct TimelineChartCard: View {
    let series: [ChartSeriesDescriptor]
    @Binding var visibleYearIndex: Int
    @Binding var visibleWindow: TimelineVisibleWindow
    let allYears: [Int]
    let onOpenDetail: () -> Void

    @State private var chartNow = Date.now

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Text(L10n.timelineReplayTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                Spacer(minLength: 0)

                Button(action: onOpenDetail) {
                    Label(L10n.chartDetailOpen, systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("timeline-open-detail-button")
            }

            TimelineWindowPicker(
                visibleWindow: $visibleWindow,
                accessibilityIdentifier: "timeline-compact-window-picker"
            )

            compactChart
                .frame(height: 280)
                .accessibilityIdentifier("timeline-chart-card")

            TimelineSeriesLegendGrid(
                series: series,
                accessibilityPrefix: "timeline-compact-series",
                fill: AppTheme.ColorToken.surfaceSubtle.opacity(0.92)
            )
        }
        .padding(20)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.92),
            radius: AppTheme.Radius.lg
        )
    }

    private var compactChart: some View {
        Chart {
            ForEach(series) { descriptor in
                let points = visiblePoints(for: descriptor)

                ForEach(points) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Amount", point.portfolioValue)
                    )
                    .foregroundStyle(by: .value("Scenario", descriptor.seriesKey))
                    .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }

                if let lastPoint = points.last {
                    PointMark(
                        x: .value("Time", lastPoint.date),
                        y: .value("Amount", lastPoint.portfolioValue)
                    )
                    .foregroundStyle(by: .value("Scenario", descriptor.seriesKey))
                    .symbol(by: .value("Scenario", descriptor.seriesKey))
                    .symbolSize(80)
                }
            }
        }
        .chartForegroundStyleScale(
            domain: series.map(\.seriesKey),
            range: series.map(\.color)
        )
        .chartSymbolScale(domain: series.map(\.seriesKey)) { seriesKey in
            symbol(for: seriesKey).chartShape
        }
        .chartXScale(domain: chartDateDomain)
        .chartYScale(domain: TimelineChartMetrics.valueDomain(for: compactVisiblePoints))
        .chartYAxisLabel(position: .leading, alignment: .center) {
            Text(L10n.chartAmountAxis)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                    .foregroundStyle(AppTheme.ColorToken.borderSoft)
                AxisTick()
                    .foregroundStyle(AppTheme.ColorToken.borderSoft)
                AxisValueLabel(format: TimelineChartMetrics.axisLabelFormat(for: visibleWindow))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                    .foregroundStyle(AppTheme.ColorToken.borderSoft)
                AxisTick()
                    .foregroundStyle(AppTheme.ColorToken.borderSoft)
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                            .monospacedDigit()
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { plot in
            plot
                .background(AppTheme.ColorToken.surfaceSubtle.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func visiblePoints(for descriptor: ChartSeriesDescriptor) -> [TimelinePoint] {
        let replayPoints: [TimelinePoint]
        guard !allYears.isEmpty else {
            replayPoints = descriptor.result.timeline
            return TimelineChartMetrics.points(replayPoints, in: chartDateDomain)
        }
        let upperYear = allYears[min(visibleYearIndex, allYears.count - 1)]
        replayPoints = descriptor.result.timeline.filter { $0.year <= upperYear }
        return TimelineChartMetrics.points(replayPoints, in: chartDateDomain)
    }

    private var compactVisiblePoints: [TimelinePoint] {
        series.flatMap { visiblePoints(for: $0) }
    }

    private var chartDateDomain: ClosedRange<Date> {
        TimelineChartMetrics.dateDomain(for: series, endingAt: chartNow)
    }

    private func symbol(for seriesKey: String) -> ChartSeriesSymbol {
        series.first(where: { $0.seriesKey == seriesKey })?.symbol ?? .circle
    }
}

struct TimelineWindowPicker: View {
    @Binding var visibleWindow: TimelineVisibleWindow
    let accessibilityIdentifier: String

    var body: some View {
        Picker(L10n.chartWindowTitle, selection: $visibleWindow) {
            ForEach(TimelineVisibleWindow.allCases) { window in
                Text(window.title)
                    .tag(window)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct TimelineSeriesLegendGrid: View {
    let series: [ChartSeriesDescriptor]
    let accessibilityPrefix: String
    let fill: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(series.enumerated()), id: \.element.id) { index, descriptor in
                TimelineSeriesLegendRow(
                    descriptor: descriptor,
                    accessibilityIdentifier: "\(accessibilityPrefix)-\(index)",
                    fill: fill
                )
            }
        }
    }
}

enum TimelineChartMetrics {
    static let defaultVisibleMonths = 60

    static func dateDomain(for dates: [Date]) -> ClosedRange<Date> {
        let sortedDates = dates.sorted()
        guard let firstDate = sortedDates.first, let lastDate = sortedDates.last else {
            let now = Date.now
            return now...now
        }

        if firstDate == lastDate {
            let padded = Calendar.utc.date(byAdding: .month, value: 1, to: lastDate) ?? lastDate
            return firstDate...padded
        }

        return firstDate...lastDate
    }

    static func dateDomain(for series: [ChartSeriesDescriptor], endingAt now: Date) -> ClosedRange<Date> {
        let startDates = series.map { $0.result.scenario.normalizedStartDate }
        let latestDates = series.compactMap { $0.result.timeline.last?.date }

        guard let startDate = startDates.min(), let latestDate = latestDates.max() else {
            return now...now
        }

        let upperDate = max(latestDate, now)
        if startDate >= upperDate {
            let padded = Calendar.utc.date(byAdding: .month, value: 1, to: upperDate) ?? upperDate
            return startDate...padded
        }

        return startDate...upperDate
    }

    static func valueDomain(for series: [ChartSeriesDescriptor]) -> ClosedRange<Double> {
        valueDomain(for: series.flatMap { $0.result.timeline })
    }

    static func valueDomain(for points: [TimelinePoint]) -> ClosedRange<Double> {
        let allPortfolioValues = points.map(\.portfolioValue)
        guard
            let minimumValue = allPortfolioValues.min(),
            let maximumValue = allPortfolioValues.max()
        else {
            return 0...1
        }

        let lowerBound = max(0, minimumValue * 0.9)
        let upperBound = maximumValue * 1.08

        if lowerBound == upperBound {
            return lowerBound...(upperBound + 1)
        }

        return lowerBound...upperBound
    }

    static func visibleLength(for domain: ClosedRange<Date>) -> TimeInterval {
        visibleLength(for: domain, preferredMonths: defaultVisibleMonths)
    }

    static func initialScrollDate(for domain: ClosedRange<Date>) -> Date {
        initialScrollDate(for: domain, visibleLength: visibleLength(for: domain))
    }

    static func points(_ points: [TimelinePoint], in domain: ClosedRange<Date>) -> [TimelinePoint] {
        points.filter { point in
            point.date >= domain.lowerBound && point.date <= domain.upperBound
        }
    }

    static func axisLabelFormat(for window: TimelineVisibleWindow) -> Date.FormatStyle {
        switch window {
        case .oneMonth:
            return .dateTime.month(.abbreviated).year(.twoDigits)
        case .sixMonths:
            return .dateTime.month(.abbreviated).year(.twoDigits)
        case .oneYear:
            return .dateTime.year()
        }
    }

    private static func visibleLength(for domain: ClosedRange<Date>, preferredMonths: Int?) -> TimeInterval {
        let totalMonths = spanMonths(for: domain)
        let visibleMonths = max(1, min(preferredMonths ?? totalMonths, totalMonths))
        return Double(visibleMonths) * 30 * 24 * 60 * 60
    }

    private static func initialScrollDate(for domain: ClosedRange<Date>, visibleLength: TimeInterval) -> Date {
        let visibleMonths = Int(visibleLength / (30 * 24 * 60 * 60))
        let totalMonths = spanMonths(for: domain)

        guard totalMonths > visibleMonths else {
            return domain.lowerBound
        }

        return Calendar.utc.date(byAdding: .month, value: -visibleMonths, to: domain.upperBound) ?? domain.lowerBound
    }

    private static func spanMonths(for domain: ClosedRange<Date>) -> Int {
        max(1, Calendar.utc.dateComponents([.month], from: domain.lowerBound, to: domain.upperBound).month ?? 1)
    }

}

private struct TimelineSeriesLegendRow: View {
    let descriptor: ChartSeriesDescriptor
    let accessibilityIdentifier: String
    let fill: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: descriptor.symbol.systemImageName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(descriptor.color)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(descriptor.color.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(descriptor.primaryText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(descriptor.secondaryText)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .appCardSurface(
            fill: fill,
            radius: 18
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(descriptor.primaryText). \(descriptor.secondaryText)")
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
