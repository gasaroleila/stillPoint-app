import Foundation

protocol ActivityRepository: Sendable {
    func getActivities() async throws -> [Activity]
    func getActivity(id: UUID) async throws -> Activity?
    func logCompletion(activityType: ActivityType, duration: Int) async throws
    func getCompletions(from: Date, to: Date) async throws -> [ActivityCompletion]
    func getTodaySuggestions() async throws -> [ActivitySuggestion]
    func respondToSuggestion(id: String, action: SuggestionAction) async throws
}
