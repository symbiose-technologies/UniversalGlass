import SwiftUI

// MARK: - Glass Effect Container

/// A container that optimizes rendering performance for multiple liquid glass effects
@MainActor @ViewBuilder
public func CompatibleGlassEffectContainer<Content: View>(
    spacing: CGFloat,
    rendering: CompatibleGlassRendering = .automatic,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    if #available(iOS 26.0, macOS 26.0, *) {
        switch rendering {
        case .forceMaterial:
            content()
        case .automatic, .forceGlass:
            GlassEffectContainer(spacing: spacing, content: content)
        }
    } else {
        content()
    }
}

// MARK: - Glass Effect Morphing Helpers

public extension View {

    /// Applies a glass effect union for morphing transitions with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectUnion<ID: Hashable & Sendable>(
        id: ID,
        namespace: Namespace.ID,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                self.glassEffectUnion(id: id, namespace: namespace)
            }
        } else {
            self
        }
    }

    /// Applies a glass effect ID for morphing transitions with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectID<ID: Hashable & Sendable>(
        _ id: ID,
        in namespace: Namespace.ID,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                self.glassEffectID(id, in: namespace)
            }
        } else {
            self
        }
    }
}
