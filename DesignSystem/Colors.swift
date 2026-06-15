import SwiftUI

public extension Color {
    // Ink & Vitality palette (DESIGN.md)
    static let vbMainText = Color(hex: 0x1A1A1A)         // ink-black
    static let vbAccent = Color(hex: 0xC73E1D)           // cinnabar-red
    static let vbWarning = Color(hex: 0xD32F2F)          // warning-red
    static let vbBackground = Color(hex: 0xF5F0E1)       // xuan-paper
    static let vbCream = Color(hex: 0xF5F0E1)            // xuan-paper (alias)
    static let vbSecondaryText = Color(hex: 0x444748)    // on-surface-variant
    static let vbCardBackground = Color.white             // pure-white
    static let vbSuccess = Color(hex: 0x2E7D32)
    static let vbInkWash = Color(hex: 0x1A1A1A)          // ink-black
    static let vbXuanPaper = Color(hex: 0xF5F0E1)        // xuan-paper
    static let vbDistantMountain = Color(hex: 0x8B9DC3)  // mountain-blue
    static let vbSurfaceVariant = Color(hex: 0xE7E2D4)   // border / track
    static let vbOutline = Color(hex: 0x747878)           // outline
}

public struct VBColors {
    public static let mainText = Color.vbMainText
    public static let accent = Color.vbAccent
    public static let warning = Color.vbWarning
    public static let background = Color.vbBackground
    public static let cream = Color.vbCream
    public static let secondaryText = Color.vbSecondaryText
    public static let cardBackground = Color.vbCardBackground
    public static let success = Color.vbSuccess
    public static let inkWash = Color.vbInkWash
    public static let xuanPaper = Color.vbXuanPaper
    public static let distantMountain = Color.vbDistantMountain
    public static let surfaceVariant = Color.vbSurfaceVariant
    public static let outline = Color.vbOutline
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
