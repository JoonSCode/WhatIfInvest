import XCTest
@testable import WhatIfInvest

@MainActor
final class ShareCardExporterTests: XCTestCase {
    func testExportCreatesPNGFile() throws {
        let exporter = ShareCardExporter()
        let primary = ScenarioResult(
            scenario: InvestmentScenario(
                asset: .voo,
                startDate: Calendar.utc.date(from: DateComponents(year: 2018, month: 1, day: 1))!,
                mode: .lumpSum,
                amount: 10_000
            ),
            investedAmount: 10_000,
            currentValue: 24_500,
            totalReturnRatio: 1.45,
            timeline: [
                TimelinePoint(
                    date: Calendar.utc.date(from: DateComponents(year: 2018, month: 1, day: 1))!,
                    year: 2018,
                    investedAmount: 10_000,
                    portfolioValue: 10_000
                ),
                TimelinePoint(
                    date: Calendar.utc.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
                    year: 2024,
                    investedAmount: 10_000,
                    portfolioValue: 24_500
                )
            ]
        )

        let export = try exporter.export(
            primaryResult: primary,
            comparisons: [],
            caption: "Test share",
            lastUpdatedAt: .now
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: export.fileURL.path))
        XCTAssertEqual(export.fileURL.pathExtension.lowercased(), "png")
        try? FileManager.default.removeItem(at: export.fileURL)
    }
}
