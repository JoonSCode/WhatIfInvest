import XCTest
@testable import WhatIfInvest

final class SimulationEngineTests: XCTestCase {
    private let engine = SimulationEngine()

    func testLumpSumSimulationProducesExpectedSummaryAndMonthlyTimeline() {
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
        XCTAssertEqual(result.timeline.map(\.year), [2020, 2020, 2020, 2021])
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
        XCTAssertEqual(result.timeline.count, 4)
        XCTAssertEqual(result.timeline[1].investedAmount, 200, accuracy: 0.001)
        XCTAssertEqual(result.timeline[2].investedAmount, 300, accuracy: 0.001)
    }

    func testRecurringSimulationUsesRecentPointsWithoutExtraMonthlyContributions() {
        let history = AssetHistory(
            asset: .voo,
            symbol: "VOO",
            displayName: "Vanguard S&P 500 ETF",
            categoryLabel: "Major ETF",
            monthlyPoints: [
                MarketPoint(date: Self.date(year: 2020, month: 1, day: 1), adjustedClose: 100),
                MarketPoint(date: Self.date(year: 2020, month: 2, day: 1), adjustedClose: 120)
            ],
            recentPoints: [
                MarketPoint(date: Self.date(year: 2020, month: 1, day: 8), adjustedClose: 110),
                MarketPoint(date: Self.date(year: 2020, month: 1, day: 15), adjustedClose: 130),
                MarketPoint(date: Self.date(year: 2020, month: 2, day: 8), adjustedClose: 140)
            ]
        )
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2020, month: 1, day: 1),
            mode: .recurringMonthly,
            amount: 100
        )

        guard let result = engine.simulate(scenario: scenario, history: history) else {
            return XCTFail("Expected a valid recurring result")
        }

        XCTAssertEqual(result.timeline.count, 5)
        XCTAssertEqual(result.timeline[0].investedAmount, 100, accuracy: 0.001)
        XCTAssertEqual(result.timeline[1].investedAmount, 100, accuracy: 0.001)
        XCTAssertEqual(result.timeline[2].investedAmount, 100, accuracy: 0.001)
        XCTAssertEqual(result.timeline[3].investedAmount, 200, accuracy: 0.001)
        XCTAssertEqual(result.timeline[4].investedAmount, 200, accuracy: 0.001)
    }

    func testAssetHistoryAggregatesAnnualOHLCBarsFromMonthlyBars() {
        let history = AssetHistory(
            asset: .voo,
            symbol: "VOO",
            displayName: "Vanguard S&P 500 ETF",
            categoryLabel: "Major ETF",
            monthlyPoints: [],
            monthlyBars: [
                MarketBar(
                    date: Self.date(year: 2020, month: 1, day: 1),
                    open: 10,
                    high: 20,
                    low: 8,
                    close: 15,
                    adjustedClose: 14,
                    volume: 100
                ),
                MarketBar(
                    date: Self.date(year: 2020, month: 12, day: 1),
                    open: 16,
                    high: 30,
                    low: 12,
                    close: 25,
                    adjustedClose: 22,
                    volume: 200
                ),
                MarketBar(
                    date: Self.date(year: 2021, month: 1, day: 1),
                    open: 25,
                    high: 32,
                    low: 24,
                    close: 31,
                    adjustedClose: 29,
                    volume: 300
                )
            ]
        )

        let annualBars = history.annualBars

        XCTAssertEqual(annualBars.count, 2)
        XCTAssertEqual(annualBars[0].open, 10, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].high, 30, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].low, 8, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].close, 25, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].adjustedClose, 22, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].volume ?? 0, 300, accuracy: 0.001)
        XCTAssertEqual(annualBars[0].date, Self.date(year: 2020, month: 12, day: 1))
        XCTAssertEqual(Calendar.utc.component(.year, from: annualBars[1].date), 2021)
    }

    func testAssetHistoryAggregatesSixMonthOHLCBarsFromMonthlyBars() {
        let history = AssetHistory(
            asset: .voo,
            symbol: "VOO",
            displayName: "Vanguard S&P 500 ETF",
            categoryLabel: "Major ETF",
            monthlyPoints: [],
            monthlyBars: [
                Self.bar(year: 2020, month: 1, open: 10, high: 12, low: 9, close: 11, adjustedClose: 11, volume: 100),
                Self.bar(year: 2020, month: 6, open: 11, high: 20, low: 10, close: 18, adjustedClose: 18, volume: 200),
                Self.bar(year: 2020, month: 7, open: 18, high: 22, low: 17, close: 21, adjustedClose: 21, volume: 300),
                Self.bar(year: 2020, month: 12, open: 21, high: 24, low: 19, close: 23, adjustedClose: 23, volume: 400)
            ]
        )

        let bars = history.bars(for: .sixMonths)

        XCTAssertEqual(bars.count, 2)
        XCTAssertEqual(bars[0].date, Self.date(year: 2020, month: 6, day: 1))
        XCTAssertEqual(bars[0].open, 10, accuracy: 0.001)
        XCTAssertEqual(bars[0].high, 20, accuracy: 0.001)
        XCTAssertEqual(bars[0].low, 9, accuracy: 0.001)
        XCTAssertEqual(bars[0].close, 18, accuracy: 0.001)
        XCTAssertEqual(bars[0].adjustedClose, 18, accuracy: 0.001)
        XCTAssertEqual(bars[0].volume ?? 0, 300, accuracy: 0.001)
        XCTAssertEqual(bars[1].date, Self.date(year: 2020, month: 12, day: 1))
    }

    func testRecurringSimulationUsesMonthlyContributionsWhenDisplayedAsSixMonthBars() {
        let history = AssetHistory(
            asset: .voo,
            symbol: "VOO",
            displayName: "Vanguard S&P 500 ETF",
            categoryLabel: "Major ETF",
            monthlyPoints: [],
            monthlyBars: [
                Self.bar(year: 2020, month: 1, adjustedClose: 100),
                Self.bar(year: 2020, month: 2, adjustedClose: 100),
                Self.bar(year: 2020, month: 3, adjustedClose: 100),
                Self.bar(year: 2020, month: 4, adjustedClose: 100),
                Self.bar(year: 2020, month: 5, adjustedClose: 100),
                Self.bar(year: 2020, month: 6, adjustedClose: 100),
                Self.bar(year: 2020, month: 7, adjustedClose: 200)
            ]
        )
        let scenario = InvestmentScenario(
            asset: .voo,
            startDate: Self.date(year: 2020, month: 1, day: 1),
            mode: .recurringMonthly,
            amount: 100
        )

        guard let result = engine.simulate(scenario: scenario, history: history, barInterval: .sixMonths) else {
            return XCTFail("Expected a valid recurring result")
        }

        XCTAssertEqual(result.timeline.count, 2)
        XCTAssertEqual(result.timeline[0].date, Self.date(year: 2020, month: 6, day: 1))
        XCTAssertEqual(result.timeline[0].investedAmount, 600, accuracy: 0.001)
        XCTAssertEqual(result.timeline[0].portfolioValue, 600, accuracy: 0.001)
        XCTAssertEqual(result.timeline[1].date, Self.date(year: 2020, month: 7, day: 1))
        XCTAssertEqual(result.timeline[1].investedAmount, 700, accuracy: 0.001)
        XCTAssertEqual(result.timeline[1].portfolioValue, 1_300, accuracy: 0.001)
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

    private static func bar(
        year: Int,
        month: Int,
        open: Double? = nil,
        high: Double? = nil,
        low: Double? = nil,
        close: Double? = nil,
        adjustedClose: Double,
        volume: Double? = nil
    ) -> MarketBar {
        MarketBar(
            date: date(year: year, month: month, day: 1),
            open: open ?? adjustedClose,
            high: high ?? adjustedClose,
            low: low ?? adjustedClose,
            close: close ?? adjustedClose,
            adjustedClose: adjustedClose,
            volume: volume
        )
    }
}
