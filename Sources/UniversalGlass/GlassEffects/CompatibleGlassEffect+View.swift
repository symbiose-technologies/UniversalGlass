import SwiftUI

// MARK: - Participant Environment & Preference Infrastructure

struct GlassEffectUnion: Hashable {
    let id: AnyHashable
    let namespace: Namespace.ID?
}

struct GlassEffectParticipantContext {
    var union: GlassEffectUnion?
    var effectID: AnyHashable?
    var transition: CompatibleGlassEffectTransition?
}

private struct GlassEffectParticipantContextKey: EnvironmentKey {
    static nonisolated(unsafe) var defaultValue = GlassEffectParticipantContext()
}

extension EnvironmentValues {
    var glassEffectParticipantContext: GlassEffectParticipantContext {
        get { self[GlassEffectParticipantContextKey.self] }
        set { self[GlassEffectParticipantContextKey.self] = newValue }
    }
}

struct AnyGlassShape: Shape {
    private let builder: @Sendable (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        builder = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        builder(rect)
    }
}

struct GlassEffectParticipant: Identifiable {
    let id = UUID()
    let anchor: Anchor<CGRect>
    let union: GlassEffectUnion?
    let effectID: AnyHashable?
    let transition: CompatibleGlassEffectTransition?
    let shape: AnyGlassShape?
    let glass: CompatibleGlass?
    let fallbackMaterial: Material
    let rendering: CompatibleGlassRendering
    let drawsOwnBackground: Bool
}

extension AnyGlassShape: @unchecked Sendable {}
extension GlassEffectParticipant: @unchecked Sendable {}

@preconcurrency
struct GlassEffectParticipantsKey: PreferenceKey {
    static let defaultValue: [GlassEffectParticipant] = []

    static func reduce(value: inout [GlassEffectParticipant], nextValue: () -> [GlassEffectParticipant]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Backward Compatible Liquid Glass Effects

public extension View {
    /// Applies a glass effect with backward compatibility to Material on older versions.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    func compatibleGlassEffect(rendering: CompatibleGlassRendering = .automatic) -> some View {
        modifier(
            CompatibleGlassEffectModifier(
                fallbackMaterial: .regularMaterial,
                glassConfiguration: nil,
                shape: nil,
                rendering: rendering
            )
        )
    }

    /// Applies a glass effect with custom shape and backward compatibility.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    func compatibleGlassEffect<S: Shape>(
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        modifier(
            CompatibleGlassEffectModifier(
                fallbackMaterial: .regularMaterial,
                glassConfiguration: nil,
                shape: AnyGlassShape(shape),
                rendering: rendering
            )
        )
    }

    /// Applies a glass effect with custom glass configuration and backward compatibility.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    func compatibleGlassEffect(
        _ glass: CompatibleGlass,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        modifier(
            CompatibleGlassEffectModifier(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: nil,
                rendering: rendering
            )
        )
    }

    /// Applies a glass effect with custom glass configuration and shape.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    func compatibleGlassEffect<S: Shape>(
        _ glass: CompatibleGlass,
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        modifier(
            CompatibleGlassEffectModifier(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: AnyGlassShape(shape),
                rendering: rendering
            )
        )
    }
}

private struct CompatibleGlassEffectModifier: ViewModifier {
    @Environment(\.glassEffectParticipantContext) private var context

    let fallbackMaterial: Material
    let glassConfiguration: CompatibleGlass?
    let shape: AnyGlassShape?
    let rendering: CompatibleGlassRendering

    func body(content: Content) -> some View {
        let drawsBackground = context.union == nil && context.effectID == nil
        let material = glassConfiguration?.fallbackMaterial ?? fallbackMaterial
        let targetShape = shape ?? AnyGlassShape(Capsule())
        let base: AnyView

        if drawsBackground {
            base = AnyView(
                content.modifier(
                    CompatibleGlassFallbackBackground(material: material, shape: targetShape)
                )
            )
        } else {
            base = AnyView(content)
        }

        return base
            .anchorPreference(key: GlassEffectParticipantsKey.self, value: .bounds) { anchor in
                [GlassEffectParticipant(
                    anchor: anchor,
                    union: context.union,
                    effectID: context.effectID,
                    transition: context.transition,
                    shape: shape,
                    glass: glassConfiguration,
                    fallbackMaterial: material,
                    rendering: rendering,
                    drawsOwnBackground: drawsBackground
                )]
            }
            .transformEnvironment(\.glassEffectParticipantContext) { value in
                value = GlassEffectParticipantContext()
            }
    }
}

private struct CompatibleGlassFallbackBackground: ViewModifier {
    let material: Material
    let shape: AnyGlassShape

    func body(content: Content) -> some View {
        if #available(iOS 15.0, macOS 13.0, *) {
            content.background(
                material.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                in: shape
            )
        } else {
            content.background(material, in: shape)
        }
    }
}
