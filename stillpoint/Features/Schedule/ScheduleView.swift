import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var viewModel: ScheduleViewModel?

    private var vm: ScheduleViewModel {
        if let viewModel { return viewModel }
        let created = ScheduleViewModel(activities: dependencies.activities)
        DispatchQueue.main.async { viewModel = created }
        return created
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            pageHeader

            if vm.isCalendarConnected {
                connectedContent
            } else {
                connectCard
                Spacer(minLength: 0)
            }
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spBackground)
        .task { await vm.checkCalendarAccess() }
    }

    // MARK: - Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Schedule")
                .font(.custom("Nunito-Black", size: 24))
                .foregroundStyle(Color.spTextPrimary)
            Text(vm.isCalendarConnected
                 ? "Your self-care plan for today"
                 : "Self-care slotted into your day, automatically")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    // MARK: - Connect Card

    private var connectCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.spTextSecondary)
                .frame(width: 48, height: 48)
                .background(Color.spBackgroundAlt)
                .cornerRadius(SP.Radius.icon)

            VStack(alignment: .leading, spacing: 1) {
                Text("Connect your calendar")
                    .font(.custom("Nunito-ExtraBold", size: 14.4))
                    .foregroundStyle(Color.spTextPrimary)
                Text("We'll find gaps and fit in activities for you")
                    .font(.custom("Nunito-Regular", size: 11.5))
                    .foregroundStyle(Color.spTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task { await vm.connectCalendar() }
            } label: {
                Text("Connect")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.spPrimary)
                    .cornerRadius(SP.Radius.pill)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(SP.Radius.card)
        .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 16, x: 0, y: 2)
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    // MARK: - Connected Content

    private var connectedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if vm.scheduledActivities.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.scheduledActivities) { activity in
                        scheduleCard(activity)
                    }
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.spCaption)
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.bottom, 32)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 36))
                .foregroundStyle(Color.spTextSecondary)
            Text("No activities scheduled yet")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
            Text("Check back tomorrow for new suggestions")
                .font(.spCaption)
                .foregroundStyle(Color.spTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    // MARK: - Schedule Card

    private func scheduleCard(_ activity: ScheduledActivity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(activity.iconAsset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.spTextPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.spBackgroundAlt)
                    .cornerRadius(SP.Radius.icon)

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(.custom("Nunito-ExtraBold", size: 14.4))
                        .foregroundStyle(Color.spTextPrimary)

                    HStack(spacing: 8) {
                        if let time = activity.scheduledTime {
                            Label(time.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                                .font(.custom("Nunito-SemiBold", size: 11.5))
                                .foregroundStyle(Color.spTextSecondary)
                        }
                        Text(activity.durationText)
                            .font(.custom("Nunito-SemiBold", size: 11.5))
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }

                Spacer()

                statusBadge(activity)
            }

            if activity.status == .pending {
                actionButtons(activity)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(SP.Radius.card)
        .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 16, x: 0, y: 2)
    }

    private func statusBadge(_ activity: ScheduledActivity) -> some View {
        let label: String
        let fg: Color
        let bg: Color

        switch activity.status {
        case .accepted:
            label = "Accepted"
            fg = Color(hex: 0x2E7D32)
            bg = Color(hex: 0xE8F5E9)
        case .skipped:
            label = "Skipped"
            fg = Color.spTextSecondary
            bg = Color.spBackgroundAlt
        case .swapped:
            label = "Swapped"
            fg = Color.spTextSecondary
            bg = Color.spBackgroundAlt
        case .pending:
            label = activity.xpText
            fg = Color.spTextPrimary
            bg = Color.spPrimaryLight
        }

        return Text(label)
            .font(.custom("Nunito-Bold", size: 10.5))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .cornerRadius(SP.Radius.pill)
    }

    private func actionButtons(_ activity: ScheduledActivity) -> some View {
        HStack(spacing: 8) {
            Button {
                Task { await vm.acceptActivity(activity) }
            } label: {
                Text("Accept")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.spPrimary)
                    .cornerRadius(SP.Radius.pill)
            }
            .buttonStyle(.plain)

            Menu {
                ForEach(swapOptions(excluding: activity.type), id: \.self) { type in
                    Button(Self.activityNames[type] ?? type.rawValue) {
                        Task { await vm.swapActivity(activity, with: type) }
                    }
                }
            } label: {
                Text("Swap")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.spBackgroundAlt)
                    .cornerRadius(SP.Radius.pill)
            }

            Button {
                Task { await vm.skipActivity(activity) }
            } label: {
                Text("Skip")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.spBackgroundAlt)
                    .cornerRadius(SP.Radius.pill)
            }
            .buttonStyle(.plain)
        }
    }

    private func swapOptions(excluding current: ActivityType) -> [ActivityType] {
        ActivityType.allCases.filter { $0 != current }
    }

    private static let activityNames: [ActivityType: String] = [
        .breathing: "Box Breathing",
        .focus: "Deep Focus",
        .coloring: "Coloring",
        .journaling: "Journal",
    ]
}

#Preview {
    ScheduleView()
        .environmentObject(Dependencies())
}
