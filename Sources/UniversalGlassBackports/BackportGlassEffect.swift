import SwiftUI
import UniversalGlass

// MARK: - Back-Deployed `.glassEffect`

/// Mirrors SwiftUI's `.glassEffect` APIs on platforms that have not yet shipped glass.
@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 11.0, obsoleted: 26.0)
public extension View {
    func glassEffect() -> some View {
        compatibleGlassEffect()
    }

    func glassEffect<S: Shape>(in shape: S) -> some View {
        compatibleGlassEffect(in: shape)
    }

    func glassEffect(_ glass: CompatibleGlass) -> some View {
        compatibleGlassEffect(glass)
    }

    func glassEffect<S: Shape>(
        _ glass: CompatibleGlass,
        in shape: S
    ) -> some View {
        compatibleGlassEffect(glass, in: shape)
    }
}
