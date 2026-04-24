import SwiftUI

struct LibraryView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        List {
            Section {
                Text(L10n.libraryPromoCopy)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .listRowBackground(Color.clear)
            }

            if appModel.savedScenarios.isEmpty {
                Section(L10n.libraryEmptyTitle) {
                    Text(L10n.libraryEmptyBody)
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)
                        .accessibilityIdentifier("saved-empty-state")
                }
            } else {
                Section(L10n.librarySavedSectionTitle) {
                    ForEach(appModel.savedScenarios) { entry in
                        SavedScenarioRow(
                            entry: entry,
                            onOpen: { appModel.loadSavedScenario(entry) },
                            onDelete: { appModel.removeSavedScenario(entry) }
                        )
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.canvasGradient)
        .navigationTitle(L10n.tabSaved)
    }
}

private struct SavedScenarioRow: View {
    let entry: SavedScenario
    let onOpen: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(UIFormatting.scenarioDescriptor(entry.scenario))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Text(L10n.savedAt(entry.savedAt.formatted(.dateTime.year().month().day().hour().minute())))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    openButton
                    deleteButton
                }

                VStack(alignment: .leading, spacing: 8) {
                    openButton
                    deleteButton
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("saved-scenario-row")
    }

    private var openButton: some View {
        Button(L10n.openInExplore, action: onOpen)
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.ColorToken.brandPrimary)
            .accessibilityIdentifier("saved-scenario-open-button")
    }

    private var deleteButton: some View {
        Button(L10n.delete, role: .destructive, action: onDelete)
            .buttonStyle(.bordered)
            .accessibilityIdentifier("saved-scenario-delete-button")
    }
}
