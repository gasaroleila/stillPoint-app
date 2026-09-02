import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var viewModel: ProfileViewModel?

    private var vm: ProfileViewModel {
        if let viewModel { return viewModel }
        let created = ProfileViewModel(user: dependencies.user)
        DispatchQueue.main.async { viewModel = created }
        return created
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                pageHeader
                heroCard
                overviewCard
                badgesCard(title: "Milestones & Habits", items: milestoneBadges)
                badgesCard(title: "Activity Awards", items: activityAwards)
                logoutButton
                    .padding(.horizontal, SP.Padding.screenHorizontal)
                    .padding(.bottom, 32)
            }
            .padding(.top, 48)
        }
        .background(Color.spBackground)
        .onAppear { Task { await vm.load() } }
    }

    private var logoutButton: some View {
        Button {
            Task {
                try? await dependencies.auth.logout()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                Text("Sign Out")
                    .font(.custom("Nunito-ExtraBold", size: 14.4))
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(SP.Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: SP.Radius.card)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Profile")
                .font(.custom("Nunito-Black", size: 24))
                .foregroundStyle(Color.spTextPrimary)
            Text("Your progress and achievements")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    // MARK: - Hero card

    private var heroCard: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.spPrimary, Color(hex: 0xFFB800)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 6)

            ZStack(alignment: .top) {
                Color.spPrimary

                VStack(spacing: 12) {
                    levelPill
                    ZStack {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.white.opacity(0.45), Color.white.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            ))
                            .frame(width: 140, height: 140)
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 90, height: 90)
                        Image(systemName: vm.characterType.iconName)
                            .font(.system(size: 44))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 8)

                VStack {
                    Spacer()
                    Image("profile-separator-curve")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 200)

            VStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text(vm.userName)
                        .font(.custom("Nunito-Black", size: 19.2))
                        .foregroundStyle(Color.spTextPrimary)
                    Text("@\(vm.userName.lowercased()) · Joined June 2026")
                        .font(.custom("Nunito-SemiBold", size: 11.5))
                        .foregroundStyle(Color.spTextSecondary)
                }

                xpProgressBar
            }
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(SP.Radius.card)
        .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 16, x: 0, y: 2)
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    private var levelPill: some View {
        Text(vm.levelDisplay)
            .font(.custom("Nunito-ExtraBold", size: 10.4))
            .tracking(0.832)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.spOverlay)
            .cornerRadius(SP.Radius.pill)
    }

    private var xpProgressBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.spBackgroundAlt)
                        .frame(height: 8)
                    Capsule()
                        .fill(Color.spPrimary)
                        .frame(width: geo.size.width * vm.xpProgress, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text(vm.xpProgressText)
                    .font(.custom("Nunito-SemiBold", size: 10))
                    .foregroundStyle(Color.spTextSecondary)
                Spacer()
                if let next = vm.growthStage.next {
                    Text(next.label)
                        .font(.custom("Nunito-Bold", size: 10))
                        .foregroundStyle(Color.spStatusText)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Overview

    private var overviewCard: some View {
        SectionCard(title: "Overview") {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                overviewCell(icon: "flame.fill", value: "\(vm.streakDays)", label: "Day Streak")
                overviewCell(icon: "bolt.fill", value: "\(vm.xp)", label: "Total XP")
                overviewCell(icon: "leaf.fill", value: "\(vm.stagesAttained) / 4", label: "Growth Stages")
                overviewCell(icon: "star.fill", value: "\(vm.totalActivities)", label: "Activities")
            }
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    private func overviewCell(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.spTextPrimary)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.custom("Nunito-Black", size: 16))
                    .foregroundStyle(Color.spTextPrimary)
                Text(label)
                    .font(.custom("Nunito-SemiBold", size: 9.9))
                    .foregroundStyle(Color.spTextSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.spBackground)
        .cornerRadius(SP.Radius.icon)
    }

    // MARK: - Badges

    private func badgesCard(title: String, items: [ProfileBadge]) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.spSectionTitle)
                        .foregroundStyle(Color.spTextPrimary)
                    Spacer()
                    Button {} label: {
                        Text("VIEW ALL")
                            .font(.custom("Nunito-Bold", size: 9.9))
                            .tracking(0.397)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                    .buttonStyle(.plain)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { badge in
                            BadgeItem(iconAsset: badge.iconAsset, label: badge.label, isEarned: badge.isEarned)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    // MARK: - Badge definitions

    private var milestoneBadges: [ProfileBadge] {
        [
            ProfileBadge(iconAsset: "mood-tracking", label: "First Steps", badgeName: "First Steps"),
            ProfileBadge(iconAsset: "streak-freak", label: "In Rhythm", badgeName: "In Rhythm"),
            ProfileBadge(iconAsset: "weekly-consistency", label: "Second Nature", badgeName: "Second Nature"),
            ProfileBadge(iconAsset: "daily-xp-completion", label: "Taking Root", badgeName: "Taking Root"),
            ProfileBadge(iconAsset: "longterm-xp-consistency", label: "Deep Roots", badgeName: "Deep Roots"),
        ].map { badge in
            ProfileBadge(iconAsset: badge.iconAsset, label: badge.label, isEarned: vm.earnedBadgeIds.contains(badge.badgeName))
        }
    }

    private var activityAwards: [ProfileBadge] {
        [
            ProfileBadge(iconAsset: "breath-master", label: "Centering", badgeName: "Centering"),
            ProfileBadge(iconAsset: "focus-completion", label: "Clear Mind", badgeName: "Clear Mind"),
            ProfileBadge(iconAsset: "deep-thinker", label: "Quiet Pages", badgeName: "Quiet Pages"),
            ProfileBadge(iconAsset: "coloring-master", label: "Creative Flow", badgeName: "Creative Flow"),
            ProfileBadge(iconAsset: "breath-completion", label: "Full Spectrum", badgeName: "Full Spectrum"),
        ].map { badge in
            ProfileBadge(iconAsset: badge.iconAsset, label: badge.label, isEarned: vm.earnedBadgeIds.contains(badge.badgeName))
        }
    }
}

private struct ProfileBadge: Identifiable {
    let id = UUID()
    let iconAsset: String
    let label: String
    var isEarned: Bool = false
    var badgeName: String = ""
}

#Preview {
    ProfileView()
        .environmentObject(Dependencies())
}
