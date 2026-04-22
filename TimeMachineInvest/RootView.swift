import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.94, blue: 0.88),
                    Color(red: 0.88, green: 0.92, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Time Machine Invest")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Standalone SwiftUI app scaffold for the US stock what-if simulator.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    RootView()
}

