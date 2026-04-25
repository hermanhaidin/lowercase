import SwiftUI

@Observable
final class EditorController {
    @ObservationIgnored
    weak var textView: MarkdownUITextView?

    func apply(_ action: MarkdownAction) {
        guard let textView else { return }
        switch action {
        case .undo: textView.undoManager?.undo()
        case .redo: textView.undoManager?.redo()
        case .heading: cycleHeading(in: textView)
        case .bold: toggleWrap(markers: "**", in: textView)
        case .italic: toggleWrap(markers: "*", in: textView)
        case .strikethrough: toggleWrap(markers: "~~", in: textView)
        case .code: toggleWrap(markers: "`", in: textView)
        case .link: insertLink(in: textView)
        case .unorderedList: toggleLinePrefix("- ", in: textView)
        case .orderedList: toggleOrderedList(in: textView)
        case .indent: changeIndent(by: +1, in: textView)
        case .outdent: changeIndent(by: -1, in: textView)
        }
    }
}

// MARK: - Replacement primitive

private extension EditorController {
    func apply(replacement: String, in nsRange: NSRange, postSelection: NSRange, view: UITextView) {
        guard let start = view.position(from: view.beginningOfDocument, offset: nsRange.location),
              let end = view.position(from: start, offset: nsRange.length),
              let textRange = view.textRange(from: start, to: end) else { return }
        view.replace(textRange, withText: replacement)
        let totalLen = (view.text as NSString).length
        let location = min(max(0, postSelection.location), totalLen)
        let length = min(postSelection.length, totalLen - location)
        view.selectedRange = NSRange(location: location, length: length)
    }
}

// MARK: - Heading cycle

private extension EditorController {
    static let headingRegex = try! NSRegularExpression(pattern: "^(#{1,6}) ")

    func cycleHeading(in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange
        let lineRange = nsString.lineRange(for: NSRange(location: selection.location, length: 0))
        let hasNewline = lineRange.length > 0
            && nsString.character(at: lineRange.location + lineRange.length - 1) == 0x0A
        let contentRange = hasNewline
            ? NSRange(location: lineRange.location, length: lineRange.length - 1)
            : lineRange
        let line = nsString.substring(with: contentRange)
        let lineNs = line as NSString

        var currentHashCount = 0
        var oldPrefixLength = 0
        if let match = Self.headingRegex.firstMatch(in: line, range: NSRange(location: 0, length: lineNs.length)) {
            currentHashCount = match.range(at: 1).length
            oldPrefixLength = match.range.length
        }

        let newHashCount = currentHashCount == 6 ? 0 : currentHashCount + 1
        let newPrefix = newHashCount == 0 ? "" : String(repeating: "#", count: newHashCount) + " "
        let content = lineNs.substring(from: oldPrefixLength)
        let replacement = newPrefix + content
        let prefixDelta = (newPrefix as NSString).length - oldPrefixLength
        let newSelectionLocation = max(contentRange.location, selection.location + prefixDelta)

        apply(
            replacement: replacement,
            in: contentRange,
            postSelection: NSRange(location: newSelectionLocation, length: 0),
            view: view
        )
    }
}

// MARK: - Wrap toggle (bold / italic / strikethrough / code)

private extension EditorController {
    func toggleWrap(markers: String, in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange
        let markersLen = (markers as NSString).length

        let leftStart = selection.location - markersLen
        let rightEnd = selection.location + selection.length + markersLen
        let alreadyWrapped = leftStart >= 0
            && rightEnd <= nsString.length
            && nsString.substring(with: NSRange(location: leftStart, length: markersLen)) == markers
            && nsString.substring(with: NSRange(location: selection.location + selection.length, length: markersLen)) == markers

        if alreadyWrapped {
            let inner = nsString.substring(with: selection)
            let unwrapRange = NSRange(location: leftStart, length: rightEnd - leftStart)
            apply(
                replacement: inner,
                in: unwrapRange,
                postSelection: NSRange(location: leftStart, length: selection.length),
                view: view
            )
        } else {
            let selectedText = selection.length == 0 ? "" : nsString.substring(with: selection)
            let replacement = markers + selectedText + markers
            apply(
                replacement: replacement,
                in: selection,
                postSelection: NSRange(location: selection.location + markersLen, length: selection.length),
                view: view
            )
        }
    }
}

// MARK: - Link

private extension EditorController {
    func insertLink(in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange

        if selection.length > 0 {
            let selectedText = nsString.substring(with: selection)
            let replacement = "[\(selectedText)]()"
            let cursorOffset = ("[\(selectedText)](" as NSString).length
            apply(
                replacement: replacement,
                in: selection,
                postSelection: NSRange(location: selection.location + cursorOffset, length: 0),
                view: view
            )
            return
        }

        let bracketStart = selection.location - 1
        let trailingRange = NSRange(location: selection.location, length: 3)
        let isInsideEmpty = bracketStart >= 0
            && trailingRange.location + trailingRange.length <= nsString.length
            && nsString.substring(with: NSRange(location: bracketStart, length: 1)) == "["
            && nsString.substring(with: trailingRange) == "]()"

        if isInsideEmpty {
            apply(
                replacement: "",
                in: NSRange(location: bracketStart, length: 4),
                postSelection: NSRange(location: bracketStart, length: 0),
                view: view
            )
        } else {
            apply(
                replacement: "[]()",
                in: selection,
                postSelection: NSRange(location: selection.location + 1, length: 0),
                view: view
            )
        }
    }
}

