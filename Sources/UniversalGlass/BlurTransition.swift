import SwiftUI

/// A view modifier that applies blur and opacity effects for smooth transitions.
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

/// Extensions providing beautiful blur-based transitions for SwiftUI views.
///
/// These transitions combine blur effects with scaling and opacity changes to create
/// smooth, elegant animations that feel at home in modern iOS interfaces.
public extension AnyTransition {
    /// A standard blur transition with default scaling and spring animation.
    ///
    /// Perfect for general-purpose view transitions that need a subtle, polished feel.
    static var blur: AnyTransition {
        .blur()
    }

    /// A smooth blur transition with bouncy animation characteristics.
    ///
    /// Provides a more playful feel with elastic motion, ideal for interactive elements
    /// or when you want to draw attention to the transition itself.
    static var blurSmooth: AnyTransition {
        .blur(scaleAnimation: Animation.bouncy)
    }

    /// A blur-only transition without any scaling effect.
    ///
    /// Uses a fixed high-intensity blur for dramatic effect. Best suited for
    /// full-screen transitions or when scaling would interfere with layout.
    static var blurWithoutScale: AnyTransition {
        .modifier(
            active: BlurModifier(isIdentity: true, intensity: 20),
            identity: BlurModifier(isIdentity: false, intensity: 20)
        )
    }

    /// A customizable blur transition with configurable intensity, scale, and animation.
    ///
    /// - Parameters:
    ///   - intensity: The blur radius applied during transition (default: 5)
    ///   - scale: The scale factor applied during transition (default: 0.8)
    ///   - scaleAnimation: The animation curve for the scaling effect (default: spring)
    ///
    /// - Returns: A combined transition that smoothly blurs and scales views
    ///
    /// Use this when you need fine control over the transition characteristics.
    /// Higher intensity values create more dramatic blur effects, while scale values
    /// closer to 1.0 result in subtler size changes.
    static func blur(
        intensity: CGFloat = 5,
        scale: CGFloat = 0.8,
        scaleAnimation: Animation = .spring()
    ) -> AnyTransition {
        .scale(scale: scale)
            .animation(scaleAnimation)
            .combined(
                with: .modifier(
                    active: BlurModifier(isIdentity: true, intensity: intensity),
                    identity: BlurModifier(isIdentity: false, intensity: intensity)
                )
            )
    }
}

#if DEBUG
#Preview("AnyTransition.blur variations") {
    @Previewable @State var showDetails = true

    VStack(spacing: 20) {
        Toggle("Show Details", isOn: $showDetails)
            .toggleStyle(.switch)
            .padding(.horizontal, 32)

        Spacer()

        if showDetails {
            VStack(spacing: 12) {
                Text("Liquid Glass")
                    .font(.title3.weight(.semibold))
                Text("Appears with blur and scale")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .transition(.blurSmooth)
        }

        Spacer()
    }
    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showDetails)
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(colors: [.indigo.opacity(0.7), .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    )
}
#endif
