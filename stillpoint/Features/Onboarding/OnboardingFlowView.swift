import SwiftUI

enum OnboardingStep: Equatable {
    case register
    case mfa
    case chooseCharacter
    case customizeCharacter
}

struct OnboardingFlowView: View {
    let auth: any AuthRepository
    let onComplete: () -> Void

    @State private var step: OnboardingStep = .register
    @State private var selectedCharacter: CharacterType = .person
    @State private var viewModel: AuthViewModel?

    private var vm: AuthViewModel {
        if let viewModel { return viewModel }
        let created = AuthViewModel(auth: auth)
        DispatchQueue.main.async { viewModel = created }
        return created
    }

    var body: some View {
        Group {
            switch step {
            case .register:
                RegisterView(viewModel: vm, onContinue: {
                    withAnimation { step = .mfa }
                })
            case .mfa:
                MFAView(
                    onVerify: {
                        withAnimation { step = .chooseCharacter }
                    },
                    onBack: {
                        withAnimation { step = .register }
                    }
                )
            case .chooseCharacter:
                ChooseCharacterView(
                    onContinue: { character in
                        selectedCharacter = character
                        withAnimation { step = .customizeCharacter }
                    },
                    onBack: {
                        withAnimation { step = .mfa }
                    }
                )
            case .customizeCharacter:
                CustomizeCharacterView(
                    characterType: selectedCharacter,
                    onComplete: onComplete,
                    onBack: {
                        withAnimation { step = .chooseCharacter }
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }
}
