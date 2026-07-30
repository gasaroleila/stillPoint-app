import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    let onContinue: () -> Void

    @State private var showPassword = false

    private var isFormValid: Bool {
        !viewModel.registerUsername.isEmpty
            && !viewModel.registerEmail.isEmpty
            && !viewModel.registerPhoneNumber.isEmpty
            && viewModel.registerPassword.count >= 6
            && viewModel.agreedToPolicy
            && viewModel.agreedToDisclaimer
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                stepDots
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)

                Text("Create your account")
                    .font(.spPageTitle)
                    .foregroundStyle(Color.spTextPrimary)
                    .padding(.bottom, 4)

                Text("One account to track your whole self-care journey.")
                    .font(.spSubtitle)
                    .foregroundStyle(Color.spTextSecondary)
                    .padding(.bottom, 20)

                VStack(spacing: 12) {
                    fieldGroup(label: "USERNAME") {
                        TextField("e.g. alex_sp", text: $viewModel.registerUsername)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    fieldGroup(label: "EMAIL") {
                        TextField("you@example.com", text: $viewModel.registerEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    fieldGroup(label: "DATE OF BIRTH") {
                        DatePicker(
                            "",
                            selection: $viewModel.registerDateOfBirth,
                            in: ...Date.now,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    fieldGroup(label: "PHONE NUMBER (for verification)") {
                        TextField("+1 555 000 0000", text: $viewModel.registerPhoneNumber)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }

                    fieldGroup(label: "PASSWORD") {
                        HStack {
                            if showPassword {
                                TextField("Min. 6 characters", text: $viewModel.registerPassword)
                                    .textContentType(.newPassword)
                            } else {
                                SecureField("Min. 6 characters", text: $viewModel.registerPassword)
                                    .textContentType(.newPassword)
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.spTextSecondary)
                            }
                        }
                    }

                    agreementRow(
                        isChecked: $viewModel.agreedToPolicy,
                        text: "I agree to StillPoint's mental health policy and understand how my data is used."
                    )

                    agreementRow(
                        isChecked: $viewModel.agreedToDisclaimer,
                        text: "I understand this app does not replace professional therapy. I will seek emergency help if needed."
                    )
                }

                errorBanner
                    .padding(.top, 8)

                continueButton
                    .padding(.top, 12)
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.top, 52)
            .padding(.bottom, 36)
        }
        .background(Color.spBackground)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(Color.spPrimary)
                .frame(width: 22, height: 6)
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color.spPrimary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Field Group

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Nunito-Bold", size: 10.9))
                .foregroundStyle(Color.spTextSecondary)
                .tracking(0.76)

            content()
                .font(.custom("Nunito-Regular", size: 14.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.spBorder, lineWidth: 0.78)
                )
        }
    }

    // MARK: - Agreement Row

    private func agreementRow(isChecked: Binding<Bool>, text: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isChecked.wrappedValue.toggle() }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isChecked.wrappedValue ? Color.spPrimary : Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    isChecked.wrappedValue ? Color.spPrimary : Color(hex: 0xD0CEC9),
                                    lineWidth: 0.78
                                )
                        )
                    if isChecked.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.spTextPrimary)
                    }
                }
                .padding(.top, 1)

                Text(text)
                    .font(.custom("Nunito-SemiBold", size: 11.8))
                    .foregroundStyle(Color(hex: 0x4A4845))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isChecked.wrappedValue ? Color.spPrimaryLight : Color(hex: 0xF9F8F5))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isChecked.wrappedValue ? Color.spPrimary : Color.spBorder,
                        lineWidth: 0.78
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Error Banner

    @ViewBuilder
    private var errorBanner: some View {
        if let error = viewModel.errorMessage {
            Text(error)
                .font(.spCaption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            Task {
                await viewModel.register()
                if viewModel.errorMessage == nil {
                    onContinue()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(viewModel.isLoading ? "Creating account..." : "Continue")
                    .font(.custom("Nunito-Black", size: 16))
                if !viewModel.isLoading {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(isFormValid ? Color.spTextPrimary : Color(hex: 0xB0ADA6))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isFormValid ? Color.spPrimary : Color(hex: 0xF0EDE8))
            .cornerRadius(20)
        }
        .disabled(!isFormValid || viewModel.isLoading)
    }
}

#Preview {
    RegisterView(
        viewModel: AuthViewModel(auth: AuthRepositoryImpl()),
        onContinue: {}
    )
}
