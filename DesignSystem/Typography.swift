import SwiftUI

public enum VBFont {
    static let hero = Font.system(.largeTitle, design: .default).weight(.bold)
    static let title = Font.system(.title2, design: .default).weight(.bold)
    static let headline = Font.system(.title3, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.body, design: .default)
    static let button = Font.system(.title3, design: .default).weight(.bold)
}

public extension View {
    func vbHero() -> some View {
        font(VBFont.hero)
            .foregroundStyle(Color.vbMainText)
    }

    func vbTitle() -> some View {
        font(VBFont.title)
            .foregroundStyle(Color.vbMainText)
    }

    func vbHeadline() -> some View {
        font(VBFont.headline)
            .foregroundStyle(Color.vbMainText)
    }

    func vbBody() -> some View {
        font(VBFont.body)
            .foregroundStyle(Color.vbMainText)
    }

    func vbCaption() -> some View {
        font(VBFont.caption)
            .foregroundStyle(Color.vbSecondaryText)
    }

    func vbButton() -> some View {
        font(VBFont.button)
            .foregroundStyle(.white)
    }
}

#Preview("Typography") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Hero Text").vbHero()
        Text("Title Text").vbTitle()
        Text("Headline Text").vbHeadline()
        Text("Body Text").vbBody()
        Text("Caption Text").vbCaption()
    }
    .padding()
}
