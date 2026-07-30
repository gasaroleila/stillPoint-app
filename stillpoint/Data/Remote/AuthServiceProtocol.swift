import Foundation

protocol AuthServiceProtocol: Sendable {
    var isAuthenticated: Bool { get async }
    var currentUserId: String? { get async }
    func startListening(onChange: @escaping @Sendable (Bool, String?) -> Void) async
    func stopListening() async
    func register(email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws
    func logout() async throws
    func requestPasswordReset(email: String) async throws
}
