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
                        VStack(alignment: .leading, spacing: 8) {
                            Text(UIFormatting.scenarioDescriptor(entry.scenario))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text(L10n.savedAt(entry.savedAt.formatted(.dateTime.year().month().day().hour().minute())))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.ColorToken.textSecondary)

                            HStack {
                                Button(L10n.openInExplore) {
                                    appModel.loadSavedScenario(entry)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.ColorToken.brandPrimary)
                                .accessibilityIdentifier("saved-scenario-open-button")

                                Button(L10n.delete, role: .destructive) {
                                    appModel.removeSavedScenario(entry)
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("saved-scenario-delete-button")
                            }
                        }
                        .padding(.vertical, 8)
                        .accessibilityIdentifier("saved-scenario-row")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.canvasGradient)
        .navigationTitle(L10n.tabSaved)
    }
}
