import Observation
import SwiftUI

struct ExploreView: View {
    @Environment(AppModel.self) private var appModel

    @State private var comparisonDraft = InvestmentScenario.suggestedComparison(after: .starter, excluding: [])
    @State private var showingComparisonSheet = false
    @State private var shareExport: ShareExportItem?
    @State private var visibleYearIndex = 0
    @State private var visibleWindow = TimelineVisibleWindow.oneYear
    @State private var isPlaying = false
    @State private var isPreparingShare = false
    @State private var showingTimelineDetail = false
    @State private var playbackTask: Task<Void, Never>?

    var body: some View {
        @Bindable var appModel = appModel

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader

                ScenarioEditorCard(
                    title: L10n.storyModeTitle,
                    subtitle: L10n.storyModeSubtitle,
                    scenario: $appModel.primaryScenario,
                    assets: appModel.availableAssets,
                    availableDateRange: appModel.availableDateRange(for: appModel.primaryScenario.asset),
                    validationMessage: appModel.validationMessage(for: appModel.primaryScenario),
                    accessibilityIdentifier: "story-mode-card"
                )

                if let primaryResult = appModel.primaryResult {
                    ResultSummaryCard(result: primaryResult)

                    TimelineChartCard(
                        series: timelineSeriesDescriptors,
                        visibleYearIndex: $visibleYearIndex,
                        visibleWindow: $visibleWindow,
                        allYears: appModel.animationYears,
                        onOpenDetail: openTimelineDetail
                    )

                    controlRow

                    if !appModel.comparisonScenarios.isEmpty {
                        comparisonSection
                    }
                } else if appModel.isLoading {
                    ProgressView(L10n.loadingHistoricalData)
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
        .tint(AppTheme.ColorToken.brandPrimary)
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
        .fullScreenCover(isPresented: $showingTimelineDetail) {
            TimelineDetailSheet(
                series: timelineSeriesDescriptors,
                visibleWindow: $visibleWindow
            )
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
            Text(L10n.exploreHeroEyebrow)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.brandPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppTheme.ColorToken.surfaceSubtle)
                )

            Text(L10n.exploreHeroTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)

            Text(L10n.exploreHeroSubtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)

            if let message = appModel.lastErrorMessage {
                Label(message, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.danger)
            }
        }
    }

    private var controlRow: some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .vertical) {
                HStack(spacing: 12) {
                    replayButton
                        .frame(maxWidth: .infinity)
                    comparisonButton
                }

                VStack(alignment: .leading, spacing: 10) {
                    replayButton
                        .frame(maxWidth: .infinity)
                    comparisonButton
                }
            }

            ViewThatFits(in: .vertical) {
                HStack(alignment: .center, spacing: 12) {
                    statusSummary

                    Spacer(minLength: 0)

                    utilityActions
                }

                VStack(alignment: .leading, spacing: 10) {
                    statusSummary
                    utilityActions
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.compareModeTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button(L10n.clearComparisons, role: .destructive) {
                    appModel.resetComparisons()
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .buttonStyle(.bordered)
            }

            ForEach(comparisonSeriesDescriptors) { descriptor in
                HStack(alignment: .top, spacing: 12) {
                    comparisonMarker(for: descriptor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(descriptor.primaryText)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(descriptor.secondaryText)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.ColorToken.textSecondary)
                            .monospacedDigit()
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Button(L10n.remove, role: .destructive) {
                        appModel.removeComparisonScenario(descriptor.result.scenario.id)
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(14)
                .appCardSurface(
                    fill: AppTheme.ColorToken.surfaceMuted.opacity(0.95),
                    radius: 18
                )
            }
        }
        .padding(18)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.88),
            radius: 24
        )
        .accessibilityIdentifier("comparison-section")
    }

    private func fallbackState(message: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message == nil ? L10n.noResultYet : L10n.adjustScenario)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(message ?? L10n.noResultBody)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.84),
            radius: 26
        )
    }

    private var backgroundGradient: some View {
        AppTheme.canvasGradient
            .ignoresSafeArea()
    }

    private var timelineSeriesDescriptors: [ChartSeriesDescriptor] {
        ChartSeriesDescriptor.make(from: appModel.visibleResults(barInterval: visibleWindow.barInterval))
    }

    private var comparisonSeriesDescriptors: [ChartSeriesDescriptor] {
        Array(ChartSeriesDescriptor.make(from: appModel.visibleResults).dropFirst())
    }

    private var visibleWindowLabel: String {
        visibleWindow.title
    }

    private var replayButton: some View {
        Button(isPlaying ? L10n.stopReplay : L10n.runReplay) {
            togglePlayback()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.ColorToken.brandPrimary)
        .controlSize(.large)
        .accessibilityIdentifier("timeline-playback-button")
    }

    private var comparisonButton: some View {
        Button(L10n.addComparison) {
            comparisonDraft = appModel.nextComparisonDraft()
            showingComparisonSheet = true
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(appModel.primaryResult == nil)
        .accessibilityIdentifier("add-comparison-button")
    }

    private var statusSummary: some View {
        Label(statusSummaryText, systemImage: "clock.arrow.circlepath")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textSecondary)
            .monospacedDigit()
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("status-summary")
    }

    private var utilityActions: some View {
        HStack(spacing: 10) {
            Button {
                Task { await prepareShareCard() }
            } label: {
                Label(isPreparingShare ? L10n.preparing : L10n.share, systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(appModel.primaryResult == nil || isPreparingShare)
            .accessibilityIdentifier("share-card-button")

            Menu {
                Button {
                    appModel.savePrimaryScenario()
                } label: {
                    Label(L10n.saveScenario, systemImage: "bookmark")
                }
                .disabled(appModel.primaryResult == nil)

                Button {
                    Task { await appModel.refreshHistoricalData() }
                } label: {
                    Label(appModel.isRefreshing ? L10n.refreshingData : L10n.refreshData, systemImage: "arrow.clockwise")
                }
                .disabled(appModel.isRefreshing)
            } label: {
                Label(L10n.more, systemImage: "ellipsis.circle")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityIdentifier("more-actions-button")
        }
    }

    private var statusSummaryText: String {
        L10n.statusSummary(
            window: visibleWindowLabel,
            scenarioCount: appModel.comparisonScenarios.count + 1,
            savedCount: appModel.savedScenarios.count
        )
    }

    private func comparisonMarker(for descriptor: ChartSeriesDescriptor) -> some View {
        Image(systemName: descriptor.symbol.systemImageName)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(descriptor.color)
            .frame(width: 26, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(descriptor.color.opacity(0.12))
            )
    }

    private func alignVisibleYearToLatest() {
        visibleYearIndex = max(0, appModel.animationYears.count - 1)
    }

    private func openTimelineDetail() {
        stopPlayback()
        showingTimelineDetail = true
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
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
            }

            Picker(L10n.assetFieldTitle, selection: $scenario.asset) {
                ForEach(assets) { asset in
                    Text("\(asset.symbol) · \(asset.displayName)")
                        .tag(asset)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("\(accessibilityIdentifier)-asset-picker")

            if let availableDateRange {
                DatePicker(L10n.startDateFieldTitle, selection: $scenario.startDate, in: availableDateRange, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("\(accessibilityIdentifier)-start-date-picker")
            } else {
                DatePicker(L10n.startDateFieldTitle, selection: $scenario.startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("\(accessibilityIdentifier)-start-date-picker")
            }

            Picker(L10n.modeFieldTitle, selection: $scenario.mode) {
                ForEach(InvestmentMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("\(accessibilityIdentifier)-mode-picker")

            VStack(alignment: .leading, spacing: 8) {
                Text(scenario.mode.amountFieldLabel)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                TextField(L10n.amountPlaceholder, value: amountBinding, format: .number.precision(.fractionLength(0...2)))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("\(accessibilityIdentifier)-amount-field")
            }

            if let validationMessage {
                Label(validationMessage, systemImage: "exclamationmark.circle")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.danger)
            }

            HStack(spacing: 10) {
                Label(scenario.asset.categoryLabel, systemImage: "chart.line.uptrend.xyaxis")
                Spacer()
                Text(UIFormatting.scenarioDescriptor(scenario))
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.ColorToken.textSecondary)
        }
        .padding(20)
        .appCardSurface(
            fill: AppTheme.ColorToken.surfaceBase.opacity(0.92),
            radius: AppTheme.Radius.lg
        )
        .accessibilityIdentifier(accessibilityIdentifier)
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
                    Text(L10n.startedWithAsset(result.scenario.asset.symbol))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    Text(result.currentValue.currencyText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
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
                metricBlock(title: L10n.investedTitle, value: result.investedAmount.currencyText)
                metricBlock(title: L10n.returnTitle, value: result.totalReturnRatio.percentText)
                metricBlock(title: L10n.spanTitle, value: UIFormatting.spanDescriptor(for: result))
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.ColorToken.surfaceBase.opacity(0.98),
                            AppTheme.ColorToken.surfaceSubtle.opacity(0.92),
                            result.scenario.asset.tint.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(AppTheme.ColorToken.borderSoft)
                )
        )
        .accessibilityIdentifier("result-summary-card")
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                title: L10n.newComparisonTitle,
                subtitle: L10n.newComparisonSubtitle,
                scenario: $scenario,
                assets: assets,
                availableDateRange: availableDateRange,
                validationMessage: validationMessage,
                accessibilityIdentifier: "comparison-editor-card"
            )
            .padding(20)
        }
        .background(AppTheme.canvasGradient)
        .navigationTitle(L10n.addComparisonTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.cancel) {
                    dismiss()
                }
                .accessibilityIdentifier("comparison-cancel-button")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.add) {
                    onAdd()
                }
                .fontWeight(.semibold)
                .disabled(validationMessage != nil)
                .accessibilityIdentifier("comparison-add-button")
            }
        }
    }
}
