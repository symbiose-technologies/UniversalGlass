import SwiftUI

// MARK: - Primitive Button Styles

public struct CompatibleGlassButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: UniversalGlassRendering

    public init(
        rendering: UniversalGlassRendering = .automatic
    ) {
        self.rendering = rendering
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        AnyView(resolvedBody(configuration: configuration))
    }

    @ViewBuilder
    private func resolvedBody(configuration: Configuration) -> some View {
        if shouldUseGlass {
            if #available(iOS 26.0, macOS 26.0, *) {
                GlassButtonStyle().makeBody(configuration: configuration)
            } else {
                fallbackBody(configuration: configuration, variant: .standard)
            }
        } else {
            fallbackBody(configuration: configuration, variant: .standard)
        }
    }

    @ViewBuilder
    private func fallbackBody(
        configuration: Configuration,
        variant: CompatibleGlassLegacyVariant
    ) -> some View {
        Button(action: configuration.trigger) {
            configuration.label
        }
        .buttonStyle(
            CompatibleGlassLegacyMaterialStyle(
                rendering: rendering,
                variant: variant
            )
        )
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

public struct CompatibleGlassProminentButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: UniversalGlassRendering

    public init(
        rendering: UniversalGlassRendering = .automatic
    ) {
        self.rendering = rendering
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        AnyView(resolvedBody(configuration: configuration))
    }

    @ViewBuilder
    private func resolvedBody(configuration: Configuration) -> some View {
        if shouldUseGlass {
            if #available(iOS 26.0, macOS 26.0, *) {
                GlassProminentButtonStyle().makeBody(configuration: configuration)
            } else {
                fallbackBody(configuration: configuration, variant: .prominent)
            }
        } else {
            fallbackBody(configuration: configuration, variant: .prominent)
        }
    }

    @ViewBuilder
    private func fallbackBody(
        configuration: Configuration,
        variant: CompatibleGlassLegacyVariant
    ) -> some View {
        Button(action: configuration.trigger) {
            configuration.label
        }
        .buttonStyle(
            CompatibleGlassLegacyMaterialStyle(
                rendering: rendering,
                variant: variant
            )
        )
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

// MARK: - Shared Resolution

// `@inline(__always)` requests the compiler to substitute the function body at every call site.
@inline(__always)
private func resolveShouldUseGlass(for rendering: UniversalGlassRendering) -> Bool {
    // Inline to keep the availability-heavy branching from adding extra view layers.
    if #available(iOS 26.0, macOS 26.0, *) {
        if case .material = rendering {
            return false
        }

        if case .glass = rendering {
            return true
        }

        return true
    } else {
        return false
    }
}
