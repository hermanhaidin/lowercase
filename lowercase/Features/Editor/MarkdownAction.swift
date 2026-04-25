import SwiftUI

enum MarkdownAction: String, CaseIterable, Identifiable {
    case undo
    case redo
    case heading
    case bold
    case italic
    case strikethrough
    case code
    case link
    case unorderedList
    case orderedList
    case indent
    case outdent

    var id: String { rawValue }

    var icon: Icon {
        switch self {
        case .undo: .cornerUpLeft
        case .redo: .cornerUpRight
        case .heading: .textHeading
        case .bold: .textBold
        case .italic: .textItalic
        case .strikethrough: .textStrikethrough
        case .code: .codeWrap
        case .link: .link
        case .unorderedList: .listUnordered
        case .orderedList: .listOrdered
        case .indent: .listNestRight
        case .outdent: .listNestLeft
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .undo: "Undo"
        case .redo: "Redo"
        case .heading: "Heading"
        case .bold: "Bold"
        case .italic: "Italic"
        case .strikethrough: "Strikethrough"
        case .code: "Code"
        case .link: "Link"
        case .unorderedList: "Bullet list"
        case .orderedList: "Numbered list"
        case .indent: "Indent"
        case .outdent: "Outdent"
        }
    }
}
