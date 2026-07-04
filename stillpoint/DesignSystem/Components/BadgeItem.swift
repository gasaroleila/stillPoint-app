import SwiftUI

struct BadgeItem: View {
    let iconAsset: String
    let label: String
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 5.5) {
            Image(iconAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .frame(width: SP.Size.badgeIcon, height: SP.Size.badgeIcon)
                .background(isEarned ? Color.spPrimaryLight : Color.spLockedBadgeBg)
                .overlay(
                    RoundedRectangle(cornerRadius: SP.Radius.icon)
                        .stroke(isEarned ? Color.spPrimary : Color.spBorder, lineWidth: 1)
                )
                .cornerRadius(SP.Radius.icon)
                .opacity(isEarned ? 1.0 : 0.38)

            Text(label)
                .font(.custom("Nunito-Bold", size: 9.3))
                .foregroundStyle(Color.spTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(width: 68)
    }
}
