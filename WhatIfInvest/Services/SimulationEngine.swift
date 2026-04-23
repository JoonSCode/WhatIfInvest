import Foundation

struct SimulationEngine {
    func simulate(scenario: InvestmentScenario, history: AssetHistory) -> ScenarioResult? {
        guard scenario.amount > 0 else {
            return nil
        }

        let orderedPoints = history.monthlyPoints.sorted { $0.date < $1.date }
        guard let startIndex = orderedPoints.firstIndex(where: {
            $0.date >= scenario.normalizedStartDate && $0.adjustedClose > 0
        }) else {
            return nil
        }

        let relevantPoints = Array(orderedPoints[startIndex...]).filter { $0.adjustedClose > 0 }
        guard let firstPoint = relevantPoints.first else {
            return nil
        }

        var shares = 0.0
        var invested = 0.0
        var checkpoints: [TimelinePoint] = []

        for point in relevantPoints {
            switch scenario.mode {
            case .lumpSum:
                if invested == 0 {
                    invested = scenario.amount
                    shares = scenario.amount / firstPoint.adjustedClose
                }
            case .recurringMonthly:
                invested += scenario.amount
                shares += scenario.amount / point.adjustedClose
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
            timeline: yearSnapshots(from: checkpoints)
        )
    }

    private func yearSnapshots(from checkpoints: [TimelinePoint]) -> [TimelinePoint] {
        guard let first = checkpoints.first, let last = checkpoints.last else { return [] }

        var snapshots: [TimelinePoint] = [first]
        var previousYear = first.year
        var previousPoint = first

        for point in checkpoints.dropFirst() {
            if point.year != previousYear {
                snapshots.append(previousPoint)
                previousYear = point.year
            }
            previousPoint = point
        }

        if snapshots.last?.date != last.date {
            snapshots.append(last)
        }

        return snapshots.reduce(into: [TimelinePoint]()) { result, point in
            if result.last?.date != point.date {
                result.append(point)
            }
        }
    }
}
