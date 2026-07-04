import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.spTextSecondary)
                .frame(width: 40, height: 40)
                .background(Color.spBorder.opacity(0.4))
                .clipShape(Circle())
        }
    }
}
