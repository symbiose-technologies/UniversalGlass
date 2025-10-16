import SwiftUI

/// Extensions providing beautiful universal glass material blur-based transitions for SwiftUI views.
///
/// These transitions combine blur effects with scaling and opacity changes to create
/// smooth, elegant animations that feel at home in modern iOS interfaces.
public extension AnyTransition {
    /// A standard universal glass material blur transition with default scaling and spring animation.
    ///
    /// Perfect for general-purpose view transitions that need a subtle, polished feel.
    static var universalGlassMaterialBlur: AnyTransition {
        .universalGlassMaterialBlur()
    }

    /// A convenience wrapper around the internal fallback transition used on
    /// platforms without native glass animations.
    static var universalGlassMaterialFallbackBlur: AnyTransition {
        .universalGlassMaterialFallbackBlurTransition()
    }

    /// A blur-only transition without any scaling effect.
    ///
    /// Uses a fixed high-intensity blur for dramatic effect. Best suited for
    /// full-screen transitions or when scaling would interfere with layout.
    static var universalGlassMaterialBlurWithoutScale: AnyTransition {
        .modifier(
            active: BlurModifier(isIdentity: true, intensity: 20),
            identity: BlurModifier(isIdentity: false, intensity: 20)
        )
    }

    /// A customizable blur transition with configurable intensity and scale.
    ///
    /// - Parameters:
    ///   - intensity: The blur radius applied during transition (default: 5)
    ///   - scale: The scale factor applied during transition (default: 0.9)
    ///
    /// - Returns: A combined transition that smoothly blurs and scales views
    ///
    /// Use this when you need fine control over the transition characteristics.
    /// Higher intensity values create more dramatic blur effects, while scale values
    /// closer to 1.0 result in subtler size changes. Apply your preferred animation
    /// separately to control timing (for example, `.animation(.spring(), value: state)`).
    static func universalGlassMaterialBlur(
        intensity: CGFloat = 5,
        scale: CGFloat = 0.9
    ) -> AnyTransition {
        .scale(scale: scale)
            .combined(
                with: .modifier(
                    active: BlurModifier(isIdentity: true, intensity: intensity),
                    identity: BlurModifier(isIdentity: false, intensity: intensity)
                )
            )
    }
    
    
    static func universalGlassMaterialFallbackBlurTransition() -> AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8)
                .combined(
                    with: .modifier(
                        active: BlurModifier(isIdentity: true, intensity: 5),
                        identity: BlurModifier(isIdentity: false, intensity: 5)
                    )
                ),
            removal: .scale(scale: 1.2)
                .combined(
                    with: .modifier(
                        active: BlurModifier(isIdentity: true, intensity: 5),
                        identity: BlurModifier(isIdentity: false, intensity: 5)
                    )
                )
        )
    }
}

private struct BlurModifier: ViewModifier {
    /// Whether this modifier represents the identity (non-blurred) state
    public let isIdentity: Bool
    /// The intensity of the blur effect
    public var intensity: CGFloat

    public func body(content: Content) -> some View {
        content
            .blur(radius: isIdentity ? intensity : 0)
            .opacity(isIdentity ? 0 : 1)
    }
}
