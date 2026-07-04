import SwiftUI

struct SegmentedControl<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.value) { option in
                segment(option)
            }
        }
        .padding(4)
        .background(Color(hex: 0xEDEBE6))
        .cornerRadius(16)
    }

    private func segment(_ option: (value: Value, label: String)) -> some View {
        let isActive = selection == option.value
        let bg: Color = isActive ? .spPrimary : .clear
        let fg: Color = isActive ? .spTextPrimary : .spTextSecondary

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = option.value
            }
        } label: {
            Text(option.label)
                .font(.spSegment)
                .tracking(0.256)
                .textCase(.uppercase)
                .foregroundStyle(fg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(bg)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
