import SwiftUI
import UniversalGlass

// MARK: - Back-Deployed Button Styles

/// Exposes SwiftUI's `.glass` button style names on platforms where they are not yet available.
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
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.2).ignoresSafeArea())
}
#endif
