import SwiftUI
import SwiftData

enum OnboardingStep: String, Equatable {
    case register
    case mfa
    case chooseCharacter
    case customizeCharacter
}

struct OnboardingFlowView: View {
    let dependencies: Dependencies
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [OnboardingProgress]

    @State private var step: OnboardingStep?
    @State private var selectedCharacter: CharacterType = .person
    @State private var viewModel: AuthViewModel?

    private var progress: OnboardingProgress {
        if let existing = progressRecords.first { return existing }
        let new = OnboardingProgress()
        modelContext.insert(new)
        return new
    }

    private var vm: AuthViewModel {
        if let viewModel { return viewModel }
        let created = AuthViewModel(auth: dependencies.auth)
        DispatchQueue.main.async { viewModel = created }
        return created
    }

    var body: some View {
        Group {
            switch step {
            case .register:
                RegisterView(viewModel: vm, onContinue: {
                    Task {
                        await vm.startMFAEnrollment()
                        if vm.errorMessage == nil {
                            goTo(.mfa)
                        }
                    }
                })
            case .mfa:
                MFAView(
                    viewModel: vm,
                    onVerify: { goTo(.chooseCharacter) },
                    onBack: { goTo(.register) }
                )
            case .chooseCharacter:
                ChooseCharacterView(
                    onContinue: { character in
                        selectedCharacter = character
                        goTo(.customizeCharacter)
                    },
                    onBack: { goTo(.mfa) }
                )
            case .customizeCharacter:
                CustomizeCharacterView(
                    characterType: selectedCharacter,
                    user: dependencies.user,
                    onComplete: {
                        progress.markComplete()
                        onComplete()
                    },
                    onBack: { goTo(.chooseCharacter) }
                )
            case .none:
                Color.spBackground
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
        .onAppear {
            if step == nil {
                step = progress.currentStep
            }
        }
    }

    private func goTo(_ newStep: OnboardingStep) {
        progress.update(to: newStep)
        withAnimation { step = newStep }
    }
}
