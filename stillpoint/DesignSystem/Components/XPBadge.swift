import SwiftUI

struct XPBadge: View {
    let earned: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.spPrimary)
            Text("\(earned)/\(total) XP")
                .font(.custom("Nunito-ExtraBold", size: 12.5))
                .foregroundStyle(Color.spTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.spPrimaryLight)
        .cornerRadius(SP.Radius.pill)
    }
}
