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

private struct IsInGlassContainerKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isInCompatibleGlassContainer: Bool {
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
    @ViewBuilder
    func compatibleGlassEffect(rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                applyingCompatibleGlassFallback(
                    fallbackMaterial: .regularMaterial,
                    glassConfiguration: nil,
                    shape: nil,
                    rendering: rendering
                )
            case .automatic, .forceGlass:
                self.glassEffect()
            }
        } else {
            applyingCompatibleGlassFallback(
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
    func compatibleGlassEffect<S: Shape>(
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                applyingCompatibleGlassFallback(
                    fallbackMaterial: .regularMaterial,
                    glassConfiguration: nil,
                    shape: AnyGlassShape(shape),
                    rendering: rendering
                )
            case .automatic, .forceGlass:
                self.glassEffect(in: shape)
            }
        } else {
            applyingCompatibleGlassFallback(
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
    func compatibleGlassEffect(
        _ glass: CompatibleGlass,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                applyingCompatibleGlassFallback(
                    fallbackMaterial: glass.fallbackMaterial,
                    glassConfiguration: glass,
                    shape: nil,
                    rendering: rendering
                )
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass)
                } else {
                    self.glassEffect()
                }
            }
        } else {
            applyingCompatibleGlassFallback(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: nil,
                rendering: rendering
            )
        }
    }

    /// Applies a glass effect with custom glass configuration and shape with backward compatibility.
    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(
        _ glass: CompatibleGlass,
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                applyingCompatibleGlassFallback(
                    fallbackMaterial: glass.fallbackMaterial,
                    glassConfiguration: glass,
                    shape: AnyGlassShape(shape),
                    rendering: rendering
                )
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass, in: shape)
                } else {
                    self.glassEffect(in: shape)
                }
            }
        } else {
            applyingCompatibleGlassFallback(
                fallbackMaterial: glass.fallbackMaterial,
                glassConfiguration: glass,
                shape: AnyGlassShape(shape),
                rendering: rendering
            )
        }
    }
}

private extension View {
    func applyingCompatibleGlassFallback(
        fallbackMaterial: Material,
        glassConfiguration: CompatibleGlass?,
        shape: AnyGlassShape?,
        rendering: CompatibleGlassRendering
    ) -> some View {
        modifier(
            CompatibleGlassEffectModifier(
                fallbackMaterial: fallbackMaterial,
                glassConfiguration: glassConfiguration,
                shape: shape,
                rendering: rendering
            )
        )
    }
}

private struct CompatibleGlassEffectModifier: ViewModifier {
    @Environment(\.glassEffectParticipantContext) private var context
    @Environment(\.isInCompatibleGlassContainer) private var isInContainer

    let fallbackMaterial: Material
    let glassConfiguration: CompatibleGlass?
    let shape: AnyGlassShape?
    let rendering: CompatibleGlassRendering

    func body(content: Content) -> some View {
        let drawsBackground = !isInContainer
        let material = glassConfiguration?.fallbackMaterial ?? fallbackMaterial
        let targetShape = shape ?? AnyGlassShape(Capsule())
        let base = drawsBackground
            ? AnyView(content.modifier(CompatibleGlassFallbackBackground(material: material, shape: targetShape)))
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
