import SwiftUI

public enum VBDesignSystem {

    // MARK: - Colors

    public enum Colors {
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

    // MARK: - Typography

    public enum Typography {
        public static let hero = VBFont.hero
        public static let title = VBFont.title
        public static let headline = VBFont.headline
        public static let body = VBFont.body
        public static let caption = VBFont.caption
        public static let button = VBFont.button
    }

    // MARK: - Spacing

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    public enum Radius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let circle: CGFloat = 999
    }

    // MARK: - Min Tap Target

    public static let minTapTarget: CGFloat = 60
}
