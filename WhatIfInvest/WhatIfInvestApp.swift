import SwiftUI

@main
struct WhatIfInvestApp: App {
    @State private var appModel: AppModel

    @MainActor
    init() {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("UITEST_RESET_DATA") {
            try? HistoricalDataStore.clearPersistedData()
            try? ScenarioLibraryStore.clearPersistedData()
        }

        if arguments.contains("UITEST_SEED_LIBRARY") {
            try? ScenarioLibraryStore().saveEntry(
                SavedScenario(
                    scenario: .starter,
                    savedAt: .now
                )
            )
        }

        let model = AppModel()
        if arguments.contains("UITEST_START_ON_SAVED") {
            model.selectedTab = .library
        }
        if arguments.contains("UITEST_SEED_SAME_ASSET_COMPARISON") {
            model.primaryScenario = .starter
            model.comparisonScenarios = [
                InvestmentScenario(
                    asset: .voo,
                    startDate: Calendar.utc.date(from: DateComponents(year: 2016, month: 1, day: 1)) ?? .now,
                    mode: .recurringMonthly,
                    amount: 500
                )
            ]
        }
        _appModel = State(initialValue: model)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
        }
    }
}