// MARK: - Line-prefix toggle (unordered list)

private extension EditorController {
    func toggleLinePrefix(_ marker: String, in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange
        let paragraphRange = nsString.paragraphRange(for: selection)
        let paragraph = nsString.substring(with: paragraphRange)
        let paragraphHasTrailingNewline = paragraph.hasSuffix("\n")
        let body = paragraphHasTrailingNewline ? String(paragraph.dropLast()) : paragraph
        let lines = body.components(separatedBy: "\n")

        let nonEmptyLines = lines.filter { !$0.isEmpty }
        let allHavePrefix = !nonEmptyLines.isEmpty
            && nonEmptyLines.allSatisfy { $0.hasPrefix(marker) }

        var firstLineDelta = 0
        let newLines: [String] = lines.enumerated().map { idx, line in
            if line.isEmpty { return line }
            if allHavePrefix {
                if idx == 0 { firstLineDelta = -(marker as NSString).length }
                return String(line.dropFirst(marker.count))
            }
            if line.hasPrefix(marker) { return line }
            if idx == 0 { firstLineDelta = (marker as NSString).length }
            return marker + line
        }

        let newBody = newLines.joined(separator: "\n")
        let replacement = paragraphHasTrailingNewline ? newBody + "\n" : newBody
        let newSelectionLocation = max(paragraphRange.location, selection.location + firstLineDelta)

        apply(
            replacement: replacement,
            in: paragraphRange,
            postSelection: NSRange(location: newSelectionLocation, length: 0),
            view: view
        )
    }
}

// MARK: - Ordered list toggle

private extension EditorController {
    static let orderedRegex = try! NSRegularExpression(pattern: #"^\d+\. "#)

    func toggleOrderedList(in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange
        let paragraphRange = nsString.paragraphRange(for: selection)
        let paragraph = nsString.substring(with: paragraphRange)
        let paragraphHasTrailingNewline = paragraph.hasSuffix("\n")
        let body = paragraphHasTrailingNewline ? String(paragraph.dropLast()) : paragraph
        let lines = body.components(separatedBy: "\n")

        func numberedPrefixLen(_ line: String) -> Int? {
            let lineNs = line as NSString
            guard let match = Self.orderedRegex.firstMatch(in: line, range: NSRange(location: 0, length: lineNs.length)) else { return nil }
            return match.range.length
        }

        let nonEmptyLines = lines.filter { !$0.isEmpty }
        let allHavePrefix = !nonEmptyLines.isEmpty
            && nonEmptyLines.allSatisfy { numberedPrefixLen($0) != nil }

        var firstLineDelta = 0
        let newLines: [String] = lines.enumerated().map { idx, line in
            if line.isEmpty { return line }
            if allHavePrefix {
                if let prefixLen = numberedPrefixLen(line) {
                    if idx == 0 { firstLineDelta = -prefixLen }
                    return String((line as NSString).substring(from: prefixLen))
                }
                return line
            }
            if numberedPrefixLen(line) != nil { return line }
            if idx == 0 { firstLineDelta = ("1. " as NSString).length }
            return "1. " + line
        }

        let newBody = newLines.joined(separator: "\n")
        let replacement = paragraphHasTrailingNewline ? newBody + "\n" : newBody
        let newSelectionLocation = max(paragraphRange.location, selection.location + firstLineDelta)

        apply(
            replacement: replacement,
            in: paragraphRange,
            postSelection: NSRange(location: newSelectionLocation, length: 0),
            view: view
        )
    }
}

// MARK: - Indent / outdent

private extension EditorController {
    func changeIndent(by direction: Int, in view: UITextView) {
        let nsString = view.text as NSString
        let selection = view.selectedRange
        let paragraphRange = nsString.paragraphRange(for: selection)
        let paragraph = nsString.substring(with: paragraphRange)
        let paragraphHasTrailingNewline = paragraph.hasSuffix("\n")
        let body = paragraphHasTrailingNewline ? String(paragraph.dropLast()) : paragraph
        let lines = body.components(separatedBy: "\n")
        let indent = "  "

        var firstLineDelta = 0
        let newLines: [String] = lines.enumerated().map { idx, line in
            if direction > 0 {
                if idx == 0 { firstLineDelta = (indent as NSString).length }
                return indent + line
            }
            if line.hasPrefix(indent) {
                if idx == 0 { firstLineDelta = -(indent as NSString).length }
                return String(line.dropFirst(indent.count))
            }
            if line.hasPrefix(" ") || line.hasPrefix("\t") {
                if idx == 0 { firstLineDelta = -1 }
                return String(line.dropFirst())
            }
            return line
        }

        let newBody = newLines.joined(separator: "\n")
        let replacement = paragraphHasTrailingNewline ? newBody + "\n" : newBody
        let newSelectionLocation = max(paragraphRange.location, selection.location + firstLineDelta)

        apply(
            replacement: replacement,
            in: paragraphRange,
            postSelection: NSRange(location: newSelectionLocation, length: 0),
            view: view
        )
    }
}
