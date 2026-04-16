import SwiftUI

struct ToolbarTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    var isEditable: Bool
    var onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ToolbarInputField {
        let field = ToolbarInputField()
        field.delegate = context.coordinator
        field.font = UIFont(name: "GeistPixel-Square", size: 17) ?? .systemFont(ofSize: 17)
        field.textColor = UIColor(Design.Colors.label)
        field.tintColor = UIColor(Design.Colors.accent)
        field.textAlignment = .center
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.spellCheckingType = .no
        field.returnKeyType = .default
        field.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        field.text = text
        return field
    }

    func updateUIView(_ uiView: ToolbarInputField, context: Context) {
        context.coordinator.parent = self

        if uiView.text != text {
            uiView.text = text
        }

        uiView.isUserInteractionEnabled = isEditable

        context.coordinator.focusTask?.cancel()
        context.coordinator.focusTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            if isEditable, isFocused, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if (!isEditable || !isFocused), uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ToolbarTextField
        var focusTask: Task<Void, Never>?

        init(parent: ToolbarTextField) {
            self.parent = parent
        }

        @objc func textChanged(_ field: UITextField) {
            let newText = field.text ?? ""
            if parent.text != newText {
                parent.text = newText
            }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            if !parent.isFocused {
                parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.isFocused {
                parent.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit()
            return true
        }
    }
}

// MARK: - UITextField Subclass

/// Reports intrinsicContentSize based on actual text width so the toolbar
/// title slot gets a correct frame — prevents layout bounce on appear.
final class ToolbarInputField: UITextField {
    private let horizontalPadding: Double = 8

    override var intrinsicContentSize: CGSize {
        guard let font, let text, !text.isEmpty else {
            return super.intrinsicContentSize
        }
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        return CGSize(width: ceil(textWidth) + horizontalPadding * 2, height: super.intrinsicContentSize.height)
    }

    override var text: String? {
        didSet { invalidateIntrinsicContentSize() }
    }
}
