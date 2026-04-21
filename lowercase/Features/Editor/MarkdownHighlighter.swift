import SwiftUI

nonisolated struct MarkdownHighlighter {
    let theme: MarkdownTheme

    func highlight(_ storage: NSMutableAttributedString, in range: NSRange) {
        let fullString = storage.string as NSString

        fullString.enumerateSubstrings(in: range, options: [.byLines]) { substring, substringRange, _, _ in
            guard let substring else { return }
            self.highlightLine(substring, substringRange: substringRange, storage: storage)
        }
    }

    private func highlightLine(_ line: String, substringRange: NSRange, storage: NSMutableAttributedString) {
        let lineLen = (line as NSString).length
        let lineRange = NSRange(location: 0, length: lineLen)

        if MarkdownPatterns.divider.firstMatch(in: line, range: lineRange) != nil {
            storage.addAttribute(.foregroundColor, value: theme.divider, range: substringRange)
            return
        }
        if MarkdownPatterns.heading.firstMatch(in: line, range: lineRange) != nil {
            storage.addAttribute(.foregroundColor, value: theme.heading, range: substringRange)
            return
        }
        if MarkdownPatterns.quote.firstMatch(in: line, range: lineRange) != nil {
            storage.addAttribute(.foregroundColor, value: theme.quote, range: substringRange)
            return
        }

        var inlineStart = 0
        if let match = MarkdownPatterns.unorderedListMarker.firstMatch(in: line, range: lineRange) {
            let markerRange = match.range(at: 2)
            let abs = NSRange(location: substringRange.location + markerRange.location, length: markerRange.length)
            storage.addAttribute(.foregroundColor, value: theme.listMarker, range: abs)
            inlineStart = match.range.location + match.range.length
        } else if let match = MarkdownPatterns.orderedListMarker.firstMatch(in: line, range: lineRange) {
            let markerRange = match.range(at: 2)
            let abs = NSRange(location: substringRange.location + markerRange.location, length: markerRange.length)
            storage.addAttribute(.foregroundColor, value: theme.listMarker, range: abs)
            inlineStart = match.range.location + match.range.length
        }

        let inlineLineRange = NSRange(location: inlineStart, length: lineLen - inlineStart)
        guard inlineLineRange.length > 0 else { return }
        applyInlineTokens(
            line: line,
            lineRange: inlineLineRange,
            absOffset: substringRange.location,
            storage: storage
        )
    }

    private func applyInlineTokens(
        line: String,
        lineRange: NSRange,
        absOffset: Int,
        storage: NSMutableAttributedString
    ) {
        var consumed = IndexSet()

        for match in MarkdownPatterns.link.matches(in: line, range: lineRange) {
            let absStart = absOffset + match.range.location
            let absEnd = absStart + match.range.length
            if consumed.intersects(integersIn: absStart..<absEnd) { continue }
            consumed.insert(integersIn: absStart..<absEnd)

            let fullRange = match.range
            let labelRange = match.range(at: 1)
            let urlRange = match.range(at: 2)

            let openBracket = NSRange(location: absOffset + fullRange.location, length: 1)
            let closeBracket = NSRange(location: absOffset + labelRange.location + labelRange.length, length: 1)
            let openParen = NSRange(location: absOffset + labelRange.location + labelRange.length + 1, length: 1)
            let closeParen = NSRange(location: absOffset + fullRange.location + fullRange.length - 1, length: 1)
            let labelAbs = NSRange(location: absOffset + labelRange.location, length: labelRange.length)
            let urlAbs = NSRange(location: absOffset + urlRange.location, length: urlRange.length)

            storage.addAttribute(.foregroundColor, value: theme.linkBrackets, range: openBracket)
            storage.addAttribute(.foregroundColor, value: theme.linkBrackets, range: closeBracket)
            storage.addAttribute(.foregroundColor, value: theme.linkBrackets, range: openParen)
            storage.addAttribute(.foregroundColor, value: theme.linkBrackets, range: closeParen)
            if labelAbs.length > 0 {
                storage.addAttribute(.foregroundColor, value: theme.linkText, range: labelAbs)
            }
            if urlAbs.length > 0 {
                storage.addAttribute(.foregroundColor, value: theme.linkURL, range: urlAbs)
                storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: urlAbs)
            }
        }

        apply(pattern: MarkdownPatterns.code, line: line, lineRange: lineRange, absOffset: absOffset, consumed: &consumed) { abs in
            storage.addAttribute(.foregroundColor, value: theme.code, range: abs)
        }

        apply(pattern: MarkdownPatterns.strikethrough, line: line, lineRange: lineRange, absOffset: absOffset, consumed: &consumed) { abs in
            storage.addAttribute(.foregroundColor, value: theme.strike, range: abs)
            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: abs)
        }

        for pattern in [MarkdownPatterns.boldStar, MarkdownPatterns.boldUnderscore] {
            apply(pattern: pattern, line: line, lineRange: lineRange, absOffset: absOffset, consumed: &consumed) { abs in
                storage.addAttribute(.foregroundColor, value: theme.bold, range: abs)
            }
        }

        for pattern in [MarkdownPatterns.italicStar, MarkdownPatterns.italicUnderscore] {
            apply(pattern: pattern, line: line, lineRange: lineRange, absOffset: absOffset, consumed: &consumed) { abs in
                storage.addAttribute(.foregroundColor, value: theme.italic, range: abs)
            }
        }
    }

    private func apply(
        pattern: NSRegularExpression,
        line: String,
        lineRange: NSRange,
        absOffset: Int,
        consumed: inout IndexSet,
        action: (NSRange) -> Void
    ) {
        for match in pattern.matches(in: line, range: lineRange) {
            let absStart = absOffset + match.range.location
            let absEnd = absStart + match.range.length
            if consumed.intersects(integersIn: absStart..<absEnd) { continue }
            consumed.insert(integersIn: absStart..<absEnd)
            action(NSRange(location: absStart, length: match.range.length))
        }
    }
}
