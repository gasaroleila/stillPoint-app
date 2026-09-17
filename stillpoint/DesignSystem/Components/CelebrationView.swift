import SwiftUI

enum CelebrationType {
    case streakMilestone(days: Int)
    case levelUp(stage: GrowthStage)
}

struct CelebrationView: View {
    let type: CelebrationType
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.spBackgroundAlt.ignoresSafeArea()

            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: iconName)
                        .font(.system(size: 72, weight: .medium))
                        .foregroundStyle(Color.spPrimary)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)

                    Text(title)
                        .font(.spLargeTitle)
                        .foregroundStyle(Color.spTextPrimary)

                    Text(subtitle)
                        .font(.spBody)
                        .foregroundStyle(Color.spTextSecondary)
                        .multilineTextAlignment(.center)

                    Text(badge)
                        .font(.spHeading)
                        .foregroundStyle(Color.spTextPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.spPrimaryLight)
                        .cornerRadius(SP.Radius.pill)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                PrimaryCTA(title: "Continue", action: onDismiss)
                    .padding(.horizontal, SP.Padding.screenHorizontal)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }

    private var iconName: String {
        switch type {
        case .streakMilestone: return "flame.fill"
        case .levelUp: return "arrow.up.circle.fill"
        }
    }

    private var title: String {
        switch type {
        case .streakMilestone(let days): return "\(days)-Day Streak"
        case .levelUp(let stage): return stage.label
        }
    }

    private var subtitle: String {
        switch type {
        case .streakMilestone(let days):
            return "You've been consistent for \(days) days straight. Keep it going!"
        case .levelUp(let stage):
            return "Your character has grown to the \(stage.label) stage."
        }
    }

    private var badge: String {
        switch type {
        case .streakMilestone: return "+75 XP"
        case .levelUp(let stage):
            return "Stage \(stageNumber(stage)) of 4"
        }
    }

    private func stageNumber(_ stage: GrowthStage) -> Int {
        switch stage {
        case .newborn: return 1
        case .sprouting: return 2
        case .young: return 3
        case .mature: return 4
        }
    }
}
