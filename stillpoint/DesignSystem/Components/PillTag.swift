import SwiftUI

struct PillTag: View {
    enum Style {
        case duration
        case xp

        var background: Color {
            switch self {
            case .duration: return .spBackgroundAlt
            case .xp: return .spPrimaryLight
            }
        }

        var foreground: Color {
            switch self {
            case .duration: return .spTextSecondary
            case .xp: return .spTextPrimary
            }
        }
    }

    let text: String
    let style: Style

    var body: some View {
        Text(text)
            .font(.custom("Nunito-Bold", size: 10.9))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 1.6)
            .background(style.background)
            .cornerRadius(SP.Radius.pill)
    }
}
