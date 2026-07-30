import SwiftUI

struct AppLoadingView: View {
    @State private var activeDot = 0

    var body: some View {
        ZStack {
            Color.spPrimary
                .ignoresSafeArea()

            VStack(spacing: 20) {
                logo
                VStack(spacing: 4) {
                    Text("Still Point")
                        .font(.custom("Nunito-Black", size: 35.2))
                        .tracking(-0.7)
                        .foregroundStyle(Color.white)

                    Text("YOUR DAILY SELF-CARE")
                        .font(.custom("Nunito-SemiBold", size: 11.5))
                        .tracking(1.6)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }

            VStack {
                Spacer()
                loadingDots
                    .padding(.bottom, 60)
            }
        }
        .onAppear { startDotAnimation() }
    }

    // MARK: - Logo

    private var logo: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.4)
                .frame(width: 79, height: 79)
                .opacity(0.57)

            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.4)
                .frame(width: 56, height: 56)
                .opacity(0.70)

            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.5)
                .frame(width: 32, height: 32)
                .opacity(0.89)

            Circle()
                .fill(Color.white)
                .frame(width: 25, height: 25)
                .overlay(
                    Circle()
                        .fill(Color.spPrimary)
                        .frame(width: 10, height: 10)
                )
        }
        .frame(width: 90, height: 90)
    }

    // MARK: - Loading Dots

    private var loadingDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(activeDot == index ? 0.9 : 0.4))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                activeDot = (activeDot + 1) % 3
            }
        }
    }
}

#Preview {
    AppLoadingView()
}
