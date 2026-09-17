import SwiftUI
import PencilKit

struct ColoringView: View {
    let onComplete: (Int) -> Void
    let onDismiss: () -> Void

    @State private var canvasView = PKCanvasView()
    @State private var selectedColorIndex = 0
    @State private var selectedBrushIndex = 1
    @State private var isErasing = false
    @State private var isComplete = false
    @State private var isDoneEnabled = false

    private let palette: [Color] = [
        Color(hex: 0xFFD60A),
        Color(hex: 0xFF6B6B),
        Color(hex: 0xFF9F43),
        Color(hex: 0x48DBFB),
        Color(hex: 0x00B894),
        Color(hex: 0x55E6C1),
        Color(hex: 0xA29BFE),
        Color(hex: 0xFD79A8),
        Color(hex: 0x4834D4),
        Color(hex: 0x6C5CE7),
        Color(hex: 0x2ED573),
        Color(hex: 0x2D3436),
    ]

    private let brushSizes: [CGFloat] = [4, 8, 14, 22]

    var body: some View {
        if isComplete {
            ActivityCompleteView(
                activityName: "Coloring",
                xpEarned: 30,
                onDone: {
                    onComplete(30)
                    onDismiss()
                }
            )
        } else {
            coloringContent
        }
    }

    private var coloringContent: some View {
        VStack(spacing: 16) {
            header
            canvas
            colorPalette
            toolBar
        }
        .padding(.horizontal, SP.Padding.screenHorizontal)
        .padding(.bottom, 16)
        .background(Color.spBackgroundAlt)
        .task {
            try? await Task.sleep(for: .seconds(300))
            withAnimation { isDoneEnabled = true }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            CloseButton(action: onDismiss)

            Spacer()

            VStack(spacing: 2) {
                Text("COLORING")
                    .font(.spActivityLabel)
                    .foregroundStyle(Color.spTextSecondary)
                    .tracking(0.832)

                Text("Mushroom Garden")
                    .font(.spHeading)
                    .foregroundStyle(Color.spTextPrimary)
            }

            Spacer()

            Button(action: clearCanvas) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.spTextSecondary)
                    .frame(width: 40, height: 40)
                    .background(Color.spBorder.opacity(0.4))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Canvas

    private var canvas: some View {
        ZStack {
            Image("garden-mushroom")
                .resizable()
                .scaledToFit()
                .padding(16)

            DrawingCanvasView(
                canvasView: $canvasView,
                brushColor: UIColor(palette[selectedColorIndex]),
                brushSize: brushSizes[selectedBrushIndex],
                isErasing: isErasing
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SP.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: SP.Radius.card)
                .stroke(Color.spBorder, lineWidth: 1)
        )
    }

    // MARK: - Color Palette

    private var colorPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(palette.indices, id: \.self) { index in
                    Circle()
                        .fill(palette[index])
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.spTextPrimary,
                                    lineWidth: selectedColorIndex == index && !isErasing ? 2.5 : 0
                                )
                                .frame(width: 38, height: 38)
                        )
                        .onTapGesture {
                            selectedColorIndex = index
                            isErasing = false
                        }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Tool Bar

    private var toolBar: some View {
        HStack {
            HStack(spacing: 12) {
                ForEach(brushSizes.indices, id: \.self) { index in
                    Circle()
                        .fill(selectedBrushIndex == index && !isErasing
                              ? Color.spTextPrimary
                              : Color.spTextSecondary.opacity(0.5))
                        .frame(width: dotSize(for: index), height: dotSize(for: index))
                        .onTapGesture {
                            selectedBrushIndex = index
                            isErasing = false
                        }
                }

                Button(action: { isErasing.toggle() }) {
                    Image(systemName: "eraser.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isErasing ? Color.spPrimary : Color.spTextSecondary)
                        .frame(width: 36, height: 36)
                        .background(isErasing ? Color.spPrimaryLight : Color.clear)
                        .clipShape(Circle())
                }
            }

            Spacer()

            Button(action: { withAnimation { isComplete = true } }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Done")
                        .font(.spCardTitle)
                }
                .foregroundStyle(Color.spTextPrimary.opacity(isDoneEnabled ? 1 : 0.4))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isDoneEnabled ? Color.spPrimary : Color.spPrimaryLight.opacity(0.5))
                .clipShape(Capsule())
            }
            .disabled(!isDoneEnabled)
        }
    }

    // MARK: - Helpers

    private func dotSize(for index: Int) -> CGFloat {
        [6, 10, 14, 18][index]
    }

    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}

// MARK: - PencilKit Canvas Wrapper

private struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let brushColor: UIColor
    let brushSize: CGFloat
    let isErasing: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        updateTool(on: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateTool(on: uiView)
    }

    private func updateTool(on canvas: PKCanvasView) {
        if isErasing {
            canvas.tool = PKEraserTool(.bitmap)
        } else {
            canvas.tool = PKInkingTool(.pen, color: brushColor, width: brushSize)
        }
    }
}

#Preview {
    ColoringView(onComplete: { _ in }, onDismiss: {})
}
