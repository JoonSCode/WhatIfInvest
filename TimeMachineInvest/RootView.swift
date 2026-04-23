import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel

        ZStack {
            TabView(selection: $appModel.selectedTab) {
                NavigationStack {
                    ExploreView()
                }
                .tabItem {
                    Label("Explore", systemImage: "sparkles.rectangle.stack")
                }
                .tag(AppTab.explore)
                .accessibilityIdentifier("explore-tab")

                NavigationStack {
                    LibraryView()
                }
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag(AppTab.library)
                .accessibilityIdentifier("saved-tab")
            }

            if appModel.historicalPayload == nil && appModel.isLoading {
                LaunchLoadingView()
                    .transition(.opacity)
            }
        }
        .task {
            await Task.yield()
            await appModel.loadIfNeeded()
        }
    }
}

private struct LaunchLoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.94, blue: 0.88),
                    Color(red: 0.92, green: 0.94, blue: 0.97),
                    Color(red: 0.98, green: 0.97, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Then")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.16, green: 0.18, blue: 0.24))

                ProgressView()
                    .controlSize(.large)
                    .tint(Color(red: 0.10, green: 0.29, blue: 0.54))

                Text("Loading bundled market history")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.30))

                Text("The first frame should appear immediately now, even while local data is decoding.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.78))
            )
            .padding(24)
        }
    }
}

#Preview {
    RootView()
        .environment(AppModel())
}
