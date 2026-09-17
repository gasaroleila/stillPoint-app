import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import stillpoint

final class DataIntegrationTests: XCTestCase {
    private var db: Firestore!
    private var firestore: FirestoreService!
    private var authRepo: AuthRepositoryImpl!
    private var createdUID: String?

    override func setUp() async throws {
        try await super.setUp()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
        authRepo = AuthRepositoryImpl()

        // Register a test user for all tests
        let email = "test-\(UUID().uuidString.prefix(8))@stillpoint-test.com"
        try await authRepo.register(username: "datatest", email: email, password: "TestPass123!", dateOfBirth: Date())
        createdUID = Auth.auth().currentUser?.uid

        firestore = FirestoreService { Auth.auth().currentUser?.uid }
    }

    override func tearDown() async throws {
        if let uid = createdUID {
            try? await cleanupTestUser(uid: uid)
        }
        try? await authRepo.logout()
        firestore = nil
        authRepo = nil
        db = nil
        createdUID = nil
        try await super.tearDown()
    }

    // MARK: - MoodRepository

    func test_mood_logAndRetrieve() async throws {
        let sut = MoodRepositoryImpl(firestore: firestore)

        try await sut.logMood(.happy)

        let history = try await sut.getMoodHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.mood, .happy)
    }

    func test_mood_multipleMoods_returnedInOrder() async throws {
        let sut = MoodRepositoryImpl(firestore: firestore)

        try await sut.logMood(.sad)
        try await Task.sleep(nanoseconds: 100_000_000)
        try await sut.logMood(.happy)

        let history = try await sut.getMoodHistory()
        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(history[0].mood, .happy, "Most recent mood should be first")
        XCTAssertEqual(history[1].mood, .sad)
    }

    func test_mood_getHistoryWithDateRange() async throws {
        let sut = MoodRepositoryImpl(firestore: firestore)

        try await sut.logMood(.neutral)

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let end = Calendar.current.date(byAdding: .hour, value: 1, to: now)!

        let history = try await sut.getMoodHistory(from: start, to: end)
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.mood, .neutral)
    }

    func test_mood_dateRangeExcludesOutsideMoods() async throws {
        let sut = MoodRepositoryImpl(firestore: firestore)

        try await sut.logMood(.stressed)

        // Query a range in the past that shouldn't include the mood we just logged
        let pastEnd = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let pastStart = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        let history = try await sut.getMoodHistory(from: pastStart, to: pastEnd)
        XCTAssertTrue(history.isEmpty)
    }

    // MARK: - ActivityRepository

    func test_activity_getActivities_returnsHardcodedCatalog() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)

        let activities = try await sut.getActivities()

        XCTAssertEqual(activities.count, 4)
        let types = Set(activities.map(\.type))
        XCTAssertTrue(types.contains(.breathing))
        XCTAssertTrue(types.contains(.focus))
        XCTAssertTrue(types.contains(.coloring))
        XCTAssertTrue(types.contains(.journaling))
    }

    func test_activity_getActivityById_returnsMatch() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)
        let activities = try await sut.getActivities()
        let first = activities[0]

        let found = try await sut.getActivity(id: first.id)

        XCTAssertEqual(found?.id, first.id)
        XCTAssertEqual(found?.type, first.type)
    }

    func test_activity_getActivityById_unknownId_returnsNil() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)

        let found = try await sut.getActivity(id: UUID())

        XCTAssertNil(found)
    }

    func test_activity_logCompletionAndRetrieve() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)

        try await sut.logCompletion(activityType: .breathing, duration: 300)

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let end = Calendar.current.date(byAdding: .hour, value: 1, to: now)!

        let completions = try await sut.getCompletions(from: start, to: end)
        XCTAssertEqual(completions.count, 1)
        XCTAssertEqual(completions.first?.activityType, .breathing)
        XCTAssertEqual(completions.first?.durationSeconds, 300)
        XCTAssertEqual(completions.first?.xpAwarded, 0)
    }

    func test_activity_multipleCompletions_allReturned() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)

        try await sut.logCompletion(activityType: .breathing, duration: 300)
        try await sut.logCompletion(activityType: .focus, duration: 1500)

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let end = Calendar.current.date(byAdding: .hour, value: 1, to: now)!

        let completions = try await sut.getCompletions(from: start, to: end)
        XCTAssertEqual(completions.count, 2)
        let types = Set(completions.map(\.activityType))
        XCTAssertTrue(types.contains(.breathing))
        XCTAssertTrue(types.contains(.focus))
    }

    func test_activity_todaySuggestions_emptyWhenNoneExist() async throws {
        let sut = ActivityRepositoryImpl(firestore: firestore)

        let suggestions = try await sut.getTodaySuggestions()
        XCTAssertTrue(suggestions.isEmpty)
    }

    // MARK: - UserRepository

    func test_user_getProfile_returnsRegisteredUser() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        let profile = try await sut.getProfile()

        XCTAssertEqual(profile.name, "datatest")
        XCTAssertEqual(profile.xp, 0)
        XCTAssertEqual(profile.totalActivities, 0)
        XCTAssertEqual(profile.level, 1)
    }

    func test_user_updateProfile_changesName() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        try await sut.updateProfile(name: "Updated Name")

        let profile = try await sut.getProfile()
        XCTAssertEqual(profile.name, "Updated Name")
    }

    func test_user_getStreak_returnsInitialStreak() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        let streak = try await sut.getStreak()

        XCTAssertEqual(streak.currentDays, 0)
        XCTAssertEqual(streak.longestDays, 0)
        XCTAssertNil(streak.lastActivityDate)
    }

    func test_user_getBadges_emptyInitially() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        let badges = try await sut.getBadges()

        XCTAssertTrue(badges.isEmpty)
    }

    func test_user_getGamificationStatus_returnsInitialStatus() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        let status = try await sut.getGamificationStatus()

        XCTAssertEqual(status.xp, 0)
        XCTAssertEqual(status.growthStage, .newborn)
        XCTAssertEqual(status.streakDays, 0)
        XCTAssertEqual(status.longestStreak, 0)
    }

    func test_user_getReport_emptyWhenNoData() async throws {
        let sut = UserRepositoryImpl(firestore: firestore)

        let report = try await sut.getReport(period: .week)

        XCTAssertEqual(report.period, .week)
        XCTAssertEqual(report.activeDays, 0)
        XCTAssertEqual(report.totalXP, 0)
        XCTAssertTrue(report.activityBreakdown.isEmpty)
    }

    // MARK: - Not authenticated

    func test_repositories_throwWhenNotAuthenticated() async {
        let noAuthFirestore = FirestoreService { nil }
        let moodRepo = MoodRepositoryImpl(firestore: noAuthFirestore)
        let activityRepo = ActivityRepositoryImpl(firestore: noAuthFirestore)
        let userRepo = UserRepositoryImpl(firestore: noAuthFirestore)

        do {
            try await moodRepo.logMood(.happy)
            XCTFail("Expected notAuthenticated error")
        } catch {
            XCTAssertEqual(error as? FirestoreServiceError, .notAuthenticated)
        }

        do {
            _ = try await activityRepo.logCompletion(activityType: .breathing, duration: 300)
            XCTFail("Expected notAuthenticated error")
        } catch {
            XCTAssertEqual(error as? FirestoreServiceError, .notAuthenticated)
        }

        do {
            _ = try await userRepo.getProfile()
            XCTFail("Expected notAuthenticated error")
        } catch {
            XCTAssertEqual(error as? FirestoreServiceError, .notAuthenticated)
        }
    }

    // MARK: - Cleanup

    private func cleanupTestUser(uid: String) async throws {
        let userDoc = db.collection("users").document(uid)

        // Delete subcollection docs
        for subcollection in ["moods", "completions", "badges", "suggestions", "reports", "streak"] {
            let snapshot = try await userDoc.collection(subcollection).getDocuments()
            for doc in snapshot.documents {
                try? await doc.reference.delete()
            }
        }

        // Delete user profile doc
        try? await userDoc.delete()

        // Delete Firebase Auth user
        try? await Auth.auth().currentUser?.delete()
    }
}
