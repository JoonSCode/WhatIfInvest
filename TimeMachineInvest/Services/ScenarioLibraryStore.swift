import Foundation

struct ScenarioLibraryStore {
    private let fileManager: FileManager
    private let fileURLOverride: URL?

    init(fileManager: FileManager = .default, fileURLOverride: URL? = nil) {
        self.fileManager = fileManager
        self.fileURLOverride = fileURLOverride
    }

    func load() -> [SavedScenario] {
        (try? loadEntries()) ?? []
    }

    func save(_ scenario: SavedScenario) {
        do {
            try saveEntry(scenario)
        } catch {
            assertionFailure("Failed to save scenario: \(error)")
        }
    }

    func remove(_ scenario: SavedScenario) {
        do {
            try removeEntry(scenario)
        } catch {
            assertionFailure("Failed to remove scenario: \(error)")
        }
    }

    func loadEntries() throws -> [SavedScenario] {
        let url = try fileURL()
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([SavedScenario].self, from: data)
            .sorted { $0.savedAt > $1.savedAt }
    }

    func saveEntry(_ scenario: SavedScenario) throws {
        var current = try loadEntries()
        current.removeAll { $0.scenario.storageKey == scenario.scenario.storageKey }
        current.insert(scenario, at: 0)
        try persist(current)
    }

    func removeEntry(_ scenario: SavedScenario) throws {
        let current = try loadEntries().filter { $0.id != scenario.id }
        try persist(current)
    }

    private func persist(_ scenarios: [SavedScenario]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(scenarios)
        let url = try fileURL()
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: [.atomic])
    }

    private func fileURL() throws -> URL {
        if let fileURLOverride {
            return fileURLOverride
        }

        return try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(path: "TimeMachineInvest", directoryHint: .isDirectory)
        .appending(path: "saved_scenarios.json")
    }
}
