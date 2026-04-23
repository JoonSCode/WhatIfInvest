import Foundation
import Observation

enum AppTab: Hashable {
    case explore
    case library
}

@MainActor
@Observable
final class AppModel {
    private let historicalStore = HistoricalDataStore()
    private let libraryStore = ScenarioLibraryStore()
    private let simulationEngine = SimulationEngine()

    var selectedTab: AppTab = .explore
    var primaryScenario: InvestmentScenario = .starter
    var comparisonScenarios: [InvestmentScenario] = []
    var historicalPayload: BundledHistoricalData?
    var savedScenarios: [SavedScenario] = []
    var isLoading = false
    var isRefreshing = false
    var lastErrorMessage: String?

    private var didLoad = false

    var assetHistories: [AssetID: AssetHistory] {
        Dictionary(uniqueKeysWithValues: (historicalPayload?.histories ?? []).map { ($0.asset, $0) })
    }

    var availableAssets: [AssetID] {
        AssetID.allCases
    }

    var providerLabel: String {
        historicalPayload?.provider ?? "Bundled data"
    }

    var lastUpdatedAt: Date? {
        historicalPayload?.generatedAt
    }

    var primaryResult: ScenarioResult? {
        simulate(primaryScenario)
    }

    var comparisonResults: [ScenarioResult] {
        comparisonScenarios.compactMap(simulate)
    }

    var visibleResults: [ScenarioResult] {
        [primaryResult].compactMap { $0 } + comparisonResults
    }

    var animationYears: [Int] {
        let years = visibleResults.flatMap { $0.timeline.map(\.year) }
        return Array(Set(years)).sorted()
    }

    var shareSummary: String {
        let primaryLine = primaryResult.map { result in
            let growth = (result.totalReturnRatio * 100).formatted(.number.precision(.fractionLength(1)))
            return "\(result.scenario.asset.symbol): \(result.currentValue.currencyText) now from \(result.scenario.amount.currencyText) \(result.scenario.mode.inlineLabel), return \(growth)%."
        } ?? "Scenario pending."

        let comparisons = comparisonResults.map { result in
            "\(result.scenario.asset.symbol) -> \(result.currentValue.currencyText)"
        }

        let comparisonBlock = comparisons.isEmpty ? "" : "\nComparisons: " + comparisons.joined(separator: ", ")

        return """
        \(AppBrand.displayName)
        \(primaryLine)\(comparisonBlock)
        Basis: adjusted close, taxes/fees/inflation excluded.
        """
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        savedScenarios = libraryStore.load()
        await loadHistoricalData()
    }

    func refreshHistoricalData() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            historicalPayload = try await historicalStore.refreshAllData()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func savePrimaryScenario() {
        do {
            try libraryStore.saveEntry(
                SavedScenario(
                    scenario: primaryScenario,
                    savedAt: .now
                )
            )
            savedScenarios = libraryStore.load()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func removeSavedScenario(_ entry: SavedScenario) {
        do {
            try libraryStore.removeEntry(entry)
            savedScenarios = libraryStore.load()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func loadSavedScenario(_ entry: SavedScenario) {
        primaryScenario = entry.scenario
        comparisonScenarios = []
        selectedTab = .explore
    }

    func addComparisonScenario(_ scenario: InvestmentScenario) {
        guard scenario.storageKey != primaryScenario.storageKey else { return }
        guard !comparisonScenarios.contains(where: { $0.storageKey == scenario.storageKey }) else { return }
        comparisonScenarios.append(scenario)
    }

    func removeComparisonScenario(_ scenarioID: UUID) {
        comparisonScenarios.removeAll { $0.id == scenarioID }
    }

    func resetComparisons() {
        comparisonScenarios = []
    }

    func nextComparisonDraft() -> InvestmentScenario {
        InvestmentScenario.suggestedComparison(
            after: primaryScenario,
            excluding: comparisonScenarios.map(\.asset)
        )
    }

    func availableDateRange(for asset: AssetID) -> ClosedRange<Date>? {
        guard
            let points = assetHistories[asset]?.monthlyPoints.sorted(by: { $0.date < $1.date }),
            let first = points.first?.date,
            let last = points.last?.date
        else {
            return nil
        }

        return Calendar.utc.startOfDay(for: first)...Calendar.utc.startOfDay(for: last)
    }

    func validationMessage(for scenario: InvestmentScenario) -> String? {
        guard scenario.amount > 0 else {
            return "Enter an amount above $0 to generate a meaningful result."
        }

        guard let range = availableDateRange(for: scenario.asset) else {
            return nil
        }

        let normalizedDate = scenario.normalizedStartDate
        guard range.contains(normalizedDate) else {
            let start = range.lowerBound.formatted(.dateTime.year().month().day())
            let end = range.upperBound.formatted(.dateTime.year().month().day())
            return "\(scenario.asset.symbol) history currently runs from \(start) through \(end)."
        }

        return nil
    }

    private func loadHistoricalData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            historicalPayload = try await historicalStore.loadHistoricalData()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func simulate(_ scenario: InvestmentScenario) -> ScenarioResult? {
        guard let history = assetHistories[scenario.asset] else { return nil }
        return simulationEngine.simulate(scenario: scenario, history: history)
    }
}
