import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [OnboardingProgress]
    @State private var selectedTab: SPTab = .home
    @State private var isLoading = true

    private var hasCompletedOnboarding: Bool {
        progressRecords.first?.isComplete ?? false
    }

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
                    // onComplete — auth state listener handles the transition
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: dependencies.isAuthenticated)
        .onChange(of: dependencies.isAuthenticated) { _, authenticated in
            if authenticated { selectedTab = .home }
        }
        .task {
            try? await Task.sleep(for: .seconds(3.5))
            // If user has a Firebase account but no local onboarding record, backfill it
            if dependencies.auth.currentUserId != nil && progressRecords.isEmpty {
                let progress = OnboardingProgress()
                progress.markComplete()
                modelContext.insert(progress)
            }
            print("[ContentView] Firebase userId: \(dependencies.auth.currentUserId ?? "nil")")
            print("[ContentView] isAuthenticated: \(dependencies.isAuthenticated)")
            print("[ContentView] progressRecords count: \(progressRecords.count)")
            if let record = progressRecords.first {
                print("[ContentView] step: \(record.step), isComplete: \(record.isComplete)")
            } else {
                print("[ContentView] No OnboardingProgress record found")
            }
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
        .tint(Color.spPrimary)
    }
}

#Preview {
    ContentView()
        .environmentObject(Dependencies())
}
