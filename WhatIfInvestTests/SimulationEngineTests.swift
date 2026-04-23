import XCTest
@testable import WhatIfInvest

final class SimulationEngineTests: XCTestCase {
    private let engine = SimulationEngine()

    func testLumpSumSimulationProducesExpectedSummaryAndSnapshots() {
        let history = makeHistory()
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2020, month: 1, day: 1),
            mode: .lumpSum,
            amount: 1_200
        )

        guard let result = engine.simulate(scenario: scenario, history: history) else {
            return XCTFail("Expected a valid lump-sum result")
        }

        XCTAssertEqual(result.investedAmount, 1_200, accuracy: 0.001)
        XCTAssertEqual(result.currentValue, 2_880, accuracy: 0.001)
        XCTAssertEqual(result.totalReturnRatio, 1.4, accuracy: 0.0001)
        XCTAssertEqual(result.timeline.map(\.year), [2020, 2020, 2021])
        XCTAssertEqual(result.timeline.last?.portfolioValue ?? 0, 2_880, accuracy: 0.001)
    }

    func testRecurringSimulationAccumulatesAcrossEachPoint() {
        let history = makeHistory()
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2020, month: 1, day: 1),
            mode: .recurringMonthly,
            amount: 100
        )

        guard let result = engine.simulate(scenario: scenario, history: history) else {
            return XCTFail("Expected a valid recurring result")
        }

        XCTAssertEqual(result.investedAmount, 400, accuracy: 0.001)
        XCTAssertEqual(result.currentValue, 673.3333, accuracy: 0.001)
        XCTAssertEqual(result.totalReturnRatio, 0.6833333, accuracy: 0.0001)
        XCTAssertEqual(result.timeline.count, 3)
        XCTAssertEqual(result.timeline[1].investedAmount, 300, accuracy: 0.001)
    }

    func testNonPositiveAmountReturnsNil() {
        let history = makeHistory()
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2020, month: 1, day: 1),
            mode: .lumpSum,
            amount: 0
        )

        XCTAssertNil(engine.simulate(scenario: scenario, history: history))
    }

    func testStartDateAfterHistoryReturnsNil() {
        let history = makeHistory()
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2024, month: 1, day: 1),
            mode: .lumpSum,
            amount: 100
        )

        XCTAssertNil(engine.simulate(scenario: scenario, history: history))
    }

    private func makeHistory() -> AssetHistory {
        AssetHistory(
            asset: .voo,
            symbol: "VOO",
            displayName: "Vanguard S&P 500 ETF",
            categoryLabel: "Major ETF",
            monthlyPoints: [
                MarketPoint(date: Self.date(year: 2020, month: 1, day: 1), adjustedClose: 100),
                MarketPoint(date: Self.date(year: 2020, month: 2, day: 1), adjustedClose: 120),
                MarketPoint(date: Self.date(year: 2020, month: 12, day: 1), adjustedClose: 180),
                MarketPoint(date: Self.date(year: 2021, month: 1, day: 1), adjustedClose: 240)
            ]
        )
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.utc.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
