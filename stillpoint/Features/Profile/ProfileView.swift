import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                pageHeader
                heroCard
                overviewCard
                badgesCard(title: "Monthly Badges", items: monthlyBadges)
                badgesCard(title: "Activity Awards", items: activityAwards)
                    .padding(.bottom, 32)
            }
            .padding(.top, 48)
        }
        .background(Color.spBackground)
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
                    Image("sample-character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .background(
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color.white.opacity(0.45), Color.white.opacity(0)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                ))
                                .frame(width: 140, height: 140)
                        )
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

            VStack(spacing: 2) {
                Text("Anne")
                    .font(.custom("Nunito-Black", size: 19.2))
                    .foregroundStyle(Color.spTextPrimary)
                Text("@anne · Joined June 2026")
                    .font(.custom("Nunito-SemiBold", size: 11.5))
                    .foregroundStyle(Color.spTextSecondary)
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
        Text("LVL 4 · 308 XP")
            .font(.custom("Nunito-ExtraBold", size: 10.4))
            .tracking(0.832)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.spOverlay)
            .cornerRadius(SP.Radius.pill)
    }

    // MARK: - Overview

    private var overviewCard: some View {
        SectionCard(title: "Overview") {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                overviewCell(icon: "flame.fill", value: "7", label: "Day Streak")
                overviewCell(icon: "bolt.fill", value: "308", label: "Total XP")
                overviewCell(icon: "trophy.fill", value: "Gold", label: "League")
                overviewCell(icon: "star.fill", value: "21", label: "Activities")
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

    // MARK: - Mock data

    private var monthlyBadges: [ProfileBadge] {
        [
            ProfileBadge(iconAsset: "streak-freak", label: "7-Day Streak", isEarned: true),
            ProfileBadge(iconAsset: "breath-master", label: "Breath Master", isEarned: true),
            ProfileBadge(iconAsset: "coloring-master", label: "First Color", isEarned: true),
            ProfileBadge(iconAsset: "deep-thinker", label: "Deep Thinker", isEarned: false),
            ProfileBadge(iconAsset: "mood-tracking", label: "Mood Tracker", isEarned: false),
        ]
    }

    private var activityAwards: [ProfileBadge] {
        [
            ProfileBadge(iconAsset: "focus-completion", label: "First Focus", isEarned: true),
            ProfileBadge(iconAsset: "breath-completion", label: "Calm Breath", isEarned: true),
            ProfileBadge(iconAsset: "daily-xp-completion", label: "Goal Getter", isEarned: true),
            ProfileBadge(iconAsset: "weekly-consistency", label: "Week Warrior", isEarned: false),
            ProfileBadge(iconAsset: "longterm-xp-consistency", label: "XP Hunter", isEarned: false),
        ]
    }
}

private struct ProfileBadge: Identifiable {
    let id = UUID()
    let iconAsset: String
    let label: String
    let isEarned: Bool
}

#Preview {
    ProfileView()
}
