import XCTest
@testable import stillpoint

@MainActor
final class AuthViewModelTests: XCTestCase {
    private var mockAuth: MockAuthRepository!
    private var sut: AuthViewModel!

    override func setUp() {
        super.setUp()
        mockAuth = MockAuthRepository()
        sut = AuthViewModel(auth: mockAuth)
    }

    override func tearDown() {
        sut = nil
        mockAuth = nil
        super.tearDown()
    }

    // MARK: - Login validation

    func test_login_emptyFields_setsErrorMessage() async {
        sut.loginEmail = ""
        sut.loginPassword = ""

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please fill in all fields.")
        XCTAssertEqual(mockAuth.loginCalls.count, 0)
    }

    func test_login_emptyEmail_setsErrorMessage() async {
        sut.loginEmail = ""
        sut.loginPassword = "password123"

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please fill in all fields.")
    }

    func test_login_emptyPassword_setsErrorMessage() async {
        sut.loginEmail = "test@example.com"
        sut.loginPassword = ""

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please fill in all fields.")
    }

    func test_login_invalidEmail_noAtSign_setsError() async {
        sut.loginEmail = "testexample.com"
        sut.loginPassword = "password123"

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(mockAuth.loginCalls.count, 0)
    }

    func test_login_invalidEmail_noDomain_setsError() async {
        sut.loginEmail = "test@"
        sut.loginPassword = "password123"

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(mockAuth.loginCalls.count, 0)
    }

    func test_login_invalidEmail_noDot_setsError() async {
        sut.loginEmail = "test@examplecom"
        sut.loginPassword = "password123"

        await sut.login()

        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(mockAuth.loginCalls.count, 0)
    }

    // MARK: - Login success/failure

    func test_login_success_clearsError() async {
        sut.loginEmail = "test@example.com"
        sut.loginPassword = "password123"
        sut.errorMessage = "Previous error"

        await sut.login()

        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuth.loginCalls.count, 1)
    }

    func test_login_failure_setsErrorMessage() async {
        sut.loginEmail = "test@example.com"
        sut.loginPassword = "wrong"
        mockAuth.loginError = TestError.networkFailure

        await sut.login()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Register validation

    func test_register_emptyFields_setsError() async {
        sut.registerUsername = ""
        sut.registerEmail = ""
        sut.registerPassword = ""

        await sut.register()

        XCTAssertEqual(sut.errorMessage, "Please fill in all fields.")
        XCTAssertEqual(mockAuth.registerCalls.count, 0)
    }

    func test_register_invalidEmail_setsError() async {
        sut.registerUsername = "testuser"
        sut.registerEmail = "notanemail"
        sut.registerPassword = "password123"
        sut.registerConfirmPassword = "password123"

        await sut.register()

        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(mockAuth.registerCalls.count, 0)
    }

    func test_register_passwordMismatch_setsError() async {
        sut.registerUsername = "testuser"
        sut.registerEmail = "test@example.com"
        sut.registerPassword = "password123"
        sut.registerConfirmPassword = "different"

        await sut.register()

        XCTAssertEqual(sut.errorMessage, "Passwords do not match.")
        XCTAssertEqual(mockAuth.registerCalls.count, 0)
    }

    func test_register_shortPassword_setsError() async {
        sut.registerUsername = "testuser"
        sut.registerEmail = "test@example.com"
        sut.registerPassword = "12345"
        sut.registerConfirmPassword = "12345"

        await sut.register()

        XCTAssertEqual(sut.errorMessage, "Password must be at least 6 characters.")
        XCTAssertEqual(mockAuth.registerCalls.count, 0)
    }

    // MARK: - Register success/failure

    func test_register_success_clearsError() async {
        sut.registerUsername = "testuser"
        sut.registerEmail = "test@example.com"
        sut.registerPassword = "password123"
        sut.registerConfirmPassword = "password123"
        sut.errorMessage = "Previous error"

        await sut.register()

        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuth.registerCalls.count, 1)
    }

    func test_register_failure_setsErrorMessage() async {
        sut.registerUsername = "testuser"
        sut.registerEmail = "test@example.com"
        sut.registerPassword = "password123"
        sut.registerConfirmPassword = "password123"
        mockAuth.registerError = TestError.mock

        await sut.register()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Password reset

    func test_requestPasswordReset_emptyEmail_setsError() async {
        sut.resetEmail = ""

        await sut.requestPasswordReset()

        XCTAssertEqual(sut.errorMessage, "Please enter your email.")
    }

    func test_requestPasswordReset_success_setsResetEmailSent() async {
        sut.resetEmail = "test@example.com"

        await sut.requestPasswordReset()

        XCTAssertTrue(sut.resetEmailSent)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuth.resetCalls.count, 1)
    }

    func test_requestPasswordReset_failure_setsErrorMessage() async {
        sut.resetEmail = "test@example.com"
        mockAuth.resetError = TestError.mock

        await sut.requestPasswordReset()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.resetEmailSent)
    }
}
