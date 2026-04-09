import SwiftUI

struct NewFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var folderName = ""
    @State private var storeInICloud = false
    @State private var isCreating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: Design.Spacing.sectionGap) {
                folderNameSection

                iCloudToggleSection
            }
            .padding(.horizontal, Design.Spacing.contentMargin)
            .padding(.top, Design.Spacing.contentMargin)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Design.Colors.background)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New folder")
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.secondaryLabel)
            }
        }
        .safeAreaBar(edge: .bottom) {
            createButton
                .padding(.horizontal, Design.Spacing.buttonMargin)
                .padding(.bottom, isTextFieldFocused ? 16 : 0)
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - Subviews

private struct FolderNameSection: View {
    @Binding var folderName: String
    var focusBinding: FocusState<Bool>.Binding

    var body: some View {
        TextField(
            "",
            text: $folderName,
            prompt: Text("Folder name e.g. \"daily\"")
                .foregroundStyle(Design.Colors.tertiaryLabel)
        )
        .font(.geistPixel)
        .foregroundStyle(Design.Colors.label)
        .tint(Design.Colors.accent)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused(focusBinding)
        .padding(.horizontal)
        .frame(minHeight: Design.Sizing.minSectionHeight)
        .background(Design.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Sizing.sectionCornerRadius))
    }
}

private struct ICloudToggleSection: View {
    @Binding var storeInICloud: Bool
    private let iCloudAvailable = StorageRoot.iCloud.isAvailable

    var body: some View {
        Toggle(isOn: $storeInICloud) {
            Text("Store in iCloud")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
        }
        .tint(Design.Colors.tertiaryAccent)
        .disabled(!iCloudAvailable)
        .padding(.horizontal)
        .frame(minHeight: Design.Sizing.minSectionHeight)
        .background(Design.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Sizing.sectionCornerRadius))
    }
}

private struct CreateButton: View {
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button("Create", action: action)
            .font(.geistPixel)
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(Design.Colors.glassTint)
            .disabled(!isEnabled)
    }
}

// MARK: - Private

private extension NewFolderView {
    var isCreateEnabled: Bool {
        !folderName.trimmingCharacters(in: .whitespaces).isEmpty && !isCreating
    }

    var folderNameSection: some View {
        FolderNameSection(folderName: $folderName, focusBinding: $isTextFieldFocused)
    }

    var iCloudToggleSection: some View {
        ICloudToggleSection(storeInICloud: $storeInICloud)
    }

    var createButton: some View {
        CreateButton(isEnabled: isCreateEnabled, action: createFolder)
    }

    func createFolder() {
        let trimmed = folderName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isTextFieldFocused = false
        isCreating = true

        Task {
            do {
                let root: StorageRoot = storeInICloud ? .iCloud : .local
                if fileStore.activeRoot != root {
                    try await fileStore.switchRoot(to: root)
                }
                try await fileStore.createFolder(named: trimmed)
                hasCompletedOnboarding = true
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
                isCreating = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewFolderView()
            .environment(FileStore())
    }
}
