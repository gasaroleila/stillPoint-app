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

    var reportPeriod: ReportPeriod {
        switch self {
        case .week: return .week
        case .month: return .month
        case .year: return .year
        }
    }
}

struct JourneyView: View {
    @EnvironmentObject private var dependencies: Dependencies
    @State private var viewModel: JourneyViewModel?
    @State private var period: JourneyPeriod = .week

    private var vm: JourneyViewModel {
        if let viewModel { return viewModel }
        let created = JourneyViewModel(user: dependencies.user)
        DispatchQueue.main.async { viewModel = created }
        return created
    }

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

                StatsRow(items: vm.stats)
                    .padding(.horizontal, SP.Padding.screenHorizontal)

                activityBreakdown
                    .padding(.horizontal, SP.Padding.screenHorizontal)
                    .padding(.bottom, 32)
            }
            .padding(.top, 48)
        }
        .background(Color.spBackground)
        .task { await vm.loadReport(for: period.reportPeriod) }
        .onChange(of: period) { _, newPeriod in
            Task { await vm.switchPeriod(to: newPeriod.reportPeriod) }
        }
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
                    if let mood = vm.dominantMood, let text = vm.moodSummaryText {
                        HStack(spacing: 5) {
                            Image(mood.assetName)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(Color.spStatusText)
                            Text(text)
                                .font(.custom("Nunito-Bold", size: 12.8))
                                .foregroundStyle(Color.spStatusText)
                        }
                    }
                }

                if vm.chartBars.isEmpty {
                    emptyChartState
                } else {
                    barChart
                }

                Divider().overlay(Color(hex: 0xF0EDE8))

                HStack(spacing: 12) {
                    legendItem(color: .spPrimary, label: "Active day")
                    legendItem(color: .spChartEmpty, label: "Rest day")
                }
            }
        }
    }

    private var emptyChartState: some View {
        VStack(spacing: 8) {
            Text("No activity data yet")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
            Text("Complete activities to see your progress here")
                .font(.spCaption)
                .foregroundStyle(Color.spTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }

    private var barChart: some View {
        let showTrack = period == .week
        let spacing: CGFloat = period == .week ? SP.Spacing.chartBarGap : 3
        return HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(vm.chartBars.enumerated()), id: \.offset) { _, bar in
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
                            .fill(bar.color.swiftUIColor)
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
                ForEach(vm.breakdown, id: \.label) { item in
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
        .background(item.bg.color)
        .cornerRadius(16)
    }
}

// MARK: - Color mappings

extension ChartBarColor {
    var swiftUIColor: Color {
        switch self {
        case .empty: return .spChartEmpty
        case .light: return .spChartLight
        case .medium: return .spChartMedium
        case .full: return .spPrimary
        }
    }
}

extension BreakdownBg {
    var color: Color {
        switch self {
        case .journal: return .spActivityJournal
        case .breathing: return .spActivityBreathing
        case .focus: return .spActivityFocus
        case .coloring: return .spActivityColoring
        }
    }
}

#Preview {
    JourneyView()
        .environmentObject(Dependencies())
}
