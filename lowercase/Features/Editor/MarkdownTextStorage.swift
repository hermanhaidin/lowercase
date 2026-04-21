import SwiftUI

nonisolated final class MarkdownTextStorage: NSTextStorage {
    private let backing = NSMutableAttributedString()
    private let highlighter: MarkdownHighlighter
    private let baseAttributes: [NSAttributedString.Key: Any]

    init(highlighter: MarkdownHighlighter) {
        self.highlighter = highlighter
        self.baseAttributes = highlighter.theme.baseAttributes
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override var string: String {
        backing.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        backing.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backing.replaceCharacters(in: range, with: str)
        let delta = (str as NSString).length - range.length
        edited(.editedCharacters, range: range, changeInLength: delta)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()
        backing.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    override func processEditing() {
        if editedMask.contains(.editedCharacters) {
            let paragraph = (backing.string as NSString).paragraphRange(for: editedRange)
            backing.setAttributes(baseAttributes, range: paragraph)
            highlighter.highlight(backing, in: paragraph)
        }
        super.processEditing()
    }
}
