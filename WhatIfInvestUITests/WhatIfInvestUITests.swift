import XCTest

final class WhatIfInvestUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testStoryModeCanCompareAndSave() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_RESET_DATA"]
        app.launch()

        XCTAssertTrue(app.navigationBars["What If Invest"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Story mode"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Timeline replay"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Add Comparison"].waitForExistence(timeout: 10))

        app.buttons["Add Comparison"].tap()
        XCTAssertTrue(app.navigationBars["Add comparison"].waitForExistence(timeout: 3))
        app.navigationBars["Add comparison"].buttons["Add"].tap()

        XCTAssertTrue(app.staticTexts["Compare mode"].waitForExistence(timeout: 5))

        let moreActionsButton = app.buttons["More"].firstMatch
        XCTAssertTrue(moreActionsButton.waitForExistence(timeout: 5))
        moreActionsButton.tap()

        let saveButton = app.buttons["Save Scenario"].firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let statusSummary = app.descendants(matching: .any)["status-summary"].firstMatch
        XCTAssertTrue(statusSummary.waitForExistence(timeout: 5))

        let savedPredicate = NSPredicate(format: "label CONTAINS[c] %@", "1 saved")
        expectation(for: savedPredicate, evaluatedWith: statusSummary)
        waitForExpectations(timeout: 5)
    }

    @MainActor
    func testSavedScenarioCanOpenFromLibrary() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_RESET_DATA", "UITEST_SEED_LIBRARY", "UITEST_START_ON_SAVED"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Saved"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Open in Explore"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["Open in Explore"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Timeline replay"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testKoreanLocalizationShowsCoreLabels() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "UITEST_RESET_DATA",
            "-AppleLanguages", "(ko)",
            "-AppleLocale", "ko_KR"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["그때 투자했다면"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["스토리 모드"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["비교 추가"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["이 결과 읽는 법"].waitForExistence(timeout: 10))
    }
}
