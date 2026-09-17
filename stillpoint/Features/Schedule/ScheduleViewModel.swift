import Foundation
import UserNotifications

struct ScheduledActivity: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let iconAsset: String
    let xpText: String
    let durationText: String
    var scheduledTime: Date?
    var status: SuggestionStatus
}

@MainActor
@Observable
final class ScheduleViewModel {
    var isCalendarConnected = false
    var scheduledActivities: [ScheduledActivity] = []
    var isLoading = false
    var errorMessage: String?

    private let activities: any ActivityRepository
    private let calendarService = CalendarService()

    init(activities: any ActivityRepository) {
        self.activities = activities
    }

    func checkCalendarAccess() async {
        isCalendarConnected = await calendarService.hasAccess
        if isCalendarConnected {
            await loadSchedule()
        }
    }

    func connectCalendar() async {
        let granted = await calendarService.requestAccess()
        print("[Schedule] Calendar access granted: \(granted)")
        isCalendarConnected = granted
        if granted {
            await requestNotificationPermission()
            await loadSchedule()
        } else {
            errorMessage = "Calendar access is required to schedule activities. You can enable it in Settings."
        }
    }

    func loadSchedule() async {
        isLoading = true
        errorMessage = nil
        do {
            let suggestions = try await activities.getTodaySuggestions()
            let slots = await calendarService.findFreeSlots(on: Date())

            scheduledActivities = assignTimesToSuggestions(suggestions, freeSlots: slots)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func acceptActivity(_ activity: ScheduledActivity) async {
        guard let index = scheduledActivities.firstIndex(where: { $0.id == activity.id }) else { return }
        do {
            try await activities.respondToSuggestion(id: activity.id, action: .accept)
            scheduledActivities[index].status = .accepted
            if let time = scheduledActivities[index].scheduledTime {
                scheduleNotification(for: scheduledActivities[index], at: time)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func skipActivity(_ activity: ScheduledActivity) async {
        guard let index = scheduledActivities.firstIndex(where: { $0.id == activity.id }) else { return }
        do {
            try await activities.respondToSuggestion(id: activity.id, action: .skip)
            scheduledActivities[index].status = .skipped
            cancelNotification(for: activity.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func swapActivity(_ activity: ScheduledActivity, with newType: ActivityType) async {
        guard let index = scheduledActivities.firstIndex(where: { $0.id == activity.id }) else { return }
        do {
            try await activities.respondToSuggestion(id: activity.id, action: .swap(newActivityType: newType))
            let meta = Self.activityMeta[newType]!
            scheduledActivities[index] = ScheduledActivity(
                id: newType.rawValue,
                type: newType,
                title: meta.title,
                iconAsset: meta.iconAsset,
                xpText: meta.xpText,
                durationText: meta.durationText,
                scheduledTime: scheduledActivities[index].scheduledTime,
                status: .pending
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func assignTimesToSuggestions(_ suggestions: [ActivitySuggestion], freeSlots: [FreeSlot]) -> [ScheduledActivity] {
        var result: [ScheduledActivity] = []
        var slotIndex = 0

        for suggestion in suggestions {
            guard let meta = Self.activityMeta[suggestion.activityType] else { continue }

            var time: Date? = suggestion.scheduledTime
            if time == nil, slotIndex < freeSlots.count {
                time = freeSlots[slotIndex].start
                slotIndex += 1
            }

            result.append(ScheduledActivity(
                id: suggestion.id,
                type: suggestion.activityType,
                title: meta.title,
                iconAsset: meta.iconAsset,
                xpText: meta.xpText,
                durationText: meta.durationText,
                scheduledTime: time,
                status: suggestion.status
            ))
        }
        return result
    }

    // MARK: - Notifications

    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    private func scheduleNotification(for activity: ScheduledActivity, at time: Date) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "StillPoint"
        content.body = "\(activity.title) starts in 5 minutes"
        content.sound = .default

        // 5 minutes before
        let triggerDate = time.addingTimeInterval(-5 * 60)
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "activity-\(activity.id)", content: content, trigger: trigger)
        center.add(request)
    }

    private func cancelNotification(for id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["activity-\(id)"])
    }

    // MARK: - Metadata

    private static let activityMeta: [ActivityType: (title: String, iconAsset: String, xpText: String, durationText: String)] = [
        .breathing: ("Box Breathing", "breathing", "+20 XP", "~2 min"),
        .focus: ("Deep Focus", "focus", "+50 XP", "20 min"),
        .coloring: ("Coloring", "coloring", "+30 XP", "5 min"),
        .journaling: ("Journal", "journal", "+25 XP", "~10 min"),
    ]
}
