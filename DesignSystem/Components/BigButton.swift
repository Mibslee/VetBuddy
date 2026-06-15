import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct BigButton: View {
    public enum Style {
        case primary
        case secondary
        case danger
    }

    private let title: String
    private let style: Style
    private let isDisabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            Text(title)
                .font(VBFont.button)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: style == .secondary ? 2 : 0)
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .accessibilityAddTraits(.isButton)
    }

    private var backgroundColor: Color {
        if isDisabled { return Color.gray.opacity(0.3) }
        switch style {
        case .primary: return Color.vbAccent
        case .secondary: return .clear
        case .danger: return Color.vbWarning
        }
    }

    private var foregroundColor: Color {
        if isDisabled { return Color.gray }
        switch style {
        case .primary, .danger: return .white
        case .secondary: return Color.vbAccent
        }
    }

    private var borderColor: Color {
        if isDisabled { return Color.gray }
        switch style {
        case .primary, .danger: return .clear
        case .secondary: return Color.vbAccent
        }
    }

    private func triggerHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}

#Preview("BigButton Styles") {
    VStack(spacing: 20) {
        BigButton("Primary Button") {}
        BigButton("Secondary", style: .secondary) {}
        BigButton("Danger", style: .danger) {}
        BigButton("Disabled", isDisabled: true) {}
    }
    .padding()
    .background(Color.vbCream)
}
