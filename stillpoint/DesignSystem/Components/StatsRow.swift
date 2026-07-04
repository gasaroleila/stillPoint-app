import SwiftUI

struct StatItem: Identifiable {
    let id = UUID()
    let iconSystemName: String
    let value: String
    let label: String
}

struct StatsRow: View {
    let items: [StatItem]

    var body: some View {
        HStack(spacing: SP.Spacing.statsGap) {
            ForEach(items) { item in
                statCard(item)
            }
        }
    }

    private func statCard(_ item: StatItem) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: item.iconSystemName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.spTextPrimary)
                Text(item.value)
                    .font(.custom("Nunito-ExtraBold", size: 15.2))
                    .foregroundStyle(Color.spTextPrimary)
            }
            Text(item.label)
                .font(.spStatLabel)
                .tracking(0.384)
                .textCase(.uppercase)
                .foregroundStyle(Color.spTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.spPrimaryLight)
        .cornerRadius(16)
    }
}
