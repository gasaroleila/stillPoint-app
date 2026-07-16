import Foundation

protocol MoodRepository: Sendable {
    func logMood(_ mood: MoodType) async throws
    func getMoodHistory() async throws -> [MoodEntry]
    func getMoodHistory(from: Date, to: Date) async throws -> [MoodEntry]
}
