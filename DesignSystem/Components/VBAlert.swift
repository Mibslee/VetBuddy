import SwiftUI

public struct VBAlert: View {
    public enum AlertType {
        case info
        case warning
        case error

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .info: return .vbAccent
            case .warning: return .vbWarning
            case .error: return .vbWarning
            }
        }
    }

    public struct Action {
        let title: String
        let style: BigButton.Style
        let handler: () -> Void

        public init(
            title: String,
            style: BigButton.Style = .primary,
            handler: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }

    private let type: AlertType
    private let title: String
    private let message: String
    private let actions: [Action]

    public init(
        type: AlertType = .info,
        title: String,
        message: String,
        actions: [Action]
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.actions = actions
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: type.icon)
                .font(.system(size: 40))
                .foregroundStyle(type.color)

            Text(title)
                .vbTitle()
                .multilineTextAlignment(.center)

            Text(message)
                .vbBody()
                .multilineTextAlignment(.center)

            actionButtons
        }
        .padding(24)
        .background(Color.vbBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .padding(.horizontal, 32)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            ForEach(Array(actions.prefix(2).enumerated()), id: \.offset) { _, action in
                BigButton(action.title, style: action.style, action: action.handler)
            }
        }
    }
}

#Preview("VBAlert Types") {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()

        VStack(spacing: 30) {
            VBAlert(
                type: .info,
                title: "Information",
                message: "This is an informational message for you.",
                actions: [
                    .init(title: "Got It", style: .primary) {}
                ]
            )

            VBAlert(
                type: .warning,
                title: "Warning",
                message: "Please confirm this action.",
                actions: [
                    .init(title: "Confirm", style: .danger) {},
                    .init(title: "Cancel", style: .secondary) {}
                ]
            )
        }
    }
}
