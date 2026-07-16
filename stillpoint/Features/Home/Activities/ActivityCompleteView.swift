import SwiftUI

struct ActivityCompleteView: View {
    let activityName: String
    let xpEarned: Int
    let onDone: () -> Void

    @State private var showContent = false

    // Everything vertically centered as one group (icon, text, XP, button)
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(Color.spPrimary)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                Text("Well done!")
                    .font(.spLargeTitle)
                    .foregroundStyle(Color.spTextPrimary)

                Text("You completed \(activityName)")
                    .font(.spBody)
                    .foregroundStyle(Color.spTextSecondary)

                Text("+\(xpEarned) XP")
                    .font(.spHeading)
                    .foregroundStyle(Color.spTextPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.spPrimaryLight)
                    .cornerRadius(SP.Radius.pill)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            PrimaryCTA(title: "Done", action: onDone)
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .opacity(showContent ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.spBackgroundAlt)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}
