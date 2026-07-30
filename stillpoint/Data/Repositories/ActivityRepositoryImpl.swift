import Foundation
import FirebaseFirestore

struct ActivityRepositoryImpl: ActivityRepository {
    private let firestore: FirestoreService

    init(firestore: FirestoreService) {
        self.firestore = firestore
    }

    func getActivities() async throws -> [Activity] {
        Activity.samples
    }

    func getActivity(id: UUID) async throws -> Activity? {
        Activity.samples.first { $0.id == id }
    }

    func logCompletion(activityType: ActivityType, duration: Int) async throws {
        let collection = try firestore.userCollection("completions")
        let data: [String: Any] = [
            "activityType": activityType.rawValue,
            "completedAt": Timestamp(date: Date()),
            "durationSeconds": duration,
            "xpAwarded": 0  // Cloud Functions will calculate and update this
        ]
        try await collection.addDocument(data: data)
    }

    func getCompletions(from start: Date, to end: Date) async throws -> [ActivityCompletion] {
        let collection = try firestore.userCollection("completions")
        let snapshot = try await collection
            .whereField("completedAt", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("completedAt", isLessThanOrEqualTo: Timestamp(date: end))
            .order(by: "completedAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            parseCompletion(doc)
        }
    }

    func getTodaySuggestions() async throws -> [ActivitySuggestion] {
        let today = Calendar.current.startOfDay(for: Date())
        let dateString = ISO8601DateFormatter().string(from: today).prefix(10)
        let doc = try firestore.userCollection("suggestions").document(String(dateString))
        let snapshot = try await doc.getDocument()

        guard snapshot.exists,
              let data = snapshot.data(),
              let activities = data["activities"] as? [[String: Any]] else { return [] }

        return activities.compactMap { item in
            guard let typeRaw = item["activityType"] as? String,
                  let type = ActivityType(rawValue: typeRaw),
                  let statusRaw = item["status"] as? String,
                  let status = SuggestionStatus(rawValue: statusRaw) else { return nil }
            let scheduledTime = (item["scheduledTime"] as? Timestamp)?.dateValue()
            return ActivitySuggestion(
                id: typeRaw,
                activityType: type,
                scheduledTime: scheduledTime,
                status: status
            )
        }
    }

    func respondToSuggestion(id: String, action: SuggestionAction) async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let dateString = ISO8601DateFormatter().string(from: today).prefix(10)
        let doc = try firestore.userCollection("suggestions").document(String(dateString))
        let snapshot = try await doc.getDocument()

        guard snapshot.exists,
              let data = snapshot.data(),
              var activities = data["activities"] as? [[String: Any]] else { return }

        guard let index = activities.firstIndex(where: { ($0["activityType"] as? String) == id }) else { return }

        switch action {
        case .accept:
            activities[index]["status"] = SuggestionStatus.accepted.rawValue
        case .skip:
            activities[index]["status"] = SuggestionStatus.skipped.rawValue
        case .swap(let newType):
            activities[index]["status"] = SuggestionStatus.swapped.rawValue
            activities[index]["activityType"] = newType.rawValue
        }

        try await doc.updateData(["activities": activities])
    }

    private func parseCompletion(_ doc: QueryDocumentSnapshot) -> ActivityCompletion? {
        let data = doc.data()
        guard let typeRaw = data["activityType"] as? String,
              let type = ActivityType(rawValue: typeRaw),
              let timestamp = data["completedAt"] as? Timestamp,
              let duration = data["durationSeconds"] as? Int,
              let xp = data["xpAwarded"] as? Int else { return nil }
        return ActivityCompletion(
            id: doc.documentID,
            activityType: type,
            completedAt: timestamp.dateValue(),
            durationSeconds: duration,
            xpAwarded: xp
        )
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
