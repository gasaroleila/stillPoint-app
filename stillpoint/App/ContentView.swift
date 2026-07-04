import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tab.view
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }
}

enum Tab: CaseIterable {
    case home, journey, schedule, profile

    var title: String {
        switch self {
        case .home: "Home"
        case .journey: "Journey"
        case .schedule: "Schedule"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .journey: "chart.bar.fill"
        case .schedule: "calendar"
        case .profile: "person.fill"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomeView()
        case .journey: JourneyView()
        case .schedule: ScheduleView()
        case .profile: ProfileView()
        }
    }
}

#Preview {
    ContentView()
}
