import SwiftUI

enum AssetBadgeSize {
    case compact
    case standard
    case hero

    var diameter: CGFloat {
        switch self {
        case .compact: return 28
        case .standard: return 44
        case .hero: return 72
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .compact: return 8
        case .standard: return 12
        case .hero: return 19
        }
    }

    var horizontalInset: CGFloat {
        switch self {
        case .compact: return 3
        case .standard: return 5
        case .hero: return 8
        }
    }

    var strokeWidth: CGFloat {
        switch self {
        case .compact: return 1
        case .standard: return 1.5
        case .hero: return 2
        }
    }
}

struct AssetBadgeView: View {
    let asset: AssetID
    var size: AssetBadgeSize = .standard

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            asset.tint.opacity(0.98),
                            asset.tint.opacity(0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.48), lineWidth: size.strokeWidth)
                )
                .overlay(
                    Circle()
                        .stroke(asset.tint.opacity(0.18), lineWidth: size.strokeWidth)
                )

            Text(asset.symbol)
                .font(.system(size: size.fontSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.48)
                .allowsTightening(true)
                .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
                .frame(width: size.diameter - (size.horizontalInset * 2))
        }
        .frame(width: size.diameter, height: size.diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(asset.symbol), \(asset.displayName)")
    }
}
