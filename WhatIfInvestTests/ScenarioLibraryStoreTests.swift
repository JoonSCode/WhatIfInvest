import XCTest
@testable import WhatIfInvest

final class ScenarioLibraryStoreTests: XCTestCase {
    func testLoadEntriesFallsBackToLegacyStoreWhenCurrentFileIsMissing() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }

        let currentURL = directory.appending(path: "current-saved_scenarios.json")
        let legacyURL = directory.appending(path: "legacy-saved_scenarios.json")
        let savedScenario = SavedScenario(
            scenario: InvestmentScenario(
                asset: .spy,
                startDate: Calendar.utc.date(from: DateComponents(year: 2018, month: 1, day: 1))!,
                mode: .lumpSum,
                amount: 1_000
            ),
            savedAt: .now
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode([savedScenario])
        try FileManager.default.createDirectory(at: legacyURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: legacyURL, options: [.atomic])

        let store = ScenarioLibraryStore(
            fileURLOverride: currentURL,
            legacyFileURLOverride: legacyURL
        )

        let loaded = try store.loadEntries()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.scenario.storageKey, savedScenario.scenario.storageKey)
    }

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
