import SwiftUI

// MARK: - Primitive Button Styles

public struct CompatibleGlassButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: CompatibleGlassRendering

    public init(
        rendering: CompatibleGlassRendering = .automatic
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
                BorderedButtonStyle().makeBody(configuration: configuration)
            }
        } else {
            BorderedButtonStyle().makeBody(configuration: configuration)
        }
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

public struct CompatibleGlassProminentButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: CompatibleGlassRendering

    public init(
        rendering: CompatibleGlassRendering = .automatic
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
                BorderedProminentButtonStyle().makeBody(configuration: configuration)
            }
        } else {
            BorderedProminentButtonStyle().makeBody(configuration: configuration)
        }
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

// MARK: - Shared Resolution

@inline(__always)
private func resolveShouldUseGlass(for rendering: CompatibleGlassRendering) -> Bool {
    if #available(iOS 26.0, macOS 26.0, *) {
        if case .forceMaterial = rendering {
            return false
        }

        if case .forceGlass = rendering {
            return true
        }

        return true
    } else {
        return false
    }
}

// MARK: - Static Helpers

public extension PrimitiveButtonStyle where Self == CompatibleGlassButtonStyle {
    static func compatibleGlass(
        rendering: CompatibleGlassRendering = .automatic
    ) -> CompatibleGlassButtonStyle {
        CompatibleGlassButtonStyle(rendering: rendering)
    }
}

public extension PrimitiveButtonStyle where Self == CompatibleGlassProminentButtonStyle {
    static func compatibleGlassProminent(
        rendering: CompatibleGlassRendering = .automatic
    ) -> CompatibleGlassProminentButtonStyle {
        CompatibleGlassProminentButtonStyle(rendering: rendering)
    }
}

// MARK: - Back-Deployed Aliases

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 11.0, obsoleted: 26.0)
public extension PrimitiveButtonStyle where Self == CompatibleGlassButtonStyle {
    static var glass: CompatibleGlassButtonStyle {
        CompatibleGlassButtonStyle()
    }
}

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 11.0, obsoleted: 26.0)
public extension PrimitiveButtonStyle where Self == CompatibleGlassProminentButtonStyle {
    static var glassProminent: CompatibleGlassProminentButtonStyle {
        CompatibleGlassProminentButtonStyle()
    }
}

// MARK: - Backwards Compatible Modifiers

public extension View {
    @ViewBuilder
    func compatibleGlassButtonStyle(
        isProminent _: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        switch rendering {
        case .automatic:
            self.buttonStyle(.glass)
        case .forceGlass, .forceMaterial:
            self.buttonStyle(
                .compatibleGlass(rendering: rendering)
            )
        }
    }

    @ViewBuilder
    func compatibleGlassProminentButtonStyle(
        isProminent _: Bool = true,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        switch rendering {
        case .automatic:
            self.buttonStyle(.glassProminent)
        case .forceGlass, .forceMaterial:
            self.buttonStyle(
                .compatibleGlassProminent(rendering: rendering)
            )
        }
    }
}

#if DEBUG
#Preview("ButtonStyle: .compatibleGlass") {
    Button("Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .buttonStyle(.glass)
}

#Preview("ButtonStyle: .compatibleGlassProminent") {
    Button("Prominent Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .buttonStyle(.glassProminent)
}
#endif
