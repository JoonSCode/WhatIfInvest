import Foundation

enum L10n {
    private static let tableName = "Localizable"

    private static func text(_ key: String, _ defaultValue: String) -> String {
        let value = Bundle.main.localizedString(forKey: key, value: defaultValue, table: tableName)
        return value == key ? defaultValue : value
    }

    private static func format(_ key: String, _ defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = text(key, defaultValue)
        return String(format: format, locale: Locale.autoupdatingCurrent, arguments: arguments)
    }

    static var tabExplore: String { text("tab.explore", "Explore") }
    static var tabSaved: String { text("tab.saved", "Saved") }

    static var loadingAdjustedCloseTitle: String {
        text("loading.adjusted_close.title", "Loading adjusted-close history")
    }

    static var loadingAdjustedCloseBody: String {
        text(
            "loading.adjusted_close.body",
            "Past market data is loading locally so your first result is ready fast."
        )
    }

    static var exploreHeroTitle: String { text("explore.hero.title", "If you had invested then") }
    static var exploreHeroEyebrow: String {
        text("explore.hero.eyebrow", "Time-travel investing")
    }
    static var exploreHeroSubtitle: String {
        text(
            "explore.hero.subtitle",
            "A hindsight simulator for major US ETFs and the Magnificent 7. Built to make the force of time feel visual, not abstract."
        )
    }

    static var storyModeTitle: String { text("explore.story_mode.title", "Story mode") }
    static var storyModeSubtitle: String {
        text(
            "explore.story_mode.subtitle",
            "Start with one scenario. Add comparisons only after the first answer lands."
        )
    }

    static var loadingHistoricalData: String {
        text("explore.loading_historical_data", "Loading historical data...")
    }

    static var runReplay: String { text("explore.run_replay", "Run Replay") }
    static var stopReplay: String { text("explore.stop_replay", "Stop Replay") }
    static var playYears: String { text("explore.play_years", "Play Years") }
    static var stopPlayback: String { text("explore.stop_playback", "Stop Playback") }
    static var addComparison: String { text("explore.add_comparison", "Add Comparison") }
    static var saveScenario: String { text("explore.save_scenario", "Save Scenario") }
    static var share: String { text("common.share", "Share") }
    static var shareCard: String { text("explore.share_card", "Share Card") }
    static var preparing: String { text("common.preparing", "Preparing...") }
    static var preparingShareCard: String {
        text("explore.preparing_share_card", "Preparing Share Card...")
    }
    static var refreshData: String { text("explore.refresh_data", "Refresh Data") }
    static var refreshingData: String { text("explore.refreshing_data", "Refreshing...") }
    static var more: String { text("common.more", "More") }
    static var visibleYearTitle: String { text("explore.stat.visible_year", "Visible year") }
    static var savedCountTitle: String { text("explore.stat.saved", "Saved") }
    static var comparedCountTitle: String { text("explore.stat.compared", "Compared") }
    static var latest: String { text("explore.visible_year.latest", "Latest") }
    static var compareModeTitle: String { text("explore.compare_mode.title", "Compare mode") }
    static var clearComparisons: String {
        text("comparison.clear", "Clear comparisons")
    }
    static var clear: String { text("common.clear", "Clear") }
    static var remove: String { text("common.remove", "Remove") }
    static var noResultYet: String { text("explore.no_result_yet", "No result yet") }
    static var adjustScenario: String { text("explore.adjust_scenario", "Adjust the scenario") }
    static var noResultBody: String {
        text(
            "explore.no_result_body",
            "Load the bundled data or refresh the cache to start exploring."
        )
    }

    static var assetFieldTitle: String { text("editor.asset", "Asset") }
    static var startDateFieldTitle: String { text("editor.start_date", "Start date") }
    static var modeFieldTitle: String { text("editor.mode", "Mode") }
    static var amountPlaceholder: String { text("editor.amount.placeholder", "Amount") }

