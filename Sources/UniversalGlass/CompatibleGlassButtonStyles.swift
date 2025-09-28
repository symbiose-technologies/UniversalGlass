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
#Preview("Modifier: compatibleGlassButtonStyle") {
    Button("Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .compatibleGlassButtonStyle(isProminent: false, rendering: .automatic)
}

#Preview("Modifier: compatibleGlassProminentButtonStyle") {
    Button("Prominent Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .compatibleGlassProminentButtonStyle(isProminent: true, rendering: .automatic)
}
#endif
