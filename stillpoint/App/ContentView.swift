import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var selectedTab: SPTab = .home

    var body: some View {
        Group {
            if dependencies.isAuthenticated {
                mainApp
            } else {
                AuthContainerView(viewModel: AuthViewModel(auth: dependencies.auth))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: dependencies.isAuthenticated)
    }

    private var mainApp: some View {
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
        .environmentObject(Dependencies())
}
