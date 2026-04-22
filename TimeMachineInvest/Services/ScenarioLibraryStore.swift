import Foundation

struct ScenarioLibraryStore {
    func load() -> [SavedScenario] {
        do {
            let url = try fileURL()
            guard FileManager.default.fileExists(atPath: url.path()) else { return [] }
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([SavedScenario].self, from: data)
                .sorted { $0.savedAt > $1.savedAt }
        } catch {
            return []
        }
    }

    func save(_ scenario: SavedScenario) {
        var current = load()
        current.insert(scenario, at: 0)
        persist(current)
    }

    func remove(_ scenario: SavedScenario) {
        let current = load().filter { $0.id != scenario.id }
        persist(current)
    }

    private func persist(_ scenarios: [SavedScenario]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(scenarios)
            let url = try fileURL()
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: [.atomic])
        } catch {
            assertionFailure("Failed to persist saved scenarios: \(error)")
        }
    }

    private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(path: "TimeMachineInvest", directoryHint: .isDirectory)
        .appending(path: "saved_scenarios.json")
    }
}

