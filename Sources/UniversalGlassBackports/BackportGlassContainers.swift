import SwiftUI
import UniversalGlass

// MARK: - Back-Deployed Glass Containers

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable, message: "Use UniversalGlassEffectContainer instead - GlassEffectContainer is not available on visionOS")
@MainActor @ViewBuilder
public func GlassEffectContainer<Content: View>(
    spacing: CGFloat? = nil,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    UniversalGlassEffectContainer(spacing: spacing, content: content)
}

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable, message: "Use universalGlassEffectUnion and universalGlassEffectID instead - Glass effect morphing APIs are not available on visionOS")
public extension View {
    @ViewBuilder
    func glassEffectUnion<ID: Hashable & Sendable>(
        id: ID,
        namespace: Namespace.ID
    ) -> some View {
        universalGlassEffectUnion(id: id, namespace: namespace)
    }

    @ViewBuilder
    func glassEffectID<ID: Hashable & Sendable>(
        _ id: ID,
        in namespace: Namespace.ID
    ) -> some View {
        universalGlassEffectID(id, in: namespace)
    }
}

// MARK: - Back-Deployed Transitions

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable)
public enum GlassEffectTransitionBackport: Sendable {
    case materialize
    case matchedGeometry
    case identity

    fileprivate var universalValue: UniversalGlassEffectTransition {
        switch self {
        case .materialize: return .materialize
        case .matchedGeometry: return .matchedGeometry
        case .identity: return .identity
        }
    }
}

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable)
public typealias GlassEffectTransition = GlassEffectTransitionBackport

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable, message: "Use universalGlassEffectTransition instead - Glass effect transitions are not available on visionOS")
public extension View {
    @ViewBuilder
    func glassEffectTransition(
        _ transition: GlassEffectTransition
    ) -> some View {
        universalGlassEffectTransition(transition.universalValue)
    }
}
