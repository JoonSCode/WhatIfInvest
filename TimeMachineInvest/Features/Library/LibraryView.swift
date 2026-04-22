import SwiftUI

struct LibraryView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        List {
            Section {
                Text("Saved scenarios stay free so revisit and sharing behavior can be measured before deeper monetization.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            if appModel.savedScenarios.isEmpty {
                Section("Nothing saved yet") {
                    Text("Save a scenario from Explore to keep a lightweight history.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Saved scenarios") {
                    ForEach(appModel.savedScenarios) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(UIFormatting.scenarioDescriptor(entry.scenario))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("Saved \(entry.savedAt.formatted(.dateTime.year().month().day().hour().minute()))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            HStack {
                                Button("Open in Explore") {
                                    appModel.loadSavedScenario(entry)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(entry.scenario.asset.tint)

                                Button("Delete", role: .destructive) {
                                    appModel.removeSavedScenario(entry)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.94, blue: 0.91),
                    Color(red: 0.93, green: 0.95, blue: 0.97)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Saved")
        .task {
            await appModel.loadIfNeeded()
        }
    }
}

