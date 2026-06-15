import SwiftUI

public struct StepCard: View {
    private let step: Int
    private let title: String
    private let subtitle: String?

    public init(step: Int, title: String, subtitle: String? = nil) {
        self.step = step
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            stepBadge
            textContent
            Spacer()
        }
        .padding(16)
        .frame(minHeight: 80)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var stepBadge: some View {
        Text("\(step)")
            .font(VBFont.headline)
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Color.vbAccent)
            .clipShape(Circle())
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .vbHeadline()
            if let subtitle {
                Text(subtitle)
                    .vbCaption()
            }
        }
    }
}

#Preview("StepCard") {
    VStack(spacing: 12) {
        StepCard(step: 1, title: "First Step", subtitle: "Begin here")
        StepCard(step: 2, title: "Second Step")
        StepCard(step: 3, title: "Third Step", subtitle: "Almost done")
    }
    .padding()
    .background(Color.vbCream)
}
