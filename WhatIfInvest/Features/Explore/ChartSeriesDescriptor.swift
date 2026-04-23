import Charts
import SwiftUI

struct ChartSeriesDescriptor: Identifiable {
    let result: ScenarioResult
    let color: Color
    let symbol: ChartSeriesSymbol

    var id: UUID { result.id }
    var seriesKey: String { result.scenario.storageKey }
    var primaryText: String { UIFormatting.scenarioDescriptor(result.scenario) }
    var secondaryText: String {
        L10n.comparisonResultSummary(
            currentValue: result.currentValue.currencyText,
            returnValue: result.totalReturnRatio.percentText
        )
    }

    static func make(from results: [ScenarioResult]) -> [ChartSeriesDescriptor] {
        let assignments = assignmentMap(for: results.map(\.scenario))

        return results.map { result in
            let assignment = assignments[result.scenario.storageKey]
                ?? SeriesPresentationAssignment(colorIndex: 0, symbolIndex: 0)

            return ChartSeriesDescriptor(
                result: result,
                color: AppTheme.chartSeriesPalette[assignment.colorIndex % AppTheme.chartSeriesPalette.count],
                symbol: ChartSeriesSymbol.allCases[assignment.symbolIndex % ChartSeriesSymbol.allCases.count]
            )
        }
    }

    private static func assignmentMap(for scenarios: [InvestmentScenario]) -> [String: SeriesPresentationAssignment] {
        let orderedScenarios = scenarios.sorted { $0.storageKey < $1.storageKey }
        var usedColorIndexes: Set<Int> = []
        var usedSymbolIndexes: Set<Int> = []
        var assignments: [String: SeriesPresentationAssignment] = [:]

        for scenario in orderedScenarios {
            let colorIndex = firstAvailableIndex(
                startingAt: stableHash(for: scenario.storageKey, modulo: AppTheme.chartSeriesPalette.count),
                used: usedColorIndexes,
                upperBound: AppTheme.chartSeriesPalette.count
            )
            let symbolIndex = firstAvailableIndex(
                startingAt: stableHash(for: "\(scenario.storageKey)-symbol", modulo: ChartSeriesSymbol.allCases.count),
                used: usedSymbolIndexes,
                upperBound: ChartSeriesSymbol.allCases.count
            )

            usedColorIndexes.insert(colorIndex)
            usedSymbolIndexes.insert(symbolIndex)
            assignments[scenario.storageKey] = SeriesPresentationAssignment(
                colorIndex: colorIndex,
                symbolIndex: symbolIndex
            )
        }

        return assignments
    }

    private static func stableHash(for value: String, modulo: Int) -> Int {
        guard modulo > 0 else { return 0 }

        var hash: UInt64 = 5_381
        for scalar in value.unicodeScalars {
            hash = ((hash << 5) &+ hash &+ UInt64(scalar.value)) % UInt64(Int.max)
        }
        return Int(hash % UInt64(modulo))
    }

    private static func firstAvailableIndex(
        startingAt start: Int,
        used: Set<Int>,
        upperBound: Int
    ) -> Int {
        guard upperBound > 0 else { return 0 }

        for offset in 0..<upperBound {
            let candidate = (start + offset) % upperBound
            if !used.contains(candidate) {
                return candidate
            }
        }

        return start % upperBound
    }
}

enum ChartSeriesSymbol: Int, CaseIterable {
    case circle
    case square
    case diamond
    case triangle
    case pentagon
    case plus

    var chartShape: BasicChartSymbolShape {
        switch self {
        case .circle:
            return .circle
        case .square:
            return .square
        case .diamond:
            return .diamond
        case .triangle:
            return .triangle
        case .pentagon:
            return .pentagon
        case .plus:
            return .plus
        }
    }

    var systemImageName: String {
        switch self {
        case .circle:
            return "circle.fill"
        case .square:
            return "square.fill"
        case .diamond:
            return "diamond.fill"
        case .triangle:
            return "triangle.fill"
        case .pentagon:
            return "pentagon.fill"
        case .plus:
            return "plus"
        }
    }
}

private struct SeriesPresentationAssignment {
    let colorIndex: Int
    let symbolIndex: Int
}
