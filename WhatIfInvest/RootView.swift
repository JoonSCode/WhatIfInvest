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
                    Label(L10n.tabExplore, systemImage: "sparkles.rectangle.stack")
                }
                .tag(AppTab.explore)
                .accessibilityIdentifier("explore-tab")

                NavigationStack {
                    LibraryView()
                }
                .tabItem {
                    Label(L10n.tabSaved, systemImage: "bookmark")
                }
                .tag(AppTab.library)
                .accessibilityIdentifier("saved-tab")
            }

            if appModel.historicalPayload == nil && appModel.isLoading {
                LaunchLoadingView()
                    .transition(.opacity)
            }
        }
        .tint(AppTheme.ColorToken.brandPrimary)
        .task {
            await Task.yield()
            await appModel.loadIfNeeded()
        }
    }
}

private struct LaunchLoadingView: View {
    var body: some View {
        ZStack {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Circle()
                    .fill(AppTheme.ColorToken.brandPrimary)
                    .frame(width: 18, height: 18)

                Text(AppBrand.displayName)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)
                    .multilineTextAlignment(.center)

                ProgressView()
                    .controlSize(.large)
                    .tint(AppTheme.ColorToken.brandPrimary)

                Text(L10n.loadingAdjustedCloseTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                Text(L10n.loadingAdjustedCloseBody)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
            .padding(28)
            .appCardSurface(fill: AppTheme.ColorToken.surfaceBase.opacity(0.92))
            .padding(24)
        }
    }
}

#Preview {
    RootView()
        .environment(AppModel())
}