    static var investedTitle: String { text("result.metric.invested", "Invested") }
    static var returnTitle: String { text("result.metric.return", "Return") }
    static var spanTitle: String { text("result.metric.span", "Span") }
    static var timelineReplayTitle: String {
        text("chart.timeline_replay.title", "Timeline replay")
    }
    static var chartTimeAxis: String { text("chart.axis.time", "Time") }
    static var chartAmountAxis: String { text("chart.axis.amount_usd", "Amount (USD)") }
    static var newComparisonTitle: String { text("comparison.new.title", "New comparison") }
    static var newComparisonSubtitle: String {
        text(
            "comparison.new.subtitle",
            "Keep it lightweight. Add one more line only after the first line already means something."
        )
    }
    static var addComparisonTitle: String { text("comparison.nav.title", "Add comparison") }
    static var cancel: String { text("common.cancel", "Cancel") }
    static var add: String { text("common.add", "Add") }

    static var libraryPromoCopy: String {
        text(
            "library.promo.copy",
            "Saved scenarios stay on device so you can reopen a past idea and compare it again later."
        )
    }
    static var libraryEmptyTitle: String { text("library.empty.title", "Nothing saved yet") }
    static var libraryEmptyBody: String {
        text(
            "library.empty.body",
            "Save a scenario from Explore to keep a lightweight history."
        )
    }
    static var librarySavedSectionTitle: String {
        text("library.section.saved", "Saved scenarios")
    }
    static var openInExplore: String { text("library.action.open", "Open in Explore") }
    static var delete: String { text("common.delete", "Delete") }

    static var shareHeroTitle: String { text("share.hero.title", "If you had invested then") }
    static var shareComparedAgainstTitle: String {
        text("share.compared_against", "Compared against")
    }
    static var shareDisclaimer: String {
        text(
            "share.disclaimer",
            "Adjusted close basis. Taxes, fees, FX, and inflation excluded."
        )
    }
    static var trustHowToRead: String { text("trust.how_to_read", "How to read this") }
    static var trustAdjustedClose: String {
        text(
            "trust.adjusted_close",
            "Returns use adjusted close, which reflects splits and dividends."
        )
    }
    static var trustExclusions: String {
        text(
            "trust.exclusions",
            "Taxes, fees, exchange rates, and inflation are excluded."
        )
    }
    static var trustLatestSnapshotUnavailable: String {
        text("trust.latest_snapshot_unavailable", "Latest data snapshot unavailable.")
    }
    static var trustLatestSnapshotDateTitle: String {
        text("trust.latest_snapshot_date.title", "Snapshot")
    }
    static var trustLatestSnapshotProviderTitle: String {
        text("trust.latest_snapshot_provider.title", "Provider")
    }

    static var providerBundledData: String { text("provider.bundled_data", "Bundled data") }
    static var providerYahooMonthlyAdjusted: String {
        text("provider.yahoo_monthly_adjusted", "Yahoo Finance chart endpoint (monthly adjusted close)")
    }

    static var shareSummaryPending: String { text("share.summary.pending", "Scenario pending.") }
    static var shareSummaryComparisonsPrefix: String {
        text("share.summary.comparisons_prefix", "Comparisons")
    }
    static var shareSummaryBasis: String {
        text("share.summary.basis", "Basis: adjusted close, taxes/fees/inflation excluded.")
    }

    static var validationPositiveAmount: String {
        text(
            "validation.positive_amount",
            "Enter an amount above $0 to generate a meaningful result."
        )
    }

    static var errorBundledFileMissing: String {
        text("error.bundled_file_missing", "Bundled historical data file is missing.")
    }
    static var errorInvalidResponse: String {
        text(
            "error.invalid_response",
            "Historical data refresh returned an invalid response."
        )
    }
    static var errorShareRenderFailed: String {
        text("error.share_render_failed", "The share card could not be rendered right now.")
    }

    static var modeLumpSumTitle: String { text("mode.lump_sum.title", "Lump Sum") }
    static var modeRecurringMonthlyTitle: String { text("mode.recurring_monthly.title", "Monthly") }
    static var modeLumpSumInline: String { text("mode.lump_sum.inline", "lump sum") }
    static var modeRecurringMonthlyInline: String {
        text("mode.recurring_monthly.inline", "monthly")
    }
    static var modeLumpSumAmountField: String {
        text("mode.lump_sum.amount_field", "Starting amount")
    }
    static var modeRecurringMonthlyAmountField: String {
        text("mode.recurring_monthly.amount_field", "Monthly amount")
    }

