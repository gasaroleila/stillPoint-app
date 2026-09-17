import SwiftUI

struct PillTag: View {
    enum Style {
        case duration
        case xp
        case xpCompleted

        var background: Color {
            switch self {
            case .duration: return .spBackgroundAlt
            case .xp: return .spPrimaryLight
            case .xpCompleted: return .spPrimary
            }
        }

        var foreground: Color {
            switch self {
            case .duration: return .spTextSecondary
            case .xp, .xpCompleted: return .spTextPrimary
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
