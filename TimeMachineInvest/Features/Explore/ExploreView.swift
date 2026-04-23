import Charts
import Observation
import SwiftUI

struct ExploreView: View {
    @Environment(AppModel.self) private var appModel

    @State private var comparisonDraft = InvestmentScenario.suggestedComparison(after: .starter, excluding: [])
    @State private var showingComparisonSheet = false
    @State private var shareExport: ShareExportItem?
    @State private var visibleYearIndex = 0
    @State private var isPlaying = false
    @State private var isPreparingShare = false
    @State private var playbackTask: Task<Void, Never>?

    var body: some View {
        @Bindable var appModel = appModel

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader

                ScenarioEditorCard(
                    title: "Story mode",
                    subtitle: "Start with one scenario. Add comparisons only after the first answer lands.",
                    scenario: $appModel.primaryScenario,
                    assets: appModel.availableAssets,
                    availableDateRange: appModel.availableDateRange(for: appModel.primaryScenario.asset),
                    validationMessage: appModel.validationMessage(for: appModel.primaryScenario)
                )

                if let primaryResult = appModel.primaryResult {
                    ResultSummaryCard(result: primaryResult)

                    TimelineChartCard(
                        results: appModel.visibleResults,
                        visibleYearIndex: $visibleYearIndex,
                        allYears: appModel.animationYears
                    )

                    controlRow

                    if !appModel.comparisonScenarios.isEmpty {
                        comparisonSection
                    }
                } else if appModel.isLoading {
                    ProgressView("Loading historical data...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    fallbackState(message: appModel.validationMessage(for: appModel.primaryScenario))
                }

                TrustNotesView(
                    providerLabel: appModel.providerLabel,
                    lastUpdatedAt: appModel.lastUpdatedAt
                )
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .background(backgroundGradient)
        .navigationTitle(AppBrand.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingComparisonSheet) {
            NavigationStack {
                ComparisonComposerView(
                    scenario: $comparisonDraft,
                    assets: appModel.availableAssets,
                    availableDateRange: appModel.availableDateRange(for: comparisonDraft.asset),
                    validationMessage: appModel.validationMessage(for: comparisonDraft),
                    onAdd: {
                        appModel.addComparisonScenario(comparisonDraft)
                        comparisonDraft = appModel.nextComparisonDraft()
                        showingComparisonSheet = false
                    }
                )
            }
            .presentationDetents([.large])
        }
        .sheet(item: $shareExport) { export in
            ActivityShareSheet(items: [export.caption, export.fileURL])
        }
        .task {
            alignVisibleYearToLatest()
        }
        .onChange(of: appModel.animationYears) { _, _ in
            alignVisibleYearToLatest()
        }
        .onChange(of: appModel.primaryScenario) { _, _ in
            alignVisibleYearToLatest()
            stopPlayback()
        }
        .onChange(of: appModel.comparisonScenarios) { _, _ in
            alignVisibleYearToLatest()
            stopPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("If you had invested then")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.24))

            Text("A hindsight simulator for major US ETFs and the Magnificent 7. Built to make the force of time feel visual, not abstract.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            if let message = appModel.lastErrorMessage {
                Label(message, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.red)
            }
        }
    }

    private var controlRow: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Button(isPlaying ? "Stop Playback" : "Play Years") {
                    togglePlayback()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.10, green: 0.29, blue: 0.54))
                .accessibilityIdentifier("timeline-playback-button")

                Button("Add Comparison") {
                    comparisonDraft = appModel.nextComparisonDraft()
                    showingComparisonSheet = true
                }
                .buttonStyle(.bordered)
                .disabled(appModel.primaryResult == nil)
                .accessibilityIdentifier("add-comparison-button")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            FlowLayout(spacing: 10) {
                Button {
                    appModel.savePrimaryScenario()
                } label: {
                    Label("Save Scenario", systemImage: "bookmark")
                }
                .buttonStyle(.bordered)
                .disabled(appModel.primaryResult == nil)
                .accessibilityIdentifier("save-scenario-button")

                Button {
                    Task { await prepareShareCard() }
                } label: {
                    Label(isPreparingShare ? "Preparing Share Card..." : "Share Card", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .disabled(appModel.primaryResult == nil || isPreparingShare)
                .accessibilityIdentifier("share-card-button")

                Button {
                    Task { await appModel.refreshHistoricalData() }
                } label: {
                    Label(appModel.isRefreshing ? "Refreshing..." : "Refresh Data", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(appModel.isRefreshing)
                .accessibilityIdentifier("refresh-data-button")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                statPill(title: "Visible year", value: visibleYearLabel, accessibilityIdentifier: "visible-year-pill")
                statPill(title: "Saved", value: "\(appModel.savedScenarios.count)", accessibilityIdentifier: "saved-count-pill")
                statPill(title: "Compared", value: "\(appModel.comparisonScenarios.count + 1)", accessibilityIdentifier: "compared-count-pill")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Compare mode")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button("Clear") {
                    appModel.resetComparisons()
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            }

            ForEach(appModel.comparisonResults) { result in
                HStack(spacing: 12) {
                    Circle()
                        .fill(result.scenario.asset.tint)
                        .frame(width: 12, height: 12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(UIFormatting.scenarioDescriptor(result.scenario))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Text("Now \(result.currentValue.currencyText) · Return \(result.totalReturnRatio.percentText)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(role: .destructive) {
                        appModel.removeComparisonScenario(result.scenario.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.7))
                )
            }
        }
        .accessibilityIdentifier("comparison-section")
    }

    private func fallbackState(message: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message == nil ? "No result yet" : "Adjust the scenario")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(message ?? "Load the bundled data or refresh the cache to start exploring.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.68))
        )
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.94, blue: 0.88),
                Color(red: 0.92, green: 0.94, blue: 0.97),
                Color(red: 0.98, green: 0.97, blue: 0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var visibleYearLabel: String {
        guard appModel.animationYears.indices.contains(visibleYearIndex) else {
            return "Latest"
        }
        return "\(appModel.animationYears[visibleYearIndex])"
    }

    private func statPill(title: String, value: String, accessibilityIdentifier: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("\(accessibilityIdentifier)-title")
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .accessibilityIdentifier("\(accessibilityIdentifier)-value")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.74))
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func alignVisibleYearToLatest() {
        visibleYearIndex = max(0, appModel.animationYears.count - 1)
    }

    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
            return
        }

        guard !appModel.animationYears.isEmpty else { return }
        visibleYearIndex = 0
        isPlaying = true
        playbackTask = Task {
            while !Task.isCancelled && visibleYearIndex < appModel.animationYears.count {
                try? await Task.sleep(for: .milliseconds(700))
                guard !Task.isCancelled else { return }
                if visibleYearIndex < appModel.animationYears.count - 1 {
                    visibleYearIndex += 1
                } else {
                    isPlaying = false
                    return
                }
            }
        }
    }

    private func stopPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
        isPlaying = false
    }

    @MainActor
    private func prepareShareCard() async {
        guard let primaryResult = appModel.primaryResult else { return }

        isPreparingShare = true
        defer { isPreparingShare = false }

        do {
            shareExport = try ShareCardExporter().export(
                primaryResult: primaryResult,
                comparisons: appModel.comparisonResults,
                caption: appModel.shareSummary,
                lastUpdatedAt: appModel.lastUpdatedAt
            )
            appModel.lastErrorMessage = nil
        } catch {
            appModel.lastErrorMessage = error.localizedDescription
        }
    }
}

