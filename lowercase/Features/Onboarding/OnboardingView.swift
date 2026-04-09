import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            content
                .padding(.horizontal, Design.Spacing.buttonMargin)

            Spacer()

            continueButton
                .padding(.horizontal, Design.Spacing.buttonMargin)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Design.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Subviews

private struct OnboardingContent: View {
    var body: some View {
        VStack(spacing: Design.Spacing.labelGap) {
            Icon.repositories.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.secondaryAccent)
                .padding(.bottom, Design.Spacing.iconGap)

            Text("Your thoughts are yours...")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)

            Text("Notes are stored as text files on your device. Open them anywhere, even offline.")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Design.Spacing.contentMargin)
        }
    }
}

private struct ContinueButton: View {
    var action: () -> Void

    var body: some View {
        Button("Continue", action: action)
            .font(.geistPixel)
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(Design.Colors.glassTint)
    }
}

// MARK: - Private

private extension OnboardingView {
    var content: some View {
        OnboardingContent()
    }

    var continueButton: some View {
        ContinueButton(action: onContinue)
    }
}

#Preview {
    NavigationStack {
        OnboardingView(onContinue: {})
    }
}
