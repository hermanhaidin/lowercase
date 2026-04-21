import Foundation

enum MarkdownToken {
    case heading
    case bold
    case italic
    case strikethrough
    case code
    case linkBrackets
    case linkText
    case linkURL
    case quote
    case listMarker
    case divider
}

nonisolated enum MarkdownPatterns {
    static let divider = try! NSRegularExpression(
        pattern: #"^[ \t]*(?:(?:\*[ \t]?){3,}|(?:-[ \t]?){3,}|(?:_[ \t]?){3,})[ \t]*$"#,
        options: [.anchorsMatchLines]
    )

    static let heading = try! NSRegularExpression(
        pattern: #"^#{1,6} .*$"#,
        options: [.anchorsMatchLines]
    )

    static let quote = try! NSRegularExpression(
        pattern: #"^> .*$"#,
        options: [.anchorsMatchLines]
    )

    static let unorderedListMarker = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+]) "#,
        options: [.anchorsMatchLines]
    )

    static let orderedListMarker = try! NSRegularExpression(
        pattern: #"^(\s*)(\d+\.)\s"#,
        options: [.anchorsMatchLines]
    )

    static let link = try! NSRegularExpression(
        pattern: #"\[([^\]\n]*)\]\(([^)\n]*)\)"#
    )

    static let code = try! NSRegularExpression(
        pattern: #"`([^`\n]+)`"#
    )

    static let strikethrough = try! NSRegularExpression(
        pattern: #"~~([^~\n]+)~~"#
    )

    static let boldStar = try! NSRegularExpression(
        pattern: #"\*\*([^*\n]+?)\*\*"#
    )

    static let boldUnderscore = try! NSRegularExpression(
        pattern: #"__([^_\n]+?)__"#
    )

    static let italicStar = try! NSRegularExpression(
        pattern: #"(?<![*])\*(?!\s|\*)([^*\n]+?)(?<!\s)\*(?!\*)"#
    )

    static let italicUnderscore = try! NSRegularExpression(
        pattern: #"(?<![_])_(?!\s|_)([^_\n]+?)(?<!\s)_(?!_)"#
    )
}
