import SwiftUI

enum Design {
    // MARK: - Colors
    enum Colors {
        // Backgrounds
        static let background = Color(hex: 0x151515)
        static let secondaryBackground = Color(hex: 0x222222)

        // Labels
        static let label = Color.white
        static let secondaryLabel = Color(hex: 0xA6A6A6)
        static let tertiaryLabel = Color(hex: 0x585858)

        // Accents
        static let accent = Color(hex: 0xBF98AB)
        static let secondaryAccent = Color(hex: 0xE6DEC2)
        static let tertiaryAccent = Color(hex: 0x70A6AD)

        // System
        static let separator = Color(hex: 0x373636)
        static let glassTint = Color(hex: 0x9F7C8F)
    }

    // MARK: - Spacing
    enum Spacing {
        static let contentMargin: Double = 20
        static let buttonMargin: Double = 36
        static let labelGap: Double = 12
        static let sectionGap: Double = 12
        static let treeIndent: Double = 16
        static let iconGap: Double = 8
    }

    // MARK: - Sizing
    enum Sizing {
        static let minRowHeight: Double = 44
        static let minSectionHeight: Double = 52
        static let sectionCornerRadius: Double = 26
        static let iconSize: Double = 16
        static let toolbarItemSize: Double = 44
    }
}
