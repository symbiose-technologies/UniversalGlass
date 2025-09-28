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
                fallbackBody(configuration: configuration, variant: .standard)
            }
        } else {
            fallbackBody(configuration: configuration, variant: .standard)
        }
    }

    @ViewBuilder
    private func fallbackBody(
        configuration: Configuration,
        variant: CompatibleGlassLegacyButton.Variant
    ) -> some View {
        CompatibleGlassLegacyButton(
            configuration: configuration,
            rendering: rendering,
            variant: variant
        )
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
                fallbackBody(configuration: configuration, variant: .prominent)
            }
        } else {
            fallbackBody(configuration: configuration, variant: .prominent)
        }
    }

    @ViewBuilder
    private func fallbackBody(
        configuration: Configuration,
        variant: CompatibleGlassLegacyButton.Variant
    ) -> some View {
        CompatibleGlassLegacyButton(
            configuration: configuration,
            rendering: rendering,
            variant: variant
        )
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

// MARK: - Shared Resolution

// `@inline(__always)` requests the compiler to substitute the function body at every call site.
@inline(__always)
private func resolveShouldUseGlass(for rendering: CompatibleGlassRendering) -> Bool {
    // Inline to keep the availability-heavy branching from adding extra view layers.
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

// MARK: - Legacy Fallback Rendering

// Provides a material-driven recreation of the glass button for platforms that
// do not ship the native style (or when callers force material rendering).
private struct CompatibleGlassLegacyButton: View {
    enum Variant {
        case standard
        case prominent
    }

    let configuration: PrimitiveButtonStyle.Configuration
    let rendering: CompatibleGlassRendering
    let variant: Variant

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        configuration.label
            .padding(padding)
            .contentShape(.capsule)
            .background(background)
            .clipShape(Capsule())
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowYOffset)
            .opacity(isEnabled ? 1 : 0.6)
    }

    private var padding: EdgeInsets {
        let metrics = metrics(for: controlSize)
        return EdgeInsets(
            top: metrics.vertical,
            leading: metrics.horizontal,
            bottom: metrics.vertical,
            trailing: metrics.horizontal
        )
    }

    private func metrics(for controlSize: ControlSize) -> (horizontal: CGFloat, vertical: CGFloat) {
        let prominent = variant == .prominent

        switch controlSize {
        case .mini:
            return prominent ? (12, 6) : (10, 5)
        case .small:
            return prominent ? (14, 7) : (12, 6)
        case .regular:
            return prominent ? (18, 9) : (16, 8)
        case .large:
            return prominent ? (20, 10) : (18, 9)
        case .extraLarge:
            return prominent ? (24, 12) : (22, 11)
        @unknown default:
            return prominent ? (18, 9) : (16, 8)
        }
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            Color.clear
                .compatibleGlassEffect(backgroundGlass, in: Capsule(), rendering: fallbackRendering)

            Capsule()
                .strokeBorder(borderGradient, lineWidth: borderWidth)
                .blendMode(.plusLighter)
                .opacity(borderOpacity)

            Capsule()
                .fill(highlightGradient)
                .opacity(baseHighlightOpacity)
        }
    }

    private var backgroundGlass: CompatibleGlass {
        var glass: CompatibleGlass

        switch variant {
        case .standard:
            glass = .clear
        case .prominent:
            glass = .regular
        }

        return glass.interactive()
    }

    private var fallbackRendering: CompatibleGlassRendering {
        if #available(iOS 26.0, macOS 26.0, *), case .forceMaterial = rendering {
            return .forceMaterial
        }

        return .automatic
    }

    private var borderWidth: CGFloat {
        variant == .prominent ? 1.4 : 1
    }

    private var borderOpacity: CGFloat {
        let base: CGFloat = variant == .prominent ? 0.7 : 0.5
        return base * (isEnabled ? 1 : 0.45)
    }

    private var borderGradient: LinearGradient {
        let top = Color.white.opacity(colorScheme == .dark ? 0.55 : 0.75)
        let bottom = Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25)
        return LinearGradient(
            colors: [top, bottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var highlightGradient: LinearGradient {
        let start = Color.white.opacity(colorScheme == .dark ? 0.28 : 0.45)
        let end = Color.white.opacity(colorScheme == .dark ? 0.05 : 0.12)
        return LinearGradient(
            colors: [start, end],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var baseHighlightOpacity: CGFloat {
        let base: CGFloat = variant == .prominent ? 0.24 : 0.18
        return base * (isEnabled ? 1 : 0.55)
    }

    private var shadowColor: Color {
        let base: Double = variant == .prominent ? 0.24 : 0.18
        return Color.black.opacity(isEnabled ? base : base * 0.35)
    }

    private var shadowRadius: CGFloat {
        variant == .prominent ? 14 : 10
    }

    private var shadowYOffset: CGFloat {
        variant == .prominent ? 4 : 3
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

// Availability ladders scope these shims to the window where the native `.glass` style is absent.

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 11.0, obsoleted: 26.0)
public extension PrimitiveButtonStyle where Self == CompatibleGlassButtonStyle {
    static var glass: CompatibleGlassButtonStyle {
        // Within the back-deployment window, calling `.glass` returns our compatibility wrapper.
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
        // Same idea for prominent: older platforms map the alias to our custom primitive style.
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

#Preview("ButtonStyle: .glass (Material Fallback)") {
    Button("Fallback Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .buttonStyle(
            .compatibleGlass(rendering: .forceMaterial)
        )
}
#endif
