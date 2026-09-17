import Foundation

@MainActor
@Observable
final class JourneyViewModel {
    var report: Report?
    var isLoading = false
    var errorMessage: String?

    private let user: any UserRepository
    private var loadedPeriods: Set<ReportPeriod> = []
    private var reports: [ReportPeriod: Report] = [:]

    init(user: any UserRepository) {
        self.user = user
    }

    func loadReport(for period: ReportPeriod) async {
        if reports[period] != nil { return }
        isLoading = true
        do {
            let fetched = try await user.getReport(period: period)
            reports[period] = fetched
            report = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func switchPeriod(to period: ReportPeriod) async {
        if let cached = reports[period] {
            report = cached
        } else {
            await loadReport(for: period)
        }
    }

    // MARK: - Chart data

    var chartBars: [ChartBar] {
        guard let report, !report.dailyActivity.isEmpty else { return [] }

        if report.period == .year {
            return yearlyChartBars(from: report.dailyActivity)
        }

        let maxCount = report.dailyActivity.map(\.count).max() ?? 1
        let effectiveMax = max(maxCount, 1)

        return report.dailyActivity.map { day in
            let label = chartLabel(for: day.date, period: report.period)
            let color = barColor(count: day.count)
            let height: CGFloat = day.count == 0
                ? 4
                : CGFloat(day.count) / CGFloat(effectiveMax) * 136
            return ChartBar(day: label, color: color, height: height)
        }
    }

    private func yearlyChartBars(from daily: [DailyActivity]) -> [ChartBar] {
        let calendar = Calendar.current
        var monthlyTotals: [Int: Int] = [:]

        for day in daily {
            guard let date = Self.dateFormatter.date(from: day.date) else { continue }
            let month = calendar.component(.month, from: date)
            monthlyTotals[month, default: 0] += day.count
        }

        let maxCount = max(monthlyTotals.values.max() ?? 1, 1)

        return (1...12).map { month in
            let count = monthlyTotals[month] ?? 0
            let label = calendar.veryShortMonthSymbols[month - 1]
            let color = barColor(count: count)
            let height: CGFloat = count == 0
                ? 4
                : CGFloat(count) / CGFloat(maxCount) * 136
            return ChartBar(day: label, color: color, height: height)
        }
    }

    private func barColor(count: Int) -> ChartBarColor {
        switch count {
        case 0: return .empty
        case 1: return .light
        case 2: return .medium
        default: return .full
        }
    }

    private func chartLabel(for dateString: String, period: ReportPeriod) -> String {
        guard let date = Self.dateFormatter.date(from: dateString) else { return "" }
        let calendar = Calendar.current

        switch period {
        case .week:
            let symbols = calendar.veryShortWeekdaySymbols
            let weekday = calendar.component(.weekday, from: date)
            return symbols[weekday - 1]
        case .month:
            let day = calendar.component(.day, from: date)
            return [1, 6, 11, 16, 21, 26].contains(day) ? "\(day)" : ""
        case .year:
            let month = calendar.component(.month, from: date)
            return calendar.veryShortMonthSymbols[month - 1]
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Stats

    var stats: [StatItem] {
        guard let report else { return [] }
        let totalDays = report.activeDays + report.restDays
        let avg = totalDays > 0
            ? String(format: "%.1f/day", Double(report.activeDays) / Double(totalDays))
            : "0/day"
        return [
            StatItem(iconSystemName: "chart.line.uptrend.xyaxis", value: avg, label: "AVG"),
            StatItem(iconSystemName: "flame.fill", value: "\(report.bestStreak) days", label: "Best Streak"),
            StatItem(iconSystemName: "bolt.fill", value: formatXP(report.totalXP), label: "Total XP"),
        ]
    }

    private func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return (formatter.string(from: NSNumber(value: xp)) ?? "\(xp)") + " XP"
        }
        return "\(xp) XP"
    }

    // MARK: - Breakdown

    var breakdown: [BreakdownItem] {
        guard let report else { return [] }
        return [
            breakdownItem(type: .journaling, label: "Journal", iconAsset: "journal", bg: .journal, breakdown: report.activityBreakdown),
            breakdownItem(type: .breathing, label: "Breathing", iconAsset: "breathing", bg: .breathing, breakdown: report.activityBreakdown),
            breakdownItem(type: .focus, label: "Focus", iconAsset: "focus", bg: .focus, breakdown: report.activityBreakdown),
            breakdownItem(type: .coloring, label: "Coloring", iconAsset: "coloring", bg: .coloring, breakdown: report.activityBreakdown),
        ]
    }

    private func breakdownItem(type: ActivityType, label: String, iconAsset: String, bg: BreakdownBg, breakdown: [ActivityType: Int]) -> BreakdownItem {
        let count = breakdown[type] ?? 0
        return BreakdownItem(iconAsset: iconAsset, count: "\(count)x", label: label, bg: bg)
    }

    // MARK: - Mood summary

    var dominantMood: MoodType? {
        guard let report, !report.moodBreakdown.isEmpty else { return nil }
        return report.moodBreakdown.max(by: { $0.value < $1.value })?.key
    }

    var moodSummaryText: String? {
        guard let mood = dominantMood else { return nil }
        return "Mostly \(mood.label)"
    }

    // MARK: - Status

    var hasData: Bool {
        report != nil && !report!.dailyActivity.isEmpty
    }
}

// MARK: - View data types

struct ChartBar {
    let day: String
    let color: ChartBarColor
    let height: CGFloat
}

enum ChartBarColor {
    case empty, light, medium, full
}

struct BreakdownItem {
    let iconAsset: String
    let count: String
    let label: String
    let bg: BreakdownBg
}

enum BreakdownBg {
    case journal, breathing, focus, coloring
}
