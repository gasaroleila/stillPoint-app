import Foundation

struct MoodRepositoryImpl: MoodRepository {
    func logMood(_ mood: MoodType) async {
        // Local-only stub — will persist via SwiftData later
    }

    func getMoodHistory() async -> [MoodEntry] {
        []
    }
}
