import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .font(.spBody)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(SP.Radius.icon)
        .overlay(
            RoundedRectangle(cornerRadius: SP.Radius.icon)
                .stroke(Color.spBorder, lineWidth: 1)
        )
        .autocorrectionDisabled()
    }
}
