import Charts
import SwiftUI

struct TimelineDetailSheet: View {
    let series: [ChartSeriesDescriptor]
    @Binding var visibleWindow: TimelineVisibleWindow

    @Environment(\.dismiss) private var dismiss
    @State private var scrollPosition: Date
    @State private var chartNow: Date

    init(series: [ChartSeriesDescriptor], visibleWindow: Binding<TimelineVisibleWindow>) {
        self.series = series
        self._visibleWindow = visibleWindow

        let now = Date.now
        let domain = TimelineChartMetrics.dateDomain(for: series, endingAt: now)
        self._chartNow = State(initialValue: now)
        self._scrollPosition = State(initialValue: TimelineChartMetrics.initialScrollDate(for: domain))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.chartDetailHint)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    }

                    TimelineWindowPicker(
                        visibleWindow: $visibleWindow,
                        accessibilityIdentifier: "timeline-detail-window-picker"
                    )

                    detailChart
                        .frame(height: 360)
                        .accessibilityIdentifier("timeline-detail-chart")

                    TimelineSeriesLegendGrid(
                        series: series,
                        accessibilityPrefix: "timeline-detail-series",
                        fill: AppTheme.ColorToken.surfaceBase.opacity(0.94)
                    )
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .background(AppTheme.canvasGradient.ignoresSafeArea())
            .navigationTitle(L10n.chartDetailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.close) {
                        dismiss()
                    }
                    .accessibilityIdentifier("timeline-detail-close-button")
                }
            }
        }
    }

    private var detailChart: some View {
        Chart {
            ForEach(series) { descriptor in
                let points = chartPoints(for: descriptor)

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
                    .symbolSize(90)
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
        .chartYScale(domain: TimelineChartMetrics.valueDomain(for: chartVisiblePoints))
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: TimelineChartMetrics.visibleLength(for: chartDateDomain))
        .chartScrollPosition(x: $scrollPosition)
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
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
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
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .onAppear(perform: alignScrollToLatest)
    }

    private var chartDateDomain: ClosedRange<Date> {
        TimelineChartMetrics.dateDomain(for: series, endingAt: chartNow)
    }

    private var chartVisiblePoints: [TimelinePoint] {
        series.flatMap { chartPoints(for: $0) }
    }

    private func chartPoints(for descriptor: ChartSeriesDescriptor) -> [TimelinePoint] {
        TimelineChartMetrics.points(descriptor.result.timeline, in: chartDateDomain)
    }

    private func symbol(for seriesKey: String) -> ChartSeriesSymbol {
        series.first(where: { $0.seriesKey == seriesKey })?.symbol ?? .circle
    }

    private func alignScrollToLatest() {
        scrollPosition = TimelineChartMetrics.initialScrollDate(for: chartDateDomain)
    }
}
