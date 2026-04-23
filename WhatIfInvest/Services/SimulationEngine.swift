import Foundation

struct SimulationEngine {
    func simulate(
        scenario: InvestmentScenario,
        history: AssetHistory,
        barInterval: MarketBarInterval? = nil
    ) -> ScenarioResult? {
        guard scenario.amount > 0 else {
            return nil
        }

        let orderedValuationPoints = history.pricePoints(for: barInterval).sorted { $0.date < $1.date }
        guard let startIndex = orderedValuationPoints.firstIndex(where: {
            $0.date >= scenario.normalizedStartDate && $0.adjustedClose > 0
        }) else {
            return nil
        }

        let relevantValuationPoints = Array(orderedValuationPoints[startIndex...]).filter { $0.adjustedClose > 0 }
        guard !relevantValuationPoints.isEmpty else {
            return nil
        }

        let contributionPoints = contributionPoints(
            for: history,
            barInterval: barInterval,
            startDate: scenario.normalizedStartDate
        )
        guard let firstContributionPoint = contributionPoints.first else {
            return nil
        }

        var shares = 0.0
        var invested = 0.0
        var checkpoints: [TimelinePoint] = []
        var lastContributionMonth: Int?
        var contributionIndex = 0

        for point in relevantValuationPoints {
            switch scenario.mode {
            case .lumpSum:
                if invested == 0 {
                    invested = scenario.amount
                    shares = scenario.amount / firstContributionPoint.adjustedClose
                }
            case .recurringMonthly:
                while contributionIndex < contributionPoints.count {
                    let contributionPoint = contributionPoints[contributionIndex]
                    guard contributionPoint.date <= point.date else { break }

                    let contributionMonth = Self.monthKey(for: contributionPoint.date)
                    if contributionMonth != lastContributionMonth {
                        invested += scenario.amount
                        shares += scenario.amount / contributionPoint.adjustedClose
                        lastContributionMonth = contributionMonth
                    }
                    contributionIndex += 1
                }
            }

            let value = shares * point.adjustedClose
            checkpoints.append(
                TimelinePoint(
                    date: point.date,
                    year: Calendar.utc.component(.year, from: point.date),
                    investedAmount: invested,
                    portfolioValue: value
                )
            )
        }

        guard let current = checkpoints.last else { return nil }

        return ScenarioResult(
            scenario: scenario,
            investedAmount: current.investedAmount,
            currentValue: current.portfolioValue,
            totalReturnRatio: current.investedAmount == 0 ? 0 : ((current.portfolioValue / current.investedAmount) - 1),
            timeline: checkpoints
        )
    }

    private func contributionPoints(
        for history: AssetHistory,
        barInterval: MarketBarInterval?,
        startDate: Date
    ) -> [MarketPoint] {
        let points: [MarketPoint]
        if barInterval == nil {
            points = history.pricePoints
        } else {
            points = history.pricePoints(for: .oneMonth)
        }

        return points
            .filter { $0.date >= startDate && $0.adjustedClose > 0 }
            .sorted { $0.date < $1.date }
    }

    private static func monthKey(for date: Date) -> Int {
        let year = Calendar.utc.component(.year, from: date)
        let month = Calendar.utc.component(.month, from: date)
        return year * 100 + month
    }
}
