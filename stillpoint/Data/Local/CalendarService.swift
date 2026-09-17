import EventKit
import Foundation

struct FreeSlot: Sendable {
    let start: Date
    let end: Date
    var duration: TimeInterval { end.timeIntervalSince(start) }
}

actor CalendarService {
    private let store = EKEventStore()

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    func findFreeSlots(on date: Date, minMinutes: Int = 15) -> [FreeSlot] {
        let calendar = Calendar.current
        let dayStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
        let dayEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date)!

        let predicate = store.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: nil)
        let events = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        var slots: [FreeSlot] = []
        var cursor = dayStart

        for event in events {
            if event.startDate > cursor {
                let gap = FreeSlot(start: cursor, end: event.startDate)
                if gap.duration >= Double(minMinutes * 60) {
                    slots.append(gap)
                }
            }
            if event.endDate > cursor {
                cursor = event.endDate
            }
        }

        // Gap after last event until end of day
        if cursor < dayEnd {
            let gap = FreeSlot(start: cursor, end: dayEnd)
            if gap.duration >= Double(minMinutes * 60) {
                slots.append(gap)
            }
        }

        return slots
    }
}
