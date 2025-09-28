import SwiftUI

// MARK: - Participant Environment & Preference Infrastructure

struct GlassEffectUnion: Hashable {
    let id: AnyHashable
    let namespace: Namespace.ID?
}

struct GlassEffectParticipantContext {
    var union: GlassEffectUnion?
    var effectID: AnyHashable?
    var transition: UniversalGlassEffectTransition?
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

private struct IsInGlassContainerKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isInFallbackGlassContainer: Bool {
        get { self[IsInGlassContainerKey.self] }
        set { self[IsInGlassContainerKey.self] = newValue }
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
    let id: UUID
    let anchor: Anchor<CGRect>
    var union: GlassEffectUnion?
    var effectID: AnyHashable?
    let transition: UniversalGlassEffectTransition?
    let shape: AnyGlassShape?
    let glass: UniversalGlass?
    let fallbackMaterial: Material
    let rendering: UniversalGlassRendering
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

// MARK: - Backward Universal Liquid Glass Effects

public extension View {
    /// Applies a glass effect with backward compatibility to Material on older versions.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func universalGlassEffect(rendering: UniversalGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .material:
                applyingUniversalGlassFallback(
                    fallbackMaterial: .regularMaterial,
                    glassConfiguration: nil,
                    shape: nil,
                    rendering: rendering
                )
            case .automatic, .glass:
                self.glassEffect()
            }
        } else {
            applyingUniversalGlassFallback(
                fallbackMaterial: .regularMaterial,
                glassConfiguration: nil,
                shape: nil,
                rendering: rendering
            )
        }
    }

    /// Applies a glass effect with custom shape and backward compatibility.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func universalGlassEffect<S: Shape>(
        in shape: S,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .material:
                applyingUniversalGlassFallback(
                    fallbackMaterial: .regularMaterial,
                    glassConfiguration: nil,
                    shape: AnyGlassShape(shape),
                    rendering: rendering
                )
            case .automatic, .glass:
                self.glassEffect(in: shape)
            }
        } else {
            applyingUniversalGlassFallback(
                fallbackMaterial: .regularMaterial,
                glassConfiguration: nil,
                shape: AnyGlassShape(shape),
                rendering: rendering
            )
        }
    }

    /// Applies a glass effect with custom glass configuration and backward compatibility.
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func universalGlassEffect(
        _ glass: UniversalGlass,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .material:
                applyingUniversalGlassFallback(
                    fallbackMaterial: glass.fallbackMaterial,
                    glassConfiguration: glass,
                    shape: nil,
                    rendering: rendering
                )
            case .automatic, .glass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass)
                } else {
                    self.glassEffect()
                }
            }
        } else {
            applyingUniversalGlassFallback(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: nil,
                rendering: rendering
            )
        }
    }

    /// Applies a glass effect with custom glass configuration and shape with backward compatibility.
    @ViewBuilder
    func universalGlassEffect<S: Shape>(
        _ glass: UniversalGlass,
        in shape: S,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .material:
                applyingUniversalGlassFallback(
                    fallbackMaterial: glass.fallbackMaterial,
                    glassConfiguration: glass,
                    shape: AnyGlassShape(shape),
                    rendering: rendering
                )
            case .automatic, .glass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass, in: shape)
                } else {
                    self.glassEffect(in: shape)
                }
            }
        } else {
            applyingUniversalGlassFallback(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: AnyGlassShape(shape),
                rendering: rendering
            )
        }
    }
}

private extension View {
    func applyingUniversalGlassFallback(
        fallbackMaterial: Material,
        glassConfiguration: UniversalGlass?,
        shape: AnyGlassShape?,
        rendering: UniversalGlassRendering
    ) -> some View {
        modifier(
            UniversalGlassEffectModifier(
                fallbackMaterial: fallbackMaterial,
                glassConfiguration: glassConfiguration,
                shape: shape,
                rendering: rendering
            )
        )
    }
}

private struct UniversalGlassEffectModifier: ViewModifier {
    @Environment(\.glassEffectParticipantContext) private var context
    @Environment(\.isInFallbackGlassContainer) private var isInContainer

    let fallbackMaterial: Material
    let glassConfiguration: UniversalGlass?
    let shape: AnyGlassShape?
    let rendering: UniversalGlassRendering

    func body(content: Content) -> some View {
        let drawsBackground = !isInContainer
        let material = glassConfiguration?.fallbackMaterial ?? fallbackMaterial
        let targetShape = shape ?? AnyGlassShape(Capsule())
        let base = drawsBackground
            ? AnyView(content.modifier(UniversalGlassFallbackBackground(material: material, shape: targetShape)))
            : AnyView(content)
        return base
            .transition(.blur)
            .anchorPreference(key: GlassEffectParticipantsKey.self, value: .bounds) { anchor in
                [GlassEffectParticipant(
                    id: UUID(),
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
            .environment(\.glassEffectParticipantContext, GlassEffectParticipantContext())
    }
}

private struct UniversalGlassFallbackBackground: ViewModifier {
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
