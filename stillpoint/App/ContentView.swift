import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var selectedTab: SPTab = .home
    @State private var isLoading = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if isLoading {
                AppLoadingView()
            } else if dependencies.isAuthenticated {
                mainApp
            } else if hasCompletedOnboarding {
                AuthContainerView(viewModel: AuthViewModel(auth: dependencies.auth))
            } else {
                OnboardingFlowView(auth: dependencies.auth) {
                    hasCompletedOnboarding = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: dependencies.isAuthenticated)
        .task {
            try? await Task.sleep(for: .seconds(3.5))
            withAnimation { isLoading = false }
        }
    }

    private var mainApp: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(SPTab.home)
                .tabItem {
                    Label(SPTab.home.label, systemImage: SPTab.home.systemImage)
                }

            JourneyView()
                .tag(SPTab.journey)
                .tabItem {
                    Label(SPTab.journey.label, systemImage: SPTab.journey.systemImage)
                }

            ScheduleView()
                .tag(SPTab.schedule)
                .tabItem {
                    Label(SPTab.schedule.label, systemImage: SPTab.schedule.systemImage)
                }

            ProfileView()
                .tag(SPTab.profile)
                .tabItem {
                    Label(SPTab.profile.label, systemImage: SPTab.profile.systemImage)
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Dependencies())
}
