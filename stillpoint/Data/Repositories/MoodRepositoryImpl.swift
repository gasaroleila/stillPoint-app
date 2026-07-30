import Foundation
import FirebaseFirestore

struct MoodRepositoryImpl: MoodRepository {
    private let firestore: FirestoreService

    init(firestore: FirestoreService) {
        self.firestore = firestore
    }

    func logMood(_ mood: MoodType) async throws {
        let collection = try firestore.userCollection("moods")
        let data: [String: Any] = [
            "mood": mood.rawValue,
            "date": Timestamp(date: Date())
        ]
        try await collection.addDocument(data: data)
    }

    func getMoodHistory() async throws -> [MoodEntry] {
        let collection = try firestore.userCollection("moods")
        let snapshot = try await collection.order(by: "date", descending: true).getDocuments()
        return snapshot.documents.compactMap { doc in
            parseMoodEntry(doc)
        }
    }

    func getMoodHistory(from start: Date, to end: Date) async throws -> [MoodEntry] {
        let collection = try firestore.userCollection("moods")
        let snapshot = try await collection
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: end))
            .order(by: "date", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            parseMoodEntry(doc)
        }
    }

    private func parseMoodEntry(_ doc: QueryDocumentSnapshot) -> MoodEntry? {
        let data = doc.data()
        guard let moodRaw = data["mood"] as? String,
              let mood = MoodType(rawValue: moodRaw),
              let timestamp = data["date"] as? Timestamp else { return nil }
        return MoodEntry(
            id: UUID(uuidString: doc.documentID) ?? UUID(),
            mood: mood,
            date: timestamp.dateValue()
        )
    }
}
