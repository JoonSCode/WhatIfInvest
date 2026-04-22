import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel

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
    }
}

#Preview {
    RootView()
        .environment(AppModel())
}
