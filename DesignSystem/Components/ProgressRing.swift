import SwiftUI

public struct ProgressRing: View {
    @Binding var progress: Double
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let color: Color

    public init(
        progress: Binding<Double>,
        size: CGFloat = 120,
        lineWidth: CGFloat = 12,
        color: Color = .vbAccent
    ) {
        self._progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            Text("\(percentageText)%")
                .font(VBFont.headline)
                .foregroundStyle(Color.vbMainText)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progress \(percentageText) percent")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var percentageText: Int {
        Int(clampedProgress * 100)
    }
}

#Preview("ProgressRing") {
    @Previewable @State var p1: Double = 0.25
    @Previewable @State var p2: Double = 0.7

    VStack(spacing: 30) {
        ProgressRing(progress: $p1)
        ProgressRing(progress: $p2, size: 160, lineWidth: 16, color: .vbSuccess)
        Button("Increase") { p1 = min(p1 + 0.1, 1.0) }
            .vbHeadline()
    }
    .padding()
    .background(Color.vbCream)
}
