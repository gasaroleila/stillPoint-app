import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let speed: Double
    let delay: Double
    let rotation: Double
    let size: CGFloat
}

struct ConfettiView: View {
    @State private var animate = false

    private let pieces: [ConfettiPiece]

    init() {
        let palette: [Color] = [
            .spPrimary,
            Color(hex: 0xFFB800),
            Color(hex: 0xFF6B6B),
            Color(hex: 0x48DBFB),
            Color(hex: 0x00B894),
            Color(hex: 0xA29BFE),
        ]
        pieces = (0..<40).map { _ in
            ConfettiPiece(
                color: palette.randomElement() ?? .spPrimary,
                x: CGFloat.random(in: 0...1),
                speed: Double.random(in: 1.2...2.5),
                delay: Double.random(in: 0...0.4),
                rotation: Double.random(in: 0...360),
                size: CGFloat.random(in: 4...8)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 1.6)
                        .rotationEffect(.degrees(animate ? piece.rotation + 360 : piece.rotation))
                        .position(
                            x: geo.size.width * piece.x,
                            y: animate ? geo.size.height + 20 : -20
                        )
                        .animation(
                            .easeIn(duration: piece.speed)
                            .delay(piece.delay),
                            value: animate
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
