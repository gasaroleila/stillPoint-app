import XCTest
import FirebaseFirestore
@testable import stillpoint

final class FirestoreServiceTests: XCTestCase {

    // MARK: - userDocument

    func test_userDocument_noUserId_throwsNotAuthenticated() {
        let sut = FirestoreService { nil }

        XCTAssertThrowsError(try sut.userDocument()) { error in
            XCTAssertEqual(error as? FirestoreServiceError, .notAuthenticated)
        }
    }

    func test_userDocument_withUserId_returnsCorrectPath() throws {
        let sut = FirestoreService { "test-uid-123" }

        let doc = try sut.userDocument()

        XCTAssertEqual(doc.documentID, "test-uid-123")
        XCTAssertEqual(doc.parent.collectionID, "users")
    }

    // MARK: - userCollection

    func test_userCollection_noUserId_throwsNotAuthenticated() {
        let sut = FirestoreService { nil }

        XCTAssertThrowsError(try sut.userCollection("moods")) { error in
            XCTAssertEqual(error as? FirestoreServiceError, .notAuthenticated)
        }
    }

    func test_userCollection_withUserId_returnsCorrectPath() throws {
        let sut = FirestoreService { "test-uid-123" }

        let collection = try sut.userCollection("moods")

        XCTAssertEqual(collection.collectionID, "moods")
        XCTAssertEqual(collection.parent?.documentID, "test-uid-123")
    }

    func test_userCollection_differentNames_returnDifferentPaths() throws {
        let sut = FirestoreService { "uid" }

        let moods = try sut.userCollection("moods")
        let completions = try sut.userCollection("completions")
        let badges = try sut.userCollection("badges")

        XCTAssertEqual(moods.collectionID, "moods")
        XCTAssertEqual(completions.collectionID, "completions")
        XCTAssertEqual(badges.collectionID, "badges")
    }

    // MARK: - Error description

    func test_notAuthenticatedError_hasDescription() {
        let error = FirestoreServiceError.notAuthenticated
        XCTAssertNotNil(error.errorDescription)
    }
}
