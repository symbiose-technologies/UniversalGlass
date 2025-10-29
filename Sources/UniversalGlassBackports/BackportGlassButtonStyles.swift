import SwiftUI
import UniversalGlass

// MARK: - Back-Deployed Button Styles

/// Exposes SwiftUI's `.glass` button style names on platforms where they are not yet available.
@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable, message: "Use UniversalGlassButtonStyle directly - Glass button styles are not available on visionOS")
public extension PrimitiveButtonStyle where Self == UniversalGlassButtonStyle {
    static var glass: UniversalGlassButtonStyle {
        UniversalGlassButtonStyle()
    }
}

@available(iOS, introduced: 13.0, obsoleted: 26.0)
@available(macOS, introduced: 11.0, obsoleted: 26.0)
@available(macCatalyst, introduced: 13.0, obsoleted: 26.0)
@available(tvOS, introduced: 18.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, unavailable, message: "Use UniversalGlassProminentButtonStyle directly - Glass button styles are not available on visionOS")
public extension PrimitiveButtonStyle where Self == UniversalGlassProminentButtonStyle {
    static var glassProminent: UniversalGlassProminentButtonStyle {
        UniversalGlassProminentButtonStyle()
    }
}

#if DEBUG
#Preview("Backport Button Styles") {
    VStack(spacing: 24) {
        Button("Backported Glass") {}
            .tint(.blue)
            .buttonStyle(.glass)

        Button("Backported Glass Prominent") {}
            .tint(.purple)
            .buttonStyle(.glassProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.2).ignoresSafeArea())
}
#endif
