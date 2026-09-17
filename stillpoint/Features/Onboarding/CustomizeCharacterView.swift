import SwiftUI

struct CustomizeCharacterView: View {
    let characterType: CharacterType
    let user: any UserRepository
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var selectedSkinTone: Int = 1
    @State private var selectedHat: String = "None"
    @State private var selectedAccessory: String = "None"
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let skinTones: [Color] = [
        Color(hex: 0xFDDBB4),
        Color(hex: 0xF5C28B),
        Color(hex: 0xC68642),
        Color(hex: 0x8D5524),
        Color(hex: 0x4A2912),
    ]

    private let hats = ["None", "Crown", "Halo", "Beanie"]
    private let accessories = ["None", "Glasses", "Bow Tie", "Scarf"]

    private var accentColor: Color {
        switch characterType {
        case .person: return Color(hex: 0xB388FF)
        case .plant: return Color(hex: 0x66BB6A)
        case .bird: return Color(hex: 0x42A5F5)
        case .cat: return Color(hex: 0xFFA726)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    stepDots
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    backButton
                        .padding(.bottom, 16)

                    Text("Dress them up")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .padding(.bottom, 4)

                    Text("All accessories shown here are free \u{2014} more unlock as you grow.")
                        .font(.spSubtitle)
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.bottom, 16)

                    characterPreview
                        .padding(.bottom, 20)

                    skinToneSection
                        .padding(.bottom, 16)

                    hatSection
                        .padding(.bottom, 16)

                    accessorySection
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 52)
                .padding(.bottom, 24)
            }

            startButton
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.bottom, 36)
        }
        .background(Color.spBackground)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color(hex: 0x66BB6A))
                    .frame(width: 6, height: 6)
            }
            Capsule()
                .fill(Color.spPrimary)
                .frame(width: 22, height: 6)
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

    // MARK: - Character Preview

    private var characterPreview: some View {
        HStack {
            Spacer()
            ZStack {
                // Accent glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.16), accentColor.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                // Character icon placeholder
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(accentColor)
            }
            Spacer()
        }
    }

    private var iconName: String {
        switch characterType {
        case .person: return "figure.stand"
        case .plant: return "leaf.fill"
        case .bird: return "bird.fill"
        case .cat: return "cat.fill"
        }
    }

    // MARK: - Skin Tone

    private var skinToneSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SKIN TONE")
                .font(.custom("Nunito-Bold", size: 10.88))
                .foregroundStyle(Color.spTextSecondary)
                .tracking(0.76)

            HStack(spacing: 12) {
                ForEach(0..<skinTones.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedSkinTone = index }
                    } label: {
                        Circle()
                            .fill(skinTones[index])
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedSkinTone == index ? Color.spTextPrimary : .clear,
                                        lineWidth: 2.3
                                    )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Hat

    private var hatSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HAT")
                .font(.custom("Nunito-Bold", size: 10.88))
                .foregroundStyle(Color.spTextSecondary)
                .tracking(0.76)

            HStack(spacing: 8) {
                ForEach(hats, id: \.self) { hat in
                    chipButton(label: hat, isSelected: selectedHat == hat) {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedHat = hat }
                    }
                }
            }
        }
    }

    // MARK: - Accessory

    private var accessorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ACCESSORY")
                .font(.custom("Nunito-Bold", size: 10.88))
                .foregroundStyle(Color.spTextSecondary)
                .tracking(0.76)

            HStack(spacing: 8) {
                ForEach(accessories, id: \.self) { accessory in
                    chipButton(label: accessory, isSelected: selectedAccessory == accessory) {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedAccessory = accessory }
                    }
                }
            }
        }
    }

    // MARK: - Chip Button

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.custom("Nunito-Bold", size: 12.16))
                .foregroundStyle(isSelected ? .white : Color.spTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? accentColor : Color(hex: 0xF0EDE8))
                .cornerRadius(99)
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        VStack(spacing: 8) {
            if let error = errorMessage {
                Text(error)
                    .font(.spCaption)
                    .foregroundStyle(.red)
            }
            Button {
                Task {
                    isSaving = true
                    errorMessage = nil
                    do {
                        try await user.saveCharacterSelection(
                            type: characterType,
                            skinTone: selectedSkinTone,
                            hat: selectedHat,
                            accessory: selectedAccessory
                        )
                        onComplete()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isSaving = false
                }
            } label: {
                HStack(spacing: 8) {
                    Text(isSaving ? "Saving..." : "Start my journey")
                        .font(.custom("Nunito-Black", size: 16))
                    if !isSaving {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundStyle(Color.spTextPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.spPrimary)
                .cornerRadius(20)
            }
            .disabled(isSaving)
        }
    }
}

#Preview {
    CustomizeCharacterView(characterType: .person, user: UserRepositoryImpl(firestore: FirestoreService { nil }), onComplete: {}, onBack: {})
}
