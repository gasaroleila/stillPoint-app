import Foundation

protocol MoodRepository: Sendable {
    func logMood(_ mood: MoodType) async
    func getMoodHistory() async -> [MoodEntry]
}
