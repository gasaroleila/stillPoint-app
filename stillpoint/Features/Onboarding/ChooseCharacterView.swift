import SwiftUI

struct ChooseCharacterView: View {
    let onContinue: (CharacterType) -> Void
    let onBack: () -> Void

    @State private var selected: CharacterType = .person

    private let characters: [(type: CharacterType, name: String, description: String, accent: Color, unlocks: [String])] = [
        (.person, "Person", "Your mini self-care avatar", Color(hex: 0xB388FF), ["Crown", "Outfit colours", "Halo"]),
        (.plant, "Plant", "Grows with every streak", Color(hex: 0x66BB6A), ["Flower bloom", "Pot designs", "Glow"]),
        (.bird, "Bird", "Takes flight as you progress", Color(hex: 0x42A5F5), ["Wing colours", "Nest upgrades", "Hat"]),
        (.cat, "Cat", "Purrs louder with each win", Color(hex: 0xFFA726), ["Collar styles", "Fur patterns", "Bow"]),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    stepDots
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    backButton
                        .padding(.bottom, 16)

                    Text("Pick your buddy")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .padding(.bottom, 4)

                    Text("They grow with every activity you complete.")
                        .font(.spSubtitle)
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.bottom, 24)

                    characterGrid
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 52)
                .padding(.bottom, 24)
            }

            continueButton
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.bottom, 36)
        }
        .background(Color.spBackground)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            // Steps 1-2 completed (green)
            ForEach(0..<2, id: \.self) { _ in
                Circle()
                    .fill(Color(hex: 0x66BB6A))
                    .frame(width: 6, height: 6)
            }
            // Step 3 active (yellow pill)
            Capsule()
                .fill(Color.spPrimary)
                .frame(width: 22, height: 6)
            // Step 4 inactive
            Circle()
                .fill(Color.spPrimary.opacity(0.3))
                .frame(width: 6, height: 6)
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

    // MARK: - Character Grid

    private var characterGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(characters, id: \.type) { character in
                characterCard(character)
            }
        }
    }

    private func characterCard(_ character: (type: CharacterType, name: String, description: String, accent: Color, unlocks: [String])) -> some View {
        let isSelected = selected == character.type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selected = character.type }
        } label: {
            VStack(spacing: 0) {
                // Character image placeholder
                ZStack {
                    Circle()
                        .fill(character.accent.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Image(systemName: iconName(for: character.type))
                        .font(.system(size: 28))
                        .foregroundStyle(character.accent)
                }
                .padding(.top, 16)
                .padding(.bottom, 10)

                Text(character.name)
                    .font(.custom("Nunito-Black", size: 14))
                    .foregroundStyle(Color.spTextPrimary)
                    .padding(.bottom, 2)

                Text(character.description)
                    .font(.custom("Nunito-Regular", size: 10.5))
                    .foregroundStyle(Color.spTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)

                // Unlock tags
                FlowLayout(spacing: 4) {
                    ForEach(character.unlocks, id: \.self) { tag in
                        Text(tag)
                            .font(.custom("Nunito-Bold", size: 9))
                            .foregroundStyle(Color.spTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: 0xF5F4F1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? character.accent : Color.spBorder,
                        lineWidth: isSelected ? 2 : 0.78
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(character.accent)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: -8, y: 8)
                }
            }
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 8 : 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func iconName(for type: CharacterType) -> String {
        switch type {
        case .person: return "figure.stand"
        case .plant: return "leaf.fill"
        case .bird: return "bird.fill"
        case .cat: return "cat.fill"
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            onContinue(selected)
        } label: {
            HStack(spacing: 8) {
                Text("Continue")
                    .font(.custom("Nunito-Black", size: 16))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color.spTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.spPrimary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Flow Layout (for tag wrapping)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y)
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

#Preview {
    ChooseCharacterView(onContinue: { _ in }, onBack: {})
}
