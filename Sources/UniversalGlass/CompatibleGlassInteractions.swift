import SwiftUI

// MARK: - Compatible Scroll Extension Mode

public enum CompatibleScrollExtensionMode {
    case underSidebar
    case none
}

// MARK: - Compatible Glass Effect Transition

public enum CompatibleGlassEffectTransition {
    case materialize
    case none
}

// MARK: - Interaction Helpers

public extension View {

    /// Sets scroll extension mode with backward compatibility
    @ViewBuilder
    func compatibleScrollExtensionMode(_ mode: CompatibleScrollExtensionMode) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch mode {
            case .underSidebar:
                // Note: This API may not exist yet, commenting out for now
                self // self.scrollExtensionMode(.underSidebar)
            case .none:
                self
            }
        } else {
            self
        }
    }

    /// Applies a glass effect transition with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectTransition(
        _ transition: CompatibleGlassEffectTransition,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                switch transition {
                case .materialize:
                    self.glassEffectTransition(.materialize)
                case .none:
                    self
                }
            }
        } else {
            self
        }
    }
}
