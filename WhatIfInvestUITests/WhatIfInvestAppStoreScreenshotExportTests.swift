import XCTest

@MainActor
final class WhatIfInvestAppStoreScreenshotExportTests: XCTestCase {
    func testCaptureRawScreenshots() throws {
        let outputRoot = Self.repositoryRootURL()
            .appendingPathComponent("app-store/screenshots/raw", isDirectory: true)

        if FileManager.default.fileExists(atPath: outputRoot.path) {
            try FileManager.default.removeItem(at: outputRoot)
        }

        try captureLocale(
            identifier: "en-US",
            languageArgument: "(en)",
            localeArgument: "en_US",
            addComparisonTitle: "Add comparison",
            addButtonTitle: "Add",
            saveScenarioTitle: "Save Scenario",
            savedTabTitle: "Saved",
            openInExploreTitle: "Open in Explore",
            outputRoot: outputRoot
        )

        try captureLocale(
            identifier: "ko-KR",
            languageArgument: "(ko)",
            localeArgument: "ko_KR",
            addComparisonTitle: "비교 추가",
            addButtonTitle: "추가",
            saveScenarioTitle: "시나리오 저장",
            savedTabTitle: "보관함",
            openInExploreTitle: "둘러보기로 열기",
            outputRoot: outputRoot
        )
    }

    private func captureLocale(
        identifier: String,
        languageArgument: String,
        localeArgument: String,
        addComparisonTitle: String,
        addButtonTitle: String,
        saveScenarioTitle: String,
        savedTabTitle: String,
        openInExploreTitle: String,
        outputRoot: URL
    ) throws {
        let outputDirectory = outputRoot
            .appendingPathComponent(identifier, isDirectory: true)
            .appendingPathComponent("iphone69", isDirectory: true)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let app = XCUIApplication()
        app.launchArguments = [
            "UITEST_RESET_DATA",
            "-AppleLanguages", languageArgument,
            "-AppleLocale", localeArgument
        ]
        app.launch()

        XCTAssertTrue(app.navigationBars["What If Invest"].waitForExistence(timeout: 12))
        XCTAssertTrue(app.buttons["add-comparison-button"].waitForExistence(timeout: 12))

        try saveScreenshot(named: "01-first-result", app: app, outputDirectory: outputDirectory)

        app.swipeUp()
        XCTAssertTrue(app.staticTexts.matching(identifier: "Timeline replay").firstMatch.waitForExistence(timeout: 3) || app.buttons["timeline-playback-button"].waitForExistence(timeout: 3))
        try saveScreenshot(named: "02-timeline-replay", app: app, outputDirectory: outputDirectory)

        let addComparisonButton = app.buttons["add-comparison-button"]
        if !addComparisonButton.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(addComparisonButton.waitForExistence(timeout: 5))
        addComparisonButton.tap()

        XCTAssertTrue(app.navigationBars[addComparisonTitle].waitForExistence(timeout: 5))
        try saveScreenshot(named: "03-add-comparison", app: app, outputDirectory: outputDirectory)

        app.navigationBars[addComparisonTitle].buttons[addButtonTitle].tap()
        XCTAssertTrue(app.otherElements["comparison-section"].waitForExistence(timeout: 8))
        try saveScreenshot(named: "04-compare-mode", app: app, outputDirectory: outputDirectory)

        let moreActionsButton = app.buttons["more-actions-button"].firstMatch
        XCTAssertTrue(moreActionsButton.waitForExistence(timeout: 5))
        moreActionsButton.tap()
        XCTAssertTrue(app.buttons[saveScenarioTitle].waitForExistence(timeout: 5))
        app.buttons[saveScenarioTitle].tap()

        let savedTab = app.tabBars.buttons[savedTabTitle]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 5))
        savedTab.tap()

        let openSavedScenarioButton = app.buttons[openInExploreTitle].firstMatch
        let identifiedOpenButton = app.buttons["saved-scenario-open-button"].firstMatch
        XCTAssertTrue(
            openSavedScenarioButton.waitForExistence(timeout: 8)
                || identifiedOpenButton.waitForExistence(timeout: 1)
        )
        try saveScreenshot(named: "05-saved-scenarios", app: app, outputDirectory: outputDirectory)

        app.terminate()
    }

    private func saveScreenshot(named name: String, app: XCUIApplication, outputDirectory: URL) throws {
        RunLoop.current.run(until: Date().addingTimeInterval(0.4))
        let screenshot = XCUIScreen.main.screenshot()
        let destination = outputDirectory.appendingPathComponent("\(name).png")
        try screenshot.pngRepresentation.write(to: destination, options: .atomic)
    }

    private static func repositoryRootURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
