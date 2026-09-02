import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var viewModel: HomeViewModel?
    @State private var showBreathingExercise = false
    @State private var showDeepFocus = false
    @State private var showColoring = false
    @State private var showJournaling = false

    private var vm: HomeViewModel {
        if let viewModel { return viewModel }
        let created = HomeViewModel(
            moods: dependencies.moods,
            activities: dependencies.activities,
            user: dependencies.user
        )
        DispatchQueue.main.async { viewModel = created }
        return created
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                moodSection
                activities
            }
        }
        .background(Color.spBackground)
        .ignoresSafeArea(edges: .top)
        .onAppear { Task { await vm.loadProfile() } }
        .fullScreenCover(isPresented: $showBreathingExercise) {
            BreathingExerciseView(
                onComplete: { _ in handleCompletion(type: .breathing, duration: 120) },
                onDismiss: { showBreathingExercise = false }
            )
        }
        .fullScreenCover(isPresented: $showDeepFocus) {
            DeepFocusView(
                onComplete: { _ in handleCompletion(type: .focus, duration: 1200) },
                onDismiss: { showDeepFocus = false }
            )
        }
        .fullScreenCover(isPresented: $showColoring) {
            ColoringView(
                onComplete: { _ in handleCompletion(type: .coloring, duration: 300) },
                onDismiss: { showColoring = false }
            )
        }
        .fullScreenCover(isPresented: $showJournaling) {
            JournalingView(
                onComplete: { _ in handleCompletion(type: .journaling, duration: 1800) },
                onDismiss: { showJournaling = false }
            )
        }
    }

    private func handleCompletion(type: ActivityType, duration: Int) {
        Task { await vm.logActivityCompletion(type: type, durationSeconds: duration) }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Image("user-profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 51.3, height: 51.3)
                    .clipShape(Circle())
                    .padding(2.3)
                    .background(
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: 2)
                    )

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("\(vm.streakDays)")
                        .font(.custom("Nunito-Black", size: 22.4))
                        .foregroundStyle(Color.white)
                }

                Spacer()

                Button {
                    // notifications
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.top, 60)
            .padding(.bottom, 16)

            VStack(spacing: 0) {
                Text("Good evening, \(vm.userName)")
                    .font(.spGreeting)
                    .foregroundStyle(Color.white.opacity(0.7))
                Text("How do you feel?")
                    .font(.spLargeTitle)
                    .foregroundStyle(Color.white)
                    .padding(.top, 2)
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.spPrimary)
    }

    // MARK: - Mood section (row OR compact indicator + curve)

    private var moodSection: some View {
        VStack(spacing: 0) {
            Group {
                if let selectedMood = vm.selectedMood {
                    moodCompact(selectedMood)
                } else {
                    moodRow
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(Color.spPrimary)

            Image("home-separator-curve")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color.spPrimary)
        }
    }

    private var moodRow: some View {
        HStack(spacing: 0) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                moodButton(mood)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }

    private func moodButton(_ mood: MoodType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                vm.selectedMood = mood
            }
            Task { await vm.confirmMood() }
        } label: {
            VStack(spacing: 7) {
                Image(mood.assetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .foregroundStyle(Color.white.opacity(0.5))
                    .frame(width: SP.Size.moodAvatar, height: SP.Size.moodAvatar)
                Text(mood.label)
                    .font(.spCaption)
                    .foregroundStyle(Color.spMoodLabelInactive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }

    private func moodCompact(_ mood: MoodType) -> some View {
        HStack(spacing: 12) {
            Image(mood.assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: 0) {
                Text("Feeling")
                    .font(.custom("Nunito-SemiBold", size: 10.4))
                    .foregroundStyle(Color.white.opacity(0.65))
                Text(mood.label)
                    .font(.custom("Nunito-Black", size: 16))
                    .foregroundStyle(Color.white)
            }

            Button {
                Task { await vm.confirmMood() }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 24, height: 24)
                    .background(Color.white.opacity(0.25))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Activities

    private var activities: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Activities")
                        .font(.spHeading)
                        .foregroundStyle(Color.spTextPrimary)
                    Text(vm.suggestions.isEmpty
                         ? "Complete activities to keep your streak alive"
                         : "3 suggested activities for today")
                        .font(.spBodyRegular)
                        .foregroundStyle(Color.spTextSecondary)
                }
                Spacer()
                XPBadge(earned: vm.earnedXP, total: vm.maxDailyXP)
            }
            .padding(.bottom, 4)

            ForEach(vm.displayedActivities, id: \.type) { activity in
                ActivityCard(
                    iconAsset: activity.iconAsset,
                    title: activity.title,
                    description: activity.description,
                    durationText: activity.durationText,
                    xpText: activity.xpText,
                    isCompleted: vm.completedActivities.contains(activity.type),
                    action: { handleActivityTap(activity.type) }
                )
            }


        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background(Color.spBackground)
    }

    private func handleActivityTap(_ type: ActivityType) {
        switch type {
        case .breathing:
            showBreathingExercise = true
        case .focus:
            showDeepFocus = true
        case .coloring:
            showColoring = true
        case .journaling:
            showJournaling = true
        default:
            break
        }
    }

}

#Preview {
    HomeView()
        .environmentObject(Dependencies())
}
