import Foundation

protocol ActivityRepository: Sendable {
    func getActivities() async -> [Activity]
    func getActivity(id: UUID) async -> Activity?
}
