import SwiftUI

struct ActivityCard: View {
    let iconAsset: String
    let title: String
    let description: String
    let durationText: String
    let xpText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(iconAsset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.spTextPrimary)
                    .frame(width: SP.Size.activityIcon, height: SP.Size.activityIcon)
                    .background(Color.spBackground)
                    .cornerRadius(SP.Radius.icon)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.spCardTitle)
                        .foregroundStyle(Color.spTextPrimary)
                    Text(description)
                        .font(.spBody)
                        .foregroundStyle(Color.spTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        PillTag(text: durationText, style: .duration)
                        PillTag(text: xpText, style: .xp)
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.spTextPrimary)
                    .frame(width: SP.Size.playButton, height: SP.Size.playButton)
                    .background(Color.spPrimary)
                    .cornerRadius(SP.Radius.icon)
            }
            .padding(SP.Padding.card)
            .background(Color.white)
            .cornerRadius(SP.Radius.card)
            .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
