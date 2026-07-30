import Foundation
import FirebaseFirestore

struct UserRepositoryImpl: UserRepository {
    private let firestore: FirestoreService

    init(firestore: FirestoreService) {
        self.firestore = firestore
    }

    func getProfile() async throws -> UserProfile {
        let doc = try firestore.userDocument()
        let snapshot = try await doc.getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            throw FirestoreServiceError.notAuthenticated
        }
        return UserProfile(
            id: UUID(uuidString: doc.documentID) ?? UUID(),
            name: data["username"] as? String ?? "",
            level: growthStageLevel(data["growthStage"] as? String),
            xp: data["xp"] as? Int ?? 0,
            totalActivities: data["totalActivities"] as? Int ?? 0
        )
    }

    func updateProfile(name: String) async throws {
        let doc = try firestore.userDocument()
        try await doc.updateData([
            "username": name,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func getStreak() async throws -> Streak {
        let doc = try firestore.userDocument().collection("streak").document("current")
        let snapshot = try await doc.getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return Streak(currentDays: 0, longestDays: 0, lastActivityDate: nil)
        }
        return Streak(
            currentDays: data["currentDays"] as? Int ?? 0,
            longestDays: data["longestDays"] as? Int ?? 0,
            lastActivityDate: (data["lastActivityDate"] as? Timestamp)?.dateValue()
        )
    }

    func getBadges() async throws -> [Badge] {
        let collection = try firestore.userCollection("badges")
        let snapshot = try await collection.getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let description = data["description"] as? String else { return nil }
            let earnedAt = (data["earnedAt"] as? Timestamp)?.dateValue()
            return Badge(
                id: UUID(uuidString: doc.documentID) ?? UUID(),
                name: name,
                description: description,
                isEarned: earnedAt != nil,
                earnedDate: earnedAt
            )
        }
    }

    func getGamificationStatus() async throws -> GamificationStatus {
        let profile = try await getProfile()
        let streak = try await getStreak()
        return GamificationStatus(
            xp: profile.xp,
            growthStage: GrowthStage(rawValue: growthStageName(profile.xp)) ?? .newborn,
            streakDays: streak.currentDays,
            longestStreak: streak.longestDays
        )
    }

    func getReport(period: ReportPeriod) async throws -> Report {
        let periodKey = reportPeriodKey(period)
        let doc = try firestore.userCollection("reports").document(periodKey)
        let snapshot = try await doc.getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return Report(period: period, activeDays: 0, restDays: 0, totalXP: 0, bestStreak: 0, activityBreakdown: [:])
        }
        var breakdown: [ActivityType: Int] = [:]
        if let rawBreakdown = data["activityBreakdown"] as? [String: Int] {
            for (key, value) in rawBreakdown {
                if let type = ActivityType(rawValue: key) {
                    breakdown[type] = value
                }
            }
        }
        return Report(
            period: period,
            activeDays: data["activeDays"] as? Int ?? 0,
            restDays: data["restDays"] as? Int ?? 0,
            totalXP: data["totalXP"] as? Int ?? 0,
            bestStreak: data["bestStreak"] as? Int ?? 0,
            activityBreakdown: breakdown
        )
    }

    // MARK: - Helpers

    private func growthStageLevel(_ stage: String?) -> Int {
        switch stage {
        case "sprouting": 2
        case "young": 3
        case "mature": 4
        default: 1
        }
    }

    private func growthStageName(_ xp: Int) -> String {
        switch xp {
        case 0...200: "newborn"
        case 201...1500: "sprouting"
        case 1501...8000: "young"
        default: "mature"
        }
    }

    private func reportPeriodKey(_ period: ReportPeriod) -> String {
        let now = Date()
        let calendar = Calendar.current
        switch period {
        case .week:
            let weekOfYear = calendar.component(.weekOfYear, from: now)
            let year = calendar.component(.yearForWeekOfYear, from: now)
            return String(format: "%d-W%02d", year, weekOfYear)
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: now)
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: now)
        }
    }
}
