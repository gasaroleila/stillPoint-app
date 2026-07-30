import XCTest
@testable import stillpoint
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

final class AuthIntegrationTests: XCTestCase {
    private var sut: AuthRepositoryImpl!
    private var db: Firestore!
    private var createdUID: String?

    override func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
        sut = AuthRepositoryImpl()
    }

    override func tearDown() async throws {
        if let uid = createdUID {
            try? await cleanupTestUser(uid: uid)
        }
        try? await sut.logout()
        sut = nil
        db = nil
        createdUID = nil
        try await super.tearDown()
    }

    // MARK: - Register

    func test_register_createsFirebaseUserAndFirestoreDocs() async throws {
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        let password = "TestPass123!"
        let username = "testuser"
        let dob = Date(timeIntervalSince1970: 946684800) // 2000-01-01

        try await sut.register(username: username, email: email, password: password, dateOfBirth: dob)

        // Capture UID for cleanup
        let user = Auth.auth().currentUser
        XCTAssertNotNil(user, "Firebase Auth user should exist after register")
        createdUID = user?.uid

        guard let uid = createdUID else { return }

        // Verify profile doc in Firestore
        let profileDoc = try await db.collection("users").document(uid).getDocument()
        XCTAssertTrue(profileDoc.exists, "Profile document should exist in Firestore")
        XCTAssertEqual(profileDoc.data()?["username"] as? String, username)
        XCTAssertEqual(profileDoc.data()?["email"] as? String, email)
        XCTAssertEqual(profileDoc.data()?["xp"] as? Int, 0)
        XCTAssertEqual(profileDoc.data()?["growthStage"] as? String, "newborn")
        XCTAssertEqual(profileDoc.data()?["totalActivities"] as? Int, 0)

        // Verify streak doc in Firestore
        let streakDoc = try await db.collection("users").document(uid).collection("streak").document("current").getDocument()
        XCTAssertTrue(streakDoc.exists, "Streak document should exist in Firestore")
        XCTAssertEqual(streakDoc.data()?["currentDays"] as? Int, 0)
        XCTAssertEqual(streakDoc.data()?["longestDays"] as? Int, 0)
    }

    // MARK: - Login

    func test_login_authenticatesExistingUser() async throws {
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        let password = "TestPass123!"

        // Create user first
        try await sut.register(username: "logintest", email: email, password: password, dateOfBirth: Date())
        createdUID = Auth.auth().currentUser?.uid

        // Logout then login
        try await sut.logout()
        let result = try await sut.login(email: email, password: password)

        XCTAssertEqual(result, .authenticated)
        XCTAssertNotNil(Auth.auth().currentUser)
    }

    func test_login_wrongPassword_throwsError() async throws {
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        let password = "TestPass123!"

        // Create user first
        try await sut.register(username: "wrongpw", email: email, password: password, dateOfBirth: Date())
        createdUID = Auth.auth().currentUser?.uid
        try await sut.logout()

        do {
            _ = try await sut.login(email: email, password: "WrongPassword!")
            XCTFail("Expected login with wrong password to throw")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Logout

    func test_logout_signsOutUser() async throws {
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        let password = "TestPass123!"

        try await sut.register(username: "logouttest", email: email, password: password, dateOfBirth: Date())
        createdUID = Auth.auth().currentUser?.uid
        XCTAssertNotNil(Auth.auth().currentUser)

        try await sut.logout()

        XCTAssertNil(Auth.auth().currentUser)
    }

    // MARK: - Password Reset

    func test_requestPasswordReset_validEmail_doesNotThrow() async throws {
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        let password = "TestPass123!"

        try await sut.register(username: "resettest", email: email, password: password, dateOfBirth: Date())
        createdUID = Auth.auth().currentUser?.uid

        try await sut.requestPasswordReset(email: email)
        // No error = Firebase accepted the request
    }

    // MARK: - Cleanup

    private func cleanupTestUser(uid: String) async throws {
        // Delete Firestore docs
        try? await db.collection("users").document(uid).collection("streak").document("current").delete()
        try? await db.collection("users").document(uid).delete()

        // Delete Firebase Auth user
        try? await Auth.auth().currentUser?.delete()
    }
}