    static var categoryMajorETF: String { text("category.major_etf", "Major ETF") }
    static var categoryMagnificent7: String {
        text("category.magnificent_7", "Magnificent 7")
    }

    static func assetDisplayName(for asset: AssetID) -> String {
        switch asset {
        case .spy:
            return text("asset.spy.display_name", "SPDR S&P 500 ETF")
        case .voo:
            return text("asset.voo.display_name", "Vanguard S&P 500 ETF")
        case .vti:
            return text("asset.vti.display_name", "Vanguard Total Stock Market ETF")
        case .qqq:
            return text("asset.qqq.display_name", "Invesco Nasdaq-100 ETF")
        case .dia:
            return text("asset.dia.display_name", "SPDR Dow Jones ETF")
        case .aapl:
            return text("asset.aapl.display_name", "Apple")
        case .msft:
            return text("asset.msft.display_name", "Microsoft")
        case .nvda:
            return text("asset.nvda.display_name", "NVIDIA")
        case .amzn:
            return text("asset.amzn.display_name", "Amazon")
        case .googl:
            return text("asset.googl.display_name", "Alphabet")
        case .meta:
            return text("asset.meta.display_name", "Meta")
        case .tsla:
            return text("asset.tsla.display_name", "Tesla")
        }
    }

    static func visibleThroughYear(_ year: Int) -> String {
        format("explore.visible_year.until", "Visible through %d", year)
    }

    static func statusSummary(visibleThrough: String, scenarioCount: Int, savedCount: Int) -> String {
        format(
            "explore.status_summary",
            "Visible through %@ • %d scenarios • %d saved",
            visibleThrough,
            scenarioCount,
            savedCount
        )
    }

    static func comparisonResultSummary(currentValue: String, returnValue: String) -> String {
        format(
            "comparison.result.summary",
            "Now %@ · Return %@",
            currentValue,
            returnValue
        )
    }

    static func startedWithAsset(_ symbol: String) -> String {
        format("result.header.started_with", "If you had started with %@", symbol)
    }

    static func savedAt(_ timestamp: String) -> String {
        format("library.row.saved_at", "Saved %@", timestamp)
    }

    static func shareSnapshotRefreshed(_ timestamp: String) -> String {
        format("share.snapshot_refreshed", "Snapshot refreshed %@.", timestamp)
    }

    static func trustLatestSnapshot(date: String, provider: String) -> String {
        format(
            "trust.latest_snapshot",
            "Latest data snapshot: %@ via %@.",
            date,
            provider
        )
    }

    static func trustLatestSnapshotDate(_ date: String) -> String {
        format("trust.latest_snapshot_date", "Latest data snapshot: %@.", date)
    }

    static func trustLatestSnapshotProvider(_ provider: String) -> String {
        format("trust.latest_snapshot_provider", "Provider: %@.", provider)
    }

    static func shareSummaryPrimaryLine(
        asset: String,
        currentValue: String,
        amount: String,
        mode: String,
        growth: String
    ) -> String {
        format(
            "share.summary.primary_line",
            "%1$@: %2$@ now from %3$@ %4$@, return %5$@%%.",
            asset,
            currentValue,
            amount,
            mode,
            growth
        )
    }

    static func validationRange(symbol: String, start: String, end: String) -> String {
        format(
            "validation.range",
            "%1$@ history currently runs from %2$@ through %3$@.",
            symbol,
            start,
            end
        )
    }

    static func errorEmptySeries(for symbol: String) -> String {
        format("error.empty_series", "No adjusted-close series was returned for %@.", symbol)
    }

    static func spanYears(_ years: Double) -> String {
        format("timeframe.years", "%.1fy", years)
    }

    static func spanMonths(_ months: Int) -> String {
        format("timeframe.months", "%d mo", months)
    }

    static func providerLabel(for rawValue: String?) -> String {
        guard let rawValue, !rawValue.isEmpty else {
            return providerBundledData
        }

        if rawValue.contains("Yahoo Finance") {
            return providerYahooMonthlyAdjusted
        }

        return rawValue
    }
}
