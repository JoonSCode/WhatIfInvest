import SwiftUI

struct LibraryView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        List {
            Section {
                Text("Saved scenarios stay on device so you can reopen a past idea and compare it again later.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .listRowBackground(Color.clear)
            }

            if appModel.savedScenarios.isEmpty {
                Section("Nothing saved yet") {
                    Text("Save a scenario from Explore to keep a lightweight history.")
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)
                        .accessibilityIdentifier("saved-empty-state")
                }
            } else {
                Section("Saved scenarios") {
                    ForEach(appModel.savedScenarios) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(UIFormatting.scenarioDescriptor(entry.scenario))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("Saved \(entry.savedAt.formatted(.dateTime.year().month().day().hour().minute()))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.ColorToken.textSecondary)

                            HStack {
                                Button("Open in Explore") {
                                    appModel.loadSavedScenario(entry)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.ColorToken.brandPrimary)
                                .accessibilityIdentifier("saved-scenario-open-button")

                                Button("Delete", role: .destructive) {
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
        .navigationTitle("Saved")
    }
}