private struct ScenarioEditorCard: View {
    let title: String
    let subtitle: String
    @Binding var scenario: InvestmentScenario
    let assets: [AssetID]
    let availableDateRange: ClosedRange<Date>?
    let validationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Picker("Asset", selection: $scenario.asset) {
                ForEach(assets) { asset in
                    Text("\(asset.symbol) · \(asset.displayName)")
                        .tag(asset)
                }
            }
            .pickerStyle(.menu)

            if let availableDateRange {
                DatePicker("Start date", selection: $scenario.startDate, in: availableDateRange, displayedComponents: .date)
                    .datePickerStyle(.compact)
            } else {
                DatePicker("Start date", selection: $scenario.startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            Picker("Mode", selection: $scenario.mode) {
                ForEach(InvestmentMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text(scenario.mode.amountFieldLabel)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("Amount", value: amountBinding, format: .number.precision(.fractionLength(0...2)))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }

            if let validationMessage {
                Label(validationMessage, systemImage: "exclamationmark.circle")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.72, green: 0.21, blue: 0.18))
            }

            HStack(spacing: 10) {
                Label(scenario.asset.categoryLabel, systemImage: "chart.line.uptrend.xyaxis")
                Spacer()
                Text(UIFormatting.scenarioDescriptor(scenario))
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.84))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.black.opacity(0.06))
                )
        )
        .accessibilityIdentifier(title == "Story mode" ? "story-mode-card" : "comparison-editor-card")
    }

    private var amountBinding: Binding<Double> {
        Binding(
            get: { scenario.amount },
            set: { scenario.amount = max(0, $0) }
        )
    }
}

