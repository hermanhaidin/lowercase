import SwiftUI

struct MarkdownTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    var onChange: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MarkdownUITextView {
        let storage = MarkdownTextStorage(highlighter: MarkdownHighlighter(theme: .default))
        let view = MarkdownUITextView(storage: storage)
        view.delegate = context.coordinator

        if !text.isEmpty {
            context.coordinator.applyExternalText(text, to: view)
        }

        return view
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MarkdownUITextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        let height = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        return CGSize(width: width, height: height)
    }

    func updateUIView(_ uiView: MarkdownUITextView, context: Context) {
        context.coordinator.parent = self

        if uiView.text != text {
            context.coordinator.applyExternalText(text, to: uiView)
        }

        context.coordinator.focusTask?.cancel()
        context.coordinator.focusTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            if isFocused, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFocused, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextView
        var focusTask: Task<Void, Never>?
        var caretTask: Task<Void, Never>?
        private var isApplyingExternal = false

        init(parent: MarkdownTextView) {
            self.parent = parent
        }

        func applyExternalText(_ text: String, to view: MarkdownUITextView) {
            isApplyingExternal = true
            defer { isApplyingExternal = false }

            let storage = view.markdownStorage
            let fullRange = NSRange(location: 0, length: storage.length)
            storage.replaceCharacters(in: fullRange, with: text)

            let newLen = (text as NSString).length
            let prev = view.selectedRange
            let clampedLocation = min(prev.location, newLen)
            let clampedLength = min(prev.length, newLen - clampedLocation)
            view.selectedRange = NSRange(location: clampedLocation, length: clampedLength)

            view.invalidateIntrinsicContentSize()
        }

        func textViewDidChange(_ textView: UITextView) {
            textView.invalidateIntrinsicContentSize()
            guard !isApplyingExternal else { return }
            let newText = textView.text ?? ""
            if parent.text != newText {
                parent.text = newText
                parent.onChange(newText)
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            scrollCaretToVisible(in: textView)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if !parent.isFocused {
                parent.isFocused = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.isFocused {
                parent.isFocused = false
            }
        }

        private func scrollCaretToVisible(in textView: UITextView) {
            guard let selection = textView.selectedTextRange else { return }
            let caret = textView.caretRect(for: selection.end)
            guard !caret.isNull, !caret.isEmpty else { return }

            guard let parentView = textView.superview,
                  let scrollView = sequence(first: parentView, next: \.superview)
                    .compactMap({ $0 as? UIScrollView })
                    .first else { return }

            let caretInScroll = textView.convert(caret, to: scrollView)
            let visibleTop = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
            let visibleBottom = scrollView.contentOffset.y + scrollView.bounds.height - scrollView.adjustedContentInset.bottom

            guard caretInScroll.minY < visibleTop
                    || caretInScroll.maxY > visibleBottom else { return }

            let target = caretInScroll.insetBy(dx: 0, dy: -24)

            caretTask?.cancel()
            caretTask = Task { @MainActor [weak scrollView] in
                await Task.yield()
                guard !Task.isCancelled, let scrollView else { return }
                scrollView.scrollRectToVisible(target, animated: false)
            }
        }
    }
}
