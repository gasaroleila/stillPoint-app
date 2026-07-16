import SwiftUI

struct BreathingExerciseView: View {
    let onDismiss: () -> Void

    private let totalCycles = 3
    private let phaseDuration: TimeInterval = 4

    @State private var currentCycle = 1
    @State private var phase: BreathPhase = .inhale
    @State private var countdown = 4
    // Start full size so the first "Breathe in" visibly shrinks it
    @State private var innerScale: CGFloat = 1.0
    @State private var isComplete = false
    @State private var timer: Timer?

    var body: some View {
        if isComplete {
            ActivityCompleteView(
                activityName: "Breathing Exercise",
                xpEarned: 30,
                onDone: onDismiss
            )
        } else {
            exerciseContent
        }
    }

    // Using ZStack so close button overlays top-right while all content stays centered
    private var exerciseContent: some View {
        ZStack(alignment: .topTrailing) {
            // Everything vertically centered as one group (label, title, circle, bars)
            VStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("CYCLE \(currentCycle) OF \(totalCycles)")
                        .font(.spActivityLabel)
                        .foregroundStyle(Color.spTextSecondary)
                        .tracking(0.832)

                    Text("Breathing Exercise")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                }

                ZStack {
                    // Outer ring — fixed
                    Circle()
                        .fill(Color.spPrimaryLight)
                        .frame(width: 260, height: 260)

                    // Inner yellow circle — shrinks on inhale, expands on exhale
                    Circle()
                        .fill(Color.spPrimary)
                        .frame(width: 200, height: 200)
                        .scaleEffect(innerScale)

                    VStack(spacing: 4) {
                        Text(phase.label)
                            .font(.spCardTitle)
                            .foregroundStyle(Color.spTextPrimary)

                        Text("\(countdown)")
                            .font(.spLargeTitle)
                            .foregroundStyle(Color.spTextPrimary)
                            .contentTransition(.numericText())
                    }
                }

                HStack(spacing: 6) {
                    ForEach(1...totalCycles, id: \.self) { cycle in
                        Capsule()
                            .fill(progressColor(for: cycle))
                            .frame(width: 40, height: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: onDismiss)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
        .onAppear { startExercise() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Progress bar color

    private func progressColor(for cycle: Int) -> Color {
        if cycle < currentCycle {
            return Color.spPrimary
        } else if cycle == currentCycle {
            return Color.spPrimary.opacity(0.5)
        } else {
            return Color.spBorder
        }
    }

    // MARK: - Timer logic

    private func startExercise() {
        currentCycle = 1
        beginPhase(.inhale)
    }

    private func beginPhase(_ newPhase: BreathPhase) {
        phase = newPhase
        countdown = 4

        // Inverted: inhale shrinks (taking air in), exhale expands (releasing air out)
        let targetScale: CGFloat = switch newPhase {
        case .inhale: 0.7
        case .holdIn: 0.7
        case .exhale: 1.0
        case .holdOut: 1.0
        }

        withAnimation(.easeInOut(duration: newPhase.isTransition ? phaseDuration : 0)) {
            innerScale = targetScale
        }

        // Tick countdown every second
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    countdown -= 1
                }
            } else {
                timer?.invalidate()
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        if let next = phase.next {
            beginPhase(next)
        } else {
            // End of cycle
            if currentCycle < totalCycles {
                currentCycle += 1
                beginPhase(.inhale)
            } else {
                withAnimation {
                    isComplete = true
                }
            }
        }
    }
}

// MARK: - Breath Phase

private enum BreathPhase {
    case inhale, holdIn, exhale, holdOut

    var label: String {
        switch self {
        case .inhale: "Breathe in"
        case .holdIn: "Hold"
        case .exhale: "Breathe out"
        case .holdOut: "Hold"
        }
    }

    /// Whether the circle should animate its scale during this phase
    var isTransition: Bool {
        switch self {
        case .inhale, .exhale: true
        case .holdIn, .holdOut: false
        }
    }

    var next: BreathPhase? {
        switch self {
        case .inhale: .holdIn
        case .holdIn: .exhale
        case .exhale: .holdOut
        case .holdOut: nil
        }
    }
}

#Preview {
    BreathingExerciseView(onDismiss: {})
}
