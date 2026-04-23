import SwiftUI

enum AppTheme {
    enum ColorToken {
        static let brandPrimary = Color(red: 0.0, green: 0.3216, blue: 1.0)
        static let brandHover = Color(red: 0.3412, green: 0.5451, blue: 0.9804)
        static let textPrimary = Color(red: 0.0392, green: 0.0431, blue: 0.0510)
        static let textSecondary = Color(red: 0.3569, green: 0.3804, blue: 0.4314)
        static let surfaceBase = Color.white
        static let surfaceSubtle = Color(red: 0.9333, green: 0.9412, blue: 0.9529)
        static let surfaceMuted = Color(red: 0.9686, green: 0.9765, blue: 0.9922)
        static let borderSoft = textSecondary.opacity(0.14)
        static let danger = Color(red: 0.8235, green: 0.1961, blue: 0.2196)
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 32
        static let xl: CGFloat = 56
    }

    static let chartSeriesPalette: [Color] = [
        Color(red: 0.07, green: 0.42, blue: 0.86),
        Color(red: 0.03, green: 0.57, blue: 0.60),
        Color(red: 0.72, green: 0.44, blue: 0.16),
        Color(red: 0.45, green: 0.31, blue: 0.69),
        Color(red: 0.73, green: 0.34, blue: 0.26),
        Color(red: 0.34, green: 0.43, blue: 0.56)
    ]

    static var canvasGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.9804, green: 0.9882, blue: 1.0),
                Color(red: 0.9569, green: 0.9686, blue: 0.9882)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var shareGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.9882, green: 0.9922, blue: 1.0),
                Color(red: 0.9490, green: 0.9686, blue: 0.9922),
                Color(red: 0.9686, green: 0.9765, blue: 0.9882)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct AppCardSurfaceModifier: ViewModifier {
    let fill: Color
    let stroke: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(stroke)
                )
        )
    }
}

extension View {
    func appCardSurface(
        fill: Color = AppTheme.ColorToken.surfaceBase.opacity(0.94),
        stroke: Color = AppTheme.ColorToken.borderSoft,
        radius: CGFloat = AppTheme.Radius.lg
    ) -> some View {
        modifier(AppCardSurfaceModifier(fill: fill, stroke: stroke, radius: radius))
    }
}
