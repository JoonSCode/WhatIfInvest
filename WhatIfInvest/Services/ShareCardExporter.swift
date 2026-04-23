import SwiftUI
import UIKit

struct ShareExportItem: Identifiable {
    let id = UUID()
    let fileURL: URL
    let caption: String
}

enum ShareCardExportError: LocalizedError {
    case imageRenderFailed

    var errorDescription: String? {
        switch self {
        case .imageRenderFailed:
            return L10n.errorShareRenderFailed
        }
    }
}

@MainActor
struct ShareCardExporter {
    func export(
        primaryResult: ScenarioResult,
        comparisons: [ScenarioResult],
        caption: String,
        lastUpdatedAt: Date?
    ) throws -> ShareExportItem {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory.appending(path: AppBrand.shareCardDirectoryName, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appending(path: "share-card-\(UUID().uuidString).png")
        let card = ShareCardView(
            primaryResult: primaryResult,
            comparisons: comparisons,
            lastUpdatedAt: lastUpdatedAt
        )
        .frame(width: 1080, height: 1350)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 3

        guard let image = renderer.uiImage, let data = image.pngData() else {
            throw ShareCardExportError.imageRenderFailed
        }

        try data.write(to: fileURL, options: [.atomic])
        return ShareExportItem(fileURL: fileURL, caption: caption)
    }
}
