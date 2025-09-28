import SwiftUI

// MARK: - Compatible Button Styles

public extension View {
    @ViewBuilder
    func compatibleGlassButtonStyle(
        isProminent: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.buttonStyle(.bordered)
            case .automatic, .forceGlass:
                self.buttonStyle(.glass)
            }
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

public extension View {
    @ViewBuilder
    func compatibleGlassProminentButtonStyle(
        isProminent: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.buttonStyle(.borderedProminent)
            case .automatic, .forceGlass:
                self.buttonStyle(.glassProminent)
            }
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
private struct CompatibleGlassButtonPreviewBackground<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.32),
                    Color(red: 0.32, green: 0.12, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .padding()
    }
}

#Preview("Modifier: compatibleGlassButtonStyle") {
    CompatibleGlassButtonPreviewBackground {
        Button("Glass Button") {}
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .compatibleGlassButtonStyle(isProminent: false, rendering: .automatic)
    }
}

#Preview("Modifier: compatibleGlassProminentButtonStyle") {
    CompatibleGlassButtonPreviewBackground {
        Button("Prominent Glass Button") {}
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .compatibleGlassProminentButtonStyle(isProminent: true, rendering: .automatic)
    }
}
#endif
