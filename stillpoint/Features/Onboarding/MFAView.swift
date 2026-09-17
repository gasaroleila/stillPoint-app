import SwiftUI

struct MFAView: View {
    @Bindable var viewModel: AuthViewModel
    let onVerify: () -> Void
    let onBack: () -> Void

    @FocusState private var focusedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    stepDots
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    backButton
                        .padding(.bottom, 16)

                    Text("Verify your phone")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .padding(.bottom, 4)

                    Text("We sent a 6-digit code to your phone number. Enter it below.")
                        .font(.spSubtitle)
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.bottom, 32)

                    codeInput
                        .padding(.bottom, 32)

                    resendRow
                        .frame(maxWidth: .infinity)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.spCaption)
                            .foregroundStyle(.red)
                            .padding(.top, 16)
                    }
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 52)
            }

            verifyButton
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.bottom, 36)
        }
        .background(Color.spBackground)
        .onAppear { focusedIndex = 0 }
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: 0x66BB6A))
                .frame(width: 6, height: 6)
            Capsule()
                .fill(Color.spPrimary)
                .frame(width: 22, height: 6)
            ForEach(0..<2, id: \.self) { _ in
                Circle()
                    .fill(Color.spPrimary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                Text("Back")
                    .font(.custom("Nunito-Bold", size: 12.5))
            }
            .foregroundStyle(Color.spTextSecondary)
        }
    }

    // MARK: - Code Input

    private var codeInput: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                digitBox(index: index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func digitBox(index: Int) -> some View {
        let isFilled = !viewModel.mfaDigits[index].isEmpty

        return TextField("", text: $viewModel.mfaDigits[index])
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.custom("Nunito-Black", size: 20))
            .foregroundStyle(Color.spTextPrimary)
            .frame(width: 44, height: 54)
            .background(isFilled ? Color.spPrimaryLight : Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isFilled ? Color.spPrimary : Color.spBorder,
                        lineWidth: isFilled ? 1.5 : 0.78
                    )
            )
            .focused($focusedIndex, equals: index)
            .onChange(of: viewModel.mfaDigits[index]) { oldValue, newValue in
                if newValue.count > 1 {
                    viewModel.mfaDigits[index] = String(newValue.last!)
                }
                if !newValue.isEmpty && index < 5 {
                    focusedIndex = index + 1
                }
            }
    }

    // MARK: - Resend Row

    private var resendRow: some View {
        HStack(spacing: 0) {
            Text("Didn't receive it? ")
                .font(.custom("Nunito-Regular", size: 12))
                .foregroundStyle(Color.spTextSecondary)
            Button {
                Task { await viewModel.resendMFACode() }
            } label: {
                Text("Resend code")
                    .font(.custom("Nunito-Bold", size: 12))
                    .foregroundStyle(Color.spTextPrimary)
            }
            .disabled(viewModel.isLoading)
        }
    }

    // MARK: - Verify Button

    private var verifyButton: some View {
        Button {
            Task {
                await viewModel.verifyMFA()
                if viewModel.errorMessage == nil {
                    onVerify()
                }
            }
        } label: {
            Text(viewModel.isLoading ? "Verifying..." : "Verify")
                .font(.custom("Nunito-Black", size: 16))
                .foregroundStyle(viewModel.isMFACodeComplete ? Color.spTextPrimary : Color(hex: 0xB0ADA6))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(viewModel.isMFACodeComplete ? Color.spPrimary : Color(hex: 0xF0EDE8))
                .cornerRadius(20)
        }
        .disabled(!viewModel.isMFACodeComplete || viewModel.isLoading)
    }
}

#Preview {
    MFAView(viewModel: AuthViewModel(auth: AuthRepositoryImpl()), onVerify: {}, onBack: {})
}
