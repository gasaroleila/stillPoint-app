import SwiftUI

struct AppLoadingView: View {
    @State private var ringScales: [CGFloat] = [0, 0, 0]
    @State private var ringOpacities: [Double] = [0, 0, 0]
    @State private var coreScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var ringPulse: [CGFloat] = [1, 1, 1]

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
                .opacity(textOpacity)
            }
        }
        .onAppear { animateEntrance() }
    }

    // MARK: - Logo

    private var logo: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.4)
                .frame(width: 79, height: 79)
                .opacity(ringOpacities[0] * 0.57)
                .scaleEffect(ringScales[0] * ringPulse[0])

            // Middle ring
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.4)
                .frame(width: 56, height: 56)
                .opacity(ringOpacities[1] * 0.70)
                .scaleEffect(ringScales[1] * ringPulse[1])

            // Inner ring
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2.5)
                .frame(width: 32, height: 32)
                .opacity(ringOpacities[2] * 0.89)
                .scaleEffect(ringScales[2] * ringPulse[2])

            // Core dot
            Circle()
                .fill(Color.white)
                .frame(width: 25, height: 25)
                .overlay(
                    Circle()
                        .fill(Color.spPrimary)
                        .frame(width: 10, height: 10)
                )
                .scaleEffect(coreScale)
        }
        .frame(width: 90, height: 90)
    }

    // MARK: - Animation

    private func animateEntrance() {
        // Core pops in first
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
            coreScale = 1
        }

        // Rings ripple outward from inner to outer with more spacing
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.7)) {
            ringScales[2] = 1
            ringOpacities[2] = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(1.0)) {
            ringScales[1] = 1
            ringOpacities[1] = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(1.3)) {
            ringScales[0] = 1
            ringOpacities[0] = 1
        }

        // Text fades in after rings have fully settled
        withAnimation(.easeOut(duration: 0.6).delay(1.8)) {
            textOpacity = 1
        }

        // All rings pulse back and forth, staggered
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(2.0)) {
            ringPulse[2] = 1.15
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(2.2)) {
            ringPulse[1] = 1.12
        }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(2.4)) {
            ringPulse[0] = 1.08
        }
    }
}

#Preview {
    AppLoadingView()
}
