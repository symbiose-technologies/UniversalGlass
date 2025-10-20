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
        universalGlassEffect()
    }

    func glassEffect<S: Shape>(in shape: S) -> some View {
        universalGlassEffect(in: shape)
    }

    func glassEffect(_ glass: UniversalGlassConfiguration) -> some View {
        universalGlassEffect(glass)
    }

    func glassEffect<S: Shape>(
        _ glass: UniversalGlassConfiguration,
        in shape: S
    ) -> some View {
        universalGlassEffect(glass, in: shape)
    }
}

#if DEBUG
#Preview("Backport Glass Effect") {
    VStack(spacing: 32) {
        Text("Standard Glass")
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .glassEffect(.regular.interactive())

        Text("Custom Shape")
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .glassEffect(in: RoundedRectangle(cornerRadius: 10, style: .continuous))

        Text("Tinted Glass")
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .glassEffect(.regular.tint(.teal))
    }
    .font(.headline)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.18, blue: 0.32),
                     Color(red: 0.05, green: 0.38, blue: 0.48)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    )
}
#endif
