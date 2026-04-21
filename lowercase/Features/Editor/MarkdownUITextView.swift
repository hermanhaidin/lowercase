import SwiftUI

final class MarkdownUITextView: UITextView {
    let markdownStorage: MarkdownTextStorage

    init(storage: MarkdownTextStorage) {
        self.markdownStorage = storage
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: .zero)
        container.widthTracksTextView = true
        container.lineFragmentPadding = 0
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: container)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func configure() {
        backgroundColor = .clear
        textColor = UIColor(Design.Colors.label)
        tintColor = UIColor(Design.Colors.accent)
        font = UIFont(name: "GeistPixel-Square", size: 17) ?? .systemFont(ofSize: 17)
        textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        alwaysBounceVertical = true
        keyboardAppearance = .dark
        dataDetectorTypes = []
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        smartQuotesType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
    }
}
