import SwiftUI

struct PrimaryCTA: View {
    let title: String
    var trailingSystemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.custom("Nunito-ExtraBold", size: 16))
                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(Color.spTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.spPrimary)
            .cornerRadius(SP.Radius.pill)
        }
    }
}
