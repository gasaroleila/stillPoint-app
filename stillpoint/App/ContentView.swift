import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SPTab = .home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .journey: JourneyView()
                case .schedule: ScheduleView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(selection: $selectedTab)
        }
        .background(Color.spBackground)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ContentView()
}
