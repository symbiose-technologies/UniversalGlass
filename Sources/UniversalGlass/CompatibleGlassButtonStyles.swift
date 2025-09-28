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
