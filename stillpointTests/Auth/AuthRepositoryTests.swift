import XCTest
@testable import stillpoint

final class AuthRepositoryTests: XCTestCase {
    private var mockAuthService: MockAuthService!
    private var sut: AuthRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = AuthRepositoryImpl(authService: mockAuthService)
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Auth State Listening

    func test_startListening_callsAuthService() async {
        let expectation = XCTestExpectation(description: "onChange called")
        sut.startListening { _ in
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        let count = await mockAuthService.startListeningCallCount
        XCTAssertEqual(count, 1)
    }

    func test_startListening_updatesIsAuthenticated_whenTrue() async {
        await mockAuthService.setAuthState(authenticated: true, userId: "user-123")

        let expectation = XCTestExpectation(description: "onChange called")
        sut.startListening { authenticated in
            XCTAssertTrue(authenticated)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        // Allow MainActor task to complete
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUserId, "user-123")
    }

    func test_startListening_updatesIsAuthenticated_whenFalse() async {
        await mockAuthService.setAuthState(authenticated: false, userId: nil)

        let expectation = XCTestExpectation(description: "onChange called")
        sut.startListening { authenticated in
            XCTAssertFalse(authenticated)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUserId)
    }

    func test_startListening_respondsToAuthStateChange() async {
        let initialExpectation = XCTestExpectation(description: "initial onChange")
        let changeExpectation = XCTestExpectation(description: "state change onChange")
        let callCounter = CallCounter()

        sut.startListening { authenticated in
            Task {
                let count = await callCounter.increment()
                if count == 1 {
                    XCTAssertFalse(authenticated)
                    initialExpectation.fulfill()
                } else if count == 2 {
                    XCTAssertTrue(authenticated)
                    changeExpectation.fulfill()
                }
            }
        }
        await fulfillment(of: [initialExpectation], timeout: 1.0)

        await mockAuthService.simulateAuthStateChange(authenticated: true, userId: "new-user")
        await fulfillment(of: [changeExpectation], timeout: 1.0)

        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUserId, "new-user")
    }

    // MARK: - MFA

    func test_setupMFA_returnsVerificationID() async throws {
        await mockAuthService.setMFAVerificationID("test-vid")
        let vid = try await sut.setupMFA(phoneNumber: "+15551234567")
        XCTAssertEqual(vid, "test-vid")
    }

    func test_verifyMFA_doesNotThrow() async throws {
        await mockAuthService.setMFAVerificationID("test-vid")
        try await sut.verifyMFA(code: "123456", verificationID: "test-vid")
    }

    // MARK: - Login

    func test_login_success_returnsAuthenticated() async throws {
        let result = try await sut.login(email: "test@example.com", password: "password123")

        XCTAssertEqual(result, .authenticated)
        let calls = await mockAuthService.loginCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.first?.email, "test@example.com")
        XCTAssertEqual(calls.first?.password, "password123")
    }

    func test_login_failure_propagatesError() async {
        await mockAuthService.setLoginError(TestError.networkFailure)

        do {
            _ = try await sut.login(email: "test@example.com", password: "wrong")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .networkFailure)
        }
    }

    // MARK: - Register

    func test_register_success_callsAuthService() async throws {
        await mockAuthService.setRegisterResult(.success("uid-abc"))

        // Note: This will attempt Firestore writes which will fail without a real Firestore instance.
        // Full register testing (including Firestore writes) comes in Step 2 with MockFirestoreService.
        // For now, we verify the AuthService call is made correctly.
        do {
            try await sut.register(
                username: "testuser",
                email: "test@example.com",
                password: "password123",
                dateOfBirth: Date(timeIntervalSince1970: 0)
            )
        } catch {
            // Expected: Firestore write will fail in test environment
        }

        let calls = await mockAuthService.registerCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.first?.email, "test@example.com")
        XCTAssertEqual(calls.first?.password, "password123")
    }

    func test_register_authFailure_propagatesError() async {
        await mockAuthService.setRegisterResult(.failure(TestError.mock))

        do {
            try await sut.register(
                username: "testuser",
                email: "test@example.com",
                password: "password123",
                dateOfBirth: Date()
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .mock)
        }
    }

    // MARK: - Logout

    func test_logout_callsAuthService() async throws {
        try await sut.logout()

        let count = await mockAuthService.logoutCallCount
        XCTAssertEqual(count, 1)
    }

    func test_logout_failure_propagatesError() async {
        await mockAuthService.setLogoutError(TestError.mock)

        do {
            try await sut.logout()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .mock)
        }
    }

    // MARK: - Password Reset

    func test_requestPasswordReset_callsAuthService() async throws {
        try await sut.requestPasswordReset(email: "test@example.com")

        let calls = await mockAuthService.resetCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.first, "test@example.com")
    }

    func test_requestPasswordReset_failure_propagatesError() async {
        await mockAuthService.setResetError(TestError.mock)

        do {
            try await sut.requestPasswordReset(email: "test@example.com")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .mock)
        }
    }
}
