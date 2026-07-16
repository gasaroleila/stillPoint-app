import Foundation

struct MoodRepositoryImpl: MoodRepository {
    func logMood(_ mood: MoodType) async throws {
        // Stub — will write to Firestore in Phase 3
    }

    func getMoodHistory() async throws -> [MoodEntry] {
        []
    }

    func getMoodHistory(from: Date, to: Date) async throws -> [MoodEntry] {
        []
    }
}
