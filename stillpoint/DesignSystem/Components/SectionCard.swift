import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: () -> Content

    init(title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.spSectionTitle)
                    .foregroundStyle(Color.spTextPrimary)
            }
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(SP.Radius.card)
        .shadow(color: .black.opacity(SP.Shadow.cardOpacity), radius: 8, x: 0, y: 2)
    }
}
