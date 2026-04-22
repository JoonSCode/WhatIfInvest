import XCTest
@testable import TimeMachineInvest

final class ScenarioLibraryStoreTests: XCTestCase {
    func testSaveDeduplicatesEquivalentScenarioAndKeepsNewestTimestamp() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = ScenarioLibraryStore(fileURLOverride: directory.appending(path: "saved_scenarios.json"))
        let scenario = InvestmentScenario(
            asset: .qqq,
            startDate: Calendar.utc.date(from: DateComponents(year: 2021, month: 6, day: 1))!,
            mode: .recurringMonthly,
            amount: 250
        )

        try store.saveEntry(SavedScenario(scenario: scenario, savedAt: .distantPast))
        try store.saveEntry(SavedScenario(scenario: scenario, savedAt: .now))

        let loaded = try store.loadEntries()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.scenario.storageKey, scenario.storageKey)
        XCTAssertGreaterThan(loaded.first?.savedAt ?? .distantPast, .distantPast)
    }

    func testRemoveDeletesSavedScenario() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = ScenarioLibraryStore(fileURLOverride: directory.appending(path: "saved_scenarios.json"))
        let scenario = InvestmentScenario(
            asset: .msft,
            startDate: Calendar.utc.date(from: DateComponents(year: 2019, month: 1, day: 1))!,
            mode: .lumpSum,
            amount: 5_000
        )
        let savedScenario = SavedScenario(scenario: scenario, savedAt: .now)

        try store.saveEntry(savedScenario)
        try store.removeEntry(savedScenario)

        XCTAssertTrue(try store.loadEntries().isEmpty)
    }
}
