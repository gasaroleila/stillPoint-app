import SwiftUI

struct ScheduleView: View {
    @State private var isConnected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            pageHeader
            connectCard
            Spacer(minLength: 0)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spBackground)
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Schedule")
                .font(.custom("Nunito-Black", size: 24))
                .foregroundStyle(Color.spTextPrimary)
            Text("Self-care slotted into your day, automatically")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }

    private var connectCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.spTextSecondary)
                .frame(width: 48, height: 48)
                .background(Color.spBackgroundAlt)
                .cornerRadius(SP.Radius.icon)

            VStack(alignment: .leading, spacing: 1) {
                Text("Connect your calendar")
                    .font(.custom("Nunito-ExtraBold", size: 14.4))
                    .foregroundStyle(Color.spTextPrimary)
                Text("We'll find gaps and fit in activities for you")
                    .font(.custom("Nunito-Regular", size: 11.5))
                    .foregroundStyle(Color.spTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                isConnected = true
            } label: {
                Text("Connect")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.spPrimary)
                    .cornerRadius(SP.Radius.pill)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(SP.Radius.card)
        .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 16, x: 0, y: 2)
        .padding(.horizontal, SP.Padding.screenHorizontal)
    }
}

#Preview {
    ScheduleView()
}