private struct ResultSummaryCard: View {
    let result: ScenarioResult

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("If you had started with \(result.scenario.asset.symbol)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(result.currentValue.currencyText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                Spacer()
                Circle()
                    .fill(result.scenario.asset.tint.gradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(result.scenario.asset.symbol.prefix(1))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    )
            }

            HStack(spacing: 16) {
                metricBlock(title: "Invested", value: result.investedAmount.currencyText)
                metricBlock(title: "Return", value: result.totalReturnRatio.percentText)
                metricBlock(title: "Span", value: UIFormatting.spanDescriptor(for: result))
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            result.scenario.asset.tint.opacity(0.18),
                            Color.white.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .accessibilityIdentifier("result-summary-card")
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TimelineChartCard: View {
    let results: [ScenarioResult]
    @Binding var visibleYearIndex: Int
    let allYears: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timeline replay")
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Chart {
                ForEach(results) { result in
                    let points = visiblePoints(for: result)
                    ForEach(points) { point in
                        LineMark(
                            x: .value("Year", point.year),
                            y: .value("Portfolio", point.portfolioValue)
                        )
                        .foregroundStyle(result.scenario.asset.tint)
                        .lineStyle(.init(lineWidth: result.scenario == results.first?.scenario ? 3.5 : 2.4))
                    }
                }
            }
            .frame(height: 240)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend(.hidden)

            if !allYears.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Visible through \(allYears[min(visibleYearIndex, allYears.count - 1)])")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Spacer()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(visibleYearIndex) },
                            set: { visibleYearIndex = Int($0.rounded()) }
                        ),
                        in: 0...Double(max(0, allYears.count - 1)),
                        step: 1
                    )
                }
            }

            FlowLayout(spacing: 10) {
                ForEach(results) { result in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(result.scenario.asset.tint)
                            .frame(width: 8, height: 8)
                        Text(result.scenario.asset.symbol)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.75)))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.84))
        )
    }

    private func visiblePoints(for result: ScenarioResult) -> [TimelinePoint] {
        guard !allYears.isEmpty else { return result.timeline }
        let upperYear = allYears[min(visibleYearIndex, allYears.count - 1)]
        return result.timeline.filter { $0.year <= upperYear }
    }
}

private struct ComparisonComposerView: View {
    @Binding var scenario: InvestmentScenario
    let assets: [AssetID]
    let availableDateRange: ClosedRange<Date>?
    let validationMessage: String?
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            ScenarioEditorCard(
                title: "New comparison",
                subtitle: "Keep it lightweight. Add one more line only after the first line already means something.",
                scenario: $scenario,
                assets: assets,
                availableDateRange: availableDateRange,
                validationMessage: validationMessage
            )
            .padding(20)
        }
        .background(Color(red: 0.95, green: 0.94, blue: 0.91))
        .navigationTitle("Add comparison")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .accessibilityIdentifier("comparison-cancel-button")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    onAdd()
                }
                .fontWeight(.semibold)
                .disabled(validationMessage != nil)
                .accessibilityIdentifier("comparison-add-button")
            }
        }
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .vertical) {
            HStack(spacing: spacing) {
                content
            }
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
    }
}
