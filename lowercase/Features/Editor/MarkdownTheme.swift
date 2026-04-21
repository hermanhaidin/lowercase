import SwiftUI

nonisolated struct MarkdownTheme {
    let baseFont: UIFont
    let baseColor: UIColor

    let heading: UIColor
    let bold: UIColor
    let italic: UIColor
    let strike: UIColor
    let code: UIColor
    let linkText: UIColor
    let linkURL: UIColor
    let linkBrackets: UIColor
    let quote: UIColor
    let listMarker: UIColor
    let divider: UIColor

    var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: baseFont,
            .foregroundColor: baseColor
        ]
    }

    static let `default` = MarkdownTheme(
        baseFont: UIFont(name: "GeistPixel-Square", size: 17) ?? .systemFont(ofSize: 17),
        baseColor: Self.color(0xFFFFFF),
        heading: Self.color(0xBF98AB),
        bold: Self.color(0xE6DEC2),
        italic: Self.color(0x70A6AD),
        strike: Self.color(0xA6A6A6),
        code: Self.color(0xBF98AB),
        linkText: Self.color(0xA6A6A6),
        linkURL: Self.color(0x70A6AD),
        linkBrackets: Self.color(0xFFFFFF),
        quote: Self.color(0xA6A6A6),
        listMarker: Self.color(0xBF98AB),
        divider: Self.color(0xBF98AB)
    )

    private static func color(_ hex: UInt32) -> UIColor {
        UIColor(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
