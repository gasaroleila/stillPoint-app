import SwiftUI
import SwiftData
import FirebaseCore

@main
struct stillpointApp: App {
    @StateObject private var dependencies = Dependencies()

    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencies)
        }
        .modelContainer(for: [LocalJournalEntry.self])
    }
}
