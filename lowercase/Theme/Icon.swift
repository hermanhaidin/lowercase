import SwiftUI

enum Icon: String {
    // Navigation
    case arrowLeft = "arrow-left"
    case chevronRight = "chevron-right"
    case chevronDown = "chevron-down"
    case chevronUpDown = "chevron-up-down"

    // Files & Folders
    case fileText = "file-text"
    case folderClosed = "folder-closed"
    case folderOpen = "folder-open"
    case folderDependent = "folder-dependent"
    case repositories

    // Actions
    case plus
    case plusCircle = "plus-circle"
    case cross
    case check
    case trash
    case pencilEdit = "pencil-edit"
    case share

    // Text Formatting
    case textBold = "text-bold"
    case textItalic = "text-italic"
    case textStrikethrough = "text-strikethrough"
    case textHeading = "text-heading"
    case link
    case codeWrap = "code-wrap"
    case slash

    // Lists
    case listOrdered = "list-ordered"
    case listUnordered = "list-unordered"
    case listNestLeft = "list-nest-left"
    case listNestRight = "list-nest-right"

    // History
    case cornerUpLeft = "corner-up-left"
    case cornerUpRight = "corner-up-right"

    // Misc
    case arrowUpDown = "arrow-up-down"
    case moreHorizontal = "more-horizontal"
    case cloud
    case devicePhone = "device-phone"
    case faceUnhappy = "face-unhappy"

    var image: Image {
        Image(rawValue)
    }
}
