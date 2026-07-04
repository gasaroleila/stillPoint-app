import SwiftUI

enum SPTab: String, CaseIterable, Identifiable {
    case home, journey, schedule, profile

    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: return "Home"
        case .journey: return "Journey"
        case .schedule: return "Schedule"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .journey: return "chart.bar"
        case .schedule: return "calendar"
        case .profile: return "person"
        }
    }
}

struct TabBarView: View {
    @Binding var selection: SPTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SPTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8.77)
        .padding(.bottom, 20)
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.spBorder)
                .frame(height: 0.77)
        }
    }

    @ViewBuilder
    private func tabButton(for tab: SPTab) -> some View {
        let isActive = selection == tab
        Button {
            selection = tab
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isActive {
                        Circle()
                            .fill(Color.spPrimary)
                            .frame(width: SP.Size.tabActiveCircle, height: SP.Size.tabActiveCircle)
                    }
                    Image(systemName: tab.systemImage)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(isActive ? Color.spTextPrimary : Color.spTextSecondary)
                        .frame(width: SP.Size.tabIcon, height: SP.Size.tabIcon)
                }
                .frame(height: SP.Size.tabActiveCircle)

                Text(tab.label)
                    .font(isActive ? .spTabLabelActive : .spTabLabelInactive)
                    .tracking(0.208)
                    .foregroundStyle(isActive ? Color.spPrimary : Color.spTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
