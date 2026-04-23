import Foundation

struct ScenarioLibraryStore {
    private let fileManager: FileManager
    private let fileURLOverride: URL?
    private let legacyFileURLOverride: URL?

    init(fileManager: FileManager = .default, fileURLOverride: URL? = nil, legacyFileURLOverride: URL? = nil) {
        self.fileManager = fileManager
        self.fileURLOverride = fileURLOverride
        self.legacyFileURLOverride = legacyFileURLOverride
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
        var mostRecentError: Error?

        for url in try fileURLs() {
            guard fileManager.fileExists(atPath: url.path) else { continue }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([SavedScenario].self, from: data)
                    .sorted { $0.savedAt > $1.savedAt }
            } catch {
                mostRecentError = error
            }
        }

        if let mostRecentError {
            throw mostRecentError
        }

        return []
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
        let url = try currentFileURL()
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: [.atomic])
    }

    private func currentFileURL() throws -> URL {
        if let fileURLOverride {
            return fileURLOverride
        }

        return try Self.currentFileURL(fileManager: fileManager)
    }

    private func fileURLs() throws -> [URL] {
        if let fileURLOverride {
            if let legacyFileURLOverride {
                return [fileURLOverride, legacyFileURLOverride]
            }
            return [fileURLOverride]
        }

        return try Self.defaultFileURLs(fileManager: fileManager)
    }

    static func clearPersistedData(fileManager: FileManager = .default) throws {
        for url in try defaultFileURLs(fileManager: fileManager) where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    private static func defaultFileURLs(fileManager: FileManager) throws -> [URL] {
        [
            try currentFileURL(fileManager: fileManager),
            try legacyFileURL(fileManager: fileManager)
        ]
    }

    private static func currentFileURL(fileManager: FileManager) throws -> URL {
        try applicationSupportDirectory(fileManager: fileManager)
            .appending(path: AppBrand.internalName, directoryHint: .isDirectory)
            .appending(path: "saved_scenarios.json")
    }

    private static func legacyFileURL(fileManager: FileManager) throws -> URL {
        try applicationSupportDirectory(fileManager: fileManager)
            .appending(path: AppBrand.legacyInternalName, directoryHint: .isDirectory)
            .appending(path: "saved_scenarios.json")
    }

    private static func applicationSupportDirectory(fileManager: FileManager) throws -> URL {
        try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
}
