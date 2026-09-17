import Foundation
import SwiftData

@Model
final class OnboardingProgress {
    var step: String
    var updatedAt: Date

    init(step: OnboardingStep = .register) {
        self.step = step.rawValue
        self.updatedAt = .now
    }

    var currentStep: OnboardingStep {
        OnboardingStep(rawValue: step) ?? .register
    }

    var isComplete: Bool {
        step == "complete"
    }

    func update(to newStep: OnboardingStep) {
        step = newStep.rawValue
        updatedAt = .now
    }

    func markComplete() {
        step = "complete"
        updatedAt = .now
    }
}
