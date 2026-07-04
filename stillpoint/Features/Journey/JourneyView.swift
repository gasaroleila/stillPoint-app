import SwiftUI

enum JourneyPeriod: String, CaseIterable {
    case week, month, year

    var label: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var chartTitle: String {
        switch self {
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}

struct JourneyView: View {
    @State private var period: JourneyPeriod = .week

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                pageHeader
                SegmentedControl(
                    options: JourneyPeriod.allCases.map { ($0, $0.label) },
                    selection: $period
                )
                .padding(.horizontal, SP.Padding.screenHorizontal)

                chartCard
                    .padding(.horizontal, SP.Padding.screenHorizontal)

                StatsRow(items: currentStats)
                    .padding(.horizontal, SP.Padding.screenHorizontal)

                activityBreakdown
                    .padding(.horizontal, SP.Padding.screenHorizontal)
                    .padding(.bottom, 32)
            }
            .padding(.top, 48)
        }
        .background(Color.spBackground)
    }

    // MARK: - Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Your Journey")
                .font(.custom("Nunito-Black", size: 24))
                .foregroundStyle(Color.spTextPrimary)
            Text("How you're taking care of yourself")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Chart card

    private var chartCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(period.chartTitle)
                        .font(.spSectionTitle)
                        .foregroundStyle(Color.spTextPrimary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.spStatusText)
                        Text("On track")
                            .font(.custom("Nunito-Bold", size: 11.2))
                            .foregroundStyle(Color.spStatusText)
                    }
                }

                barChart

                Divider().overlay(Color(hex: 0xF0EDE8))

                HStack(spacing: 12) {
                    legendItem(color: .spPrimary, label: "Active day")
                    legendItem(color: .spChartEmpty, label: "Rest day")
                }
            }
        }
    }

    private var barChart: some View {
        let showTrack = period == .week
        let spacing: CGFloat = period == .week ? SP.Spacing.chartBarGap : 3
        return HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(chartBars.enumerated()), id: \.offset) { _, bar in
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        if showTrack {
                            Capsule()
                                .fill(Color.spBackgroundAlt)
                                .frame(height: 140)
                        } else {
                            Color.clear.frame(height: 140)
                        }
                        Capsule()
                            .fill(bar.color)
                            .frame(height: bar.height)
                    }
                    .frame(maxWidth: .infinity)
                    Text(bar.day)
                        .font(.spChartLabel)
                        .foregroundStyle(Color(hex: 0xA09D97))
                        .frame(height: 10)
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(label)
                .font(.custom("Nunito-SemiBold", size: 9.9))
                .foregroundStyle(Color.spTextSecondary)
        }
    }

    // MARK: - Activity breakdown

    private var activityBreakdown: some View {
        SectionCard(title: "Activity Breakdown") {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(currentBreakdown, id: \.label) { item in
                    breakdownCell(item)
                }
            }
        }
    }

    private func breakdownCell(_ item: BreakdownItem) -> some View {
        HStack(spacing: 8) {
            Image(item.iconAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.spTextPrimary)
            VStack(alignment: .leading, spacing: 0) {
                Text(item.count)
                    .font(.spSectionTitle)
                    .foregroundStyle(Color.spTextPrimary)
                Text(item.label)
                    .font(.custom("Nunito-SemiBold", size: 9.3))
                    .foregroundStyle(Color.spTextSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(item.background)
        .cornerRadius(16)
    }

    // MARK: - Mock data

    private var chartBars: [ChartBar] {
        switch period {
        case .week:
            return [
                ChartBar(day: "M", color: .spChartMedium, height: 80),
                ChartBar(day: "T", color: .spChartLight, height: 40),
                ChartBar(day: "W", color: .spPrimary, height: 120),
                ChartBar(day: "T", color: .spChartMedium, height: 80),
                ChartBar(day: "F", color: .spChartEmpty, height: 4),
                ChartBar(day: "S", color: .spPrimary, height: 120),
                ChartBar(day: "S", color: .spChartMedium, height: 80),
            ]

        case .month:
            // 30 bars, labels shown at day 1, 6, 11, 16, 21, 26
            let heights: [(CGFloat, Color)] = [
                (40, .spChartLight), (110, .spPrimary), (30, .spChartLight), (70, .spChartMedium), (35, .spChartLight),
                (110, .spPrimary), (30, .spChartLight), (60, .spChartMedium), (55, .spChartMedium), (65, .spChartMedium),
                (100, .spPrimary), (55, .spChartMedium), (110, .spPrimary), (35, .spChartLight), (55, .spChartMedium),
                (60, .spChartMedium), (30, .spChartLight), (105, .spPrimary), (55, .spChartMedium), (60, .spChartMedium),
                (95, .spPrimary), (55, .spChartMedium), (35, .spChartLight), (60, .spChartMedium), (55, .spChartMedium),
                (125, .spPrimary), (55, .spChartMedium), (30, .spChartLight), (35, .spChartLight), (55, .spChartMedium),
            ]
            return heights.enumerated().map { i, entry in
                let day = i + 1
                let label = [1, 6, 11, 16, 21, 26].contains(day) ? "\(day)" : ""
                return ChartBar(day: label, color: entry.1, height: entry.0)
            }

        case .year:
            let months: [(String, CGFloat, Color)] = [
                ("J", 45, .spChartLight),
                ("F", 55, .spChartLight),
                ("M", 55, .spChartLight),
                ("A", 75, .spChartMedium),
                ("M", 75, .spChartMedium),
                ("J", 85, .spChartMedium),
                ("J", 85, .spChartMedium),
                ("A", 110, .spPrimary),
                ("S", 85, .spChartMedium),
                ("O", 125, .spPrimary),
                ("N", 80, .spChartMedium),
                ("D", 85, .spChartMedium),
            ]
            return months.map { ChartBar(day: $0.0, color: $0.2, height: $0.1) }
        }
    }

    private var currentStats: [StatItem] {
        switch period {
        case .week:
            return [
                StatItem(iconSystemName: "chart.line.uptrend.xyaxis", value: "2.1/day", label: "AVG"),
                StatItem(iconSystemName: "flame.fill", value: "7 days", label: "Best Streak"),
                StatItem(iconSystemName: "bolt.fill", value: "388 XP", label: "Total XP"),
            ]
        case .month:
            return [
                StatItem(iconSystemName: "chart.line.uptrend.xyaxis", value: "1.7/day", label: "AVG"),
                StatItem(iconSystemName: "flame.fill", value: "7 days", label: "Best Streak"),
                StatItem(iconSystemName: "bolt.fill", value: "1,560 XP", label: "Total XP"),
            ]
        case .year:
            return [
                StatItem(iconSystemName: "chart.line.uptrend.xyaxis", value: "1.5/day", label: "AVG"),
                StatItem(iconSystemName: "flame.fill", value: "14 days", label: "Best Streak"),
                StatItem(iconSystemName: "bolt.fill", value: "11,320 XP", label: "Total XP"),
            ]
        }
    }

    private var currentBreakdown: [BreakdownItem] {
        switch period {
        case .week:
            return [
                BreakdownItem(iconAsset: "journal", count: "3x", label: "Journal", background: .spActivityJournal),
                BreakdownItem(iconAsset: "breathing", count: "5x", label: "Breathing", background: .spActivityBreathing),
                BreakdownItem(iconAsset: "focus", count: "3x", label: "Focus", background: .spActivityFocus),
                BreakdownItem(iconAsset: "coloring", count: "4x", label: "Coloring", background: .spActivityColoring),
            ]
        case .month:
            return [
                BreakdownItem(iconAsset: "journal", count: "10x", label: "Journal", background: .spActivityJournal),
                BreakdownItem(iconAsset: "breathing", count: "18x", label: "Breathing", background: .spActivityBreathing),
                BreakdownItem(iconAsset: "focus", count: "12x", label: "Focus", background: .spActivityFocus),
                BreakdownItem(iconAsset: "coloring", count: "8x", label: "Coloring", background: .spActivityColoring),
            ]
        case .year:
            return [
                BreakdownItem(iconAsset: "journal", count: "43x", label: "Journal", background: .spActivityJournal),
                BreakdownItem(iconAsset: "breathing", count: "72x", label: "Breathing", background: .spActivityBreathing),
                BreakdownItem(iconAsset: "focus", count: "56x", label: "Focus", background: .spActivityFocus),
                BreakdownItem(iconAsset: "coloring", count: "67x", label: "Coloring", background: .spActivityColoring),
            ]
        }
    }
}

private struct ChartBar {
    let day: String
    let color: Color
    let height: CGFloat
}

private struct BreakdownItem {
    let iconAsset: String
    let count: String
    let label: String
    let background: Color
}

#Preview {
    JourneyView()
}
