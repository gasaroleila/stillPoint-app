import FirebaseFirestore

final class FirestoreService: @unchecked Sendable {
    let db: Firestore
    private let userIdProvider: @Sendable () -> String?

    init(db: Firestore = Firestore.firestore(), userIdProvider: @escaping @Sendable () -> String?) {
        self.db = db
        self.userIdProvider = userIdProvider
    }

    func userDocument() throws -> DocumentReference {
        guard let uid = userIdProvider() else { throw FirestoreServiceError.notAuthenticated }
        return db.collection("users").document(uid)
    }

    func userCollection(_ name: String) throws -> CollectionReference {
        try userDocument().collection(name)
    }
}

enum FirestoreServiceError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: "You must be signed in to perform this action."
        }
    }
}
