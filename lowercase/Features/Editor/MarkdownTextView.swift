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
        }

        func textViewDidChange(_ textView: UITextView) {
            guard !isApplyingExternal else { return }
            let newText = textView.text ?? ""
            if parent.text != newText {
                parent.text = newText
                parent.onChange(newText)
            }
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
    }
}
