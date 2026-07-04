import Foundation

struct ActivityRepositoryImpl: ActivityRepository {
    func getActivities() async -> [Activity] {
        Activity.samples
    }

    func getActivity(id: UUID) async -> Activity? {
        Activity.samples.first { $0.id == id }
    }
}

extension Activity {
    static let samples: [Activity] = [
        Activity(id: UUID(), type: .breathing, title: "Deep Breathing", description: "Calm your mind with guided breathing", durationMinutes: 5, xpReward: 20),
        Activity(id: UUID(), type: .focus, title: "Focus Timer", description: "Stay focused with a timed session", durationMinutes: 25, xpReward: 50),
        Activity(id: UUID(), type: .coloring, title: "Mindful Coloring", description: "Relax with creative coloring", durationMinutes: 15, xpReward: 30),
        Activity(id: UUID(), type: .journaling, title: "Journal Entry", description: "Reflect on your thoughts and feelings", durationMinutes: 10, xpReward: 25),
    ]
}
