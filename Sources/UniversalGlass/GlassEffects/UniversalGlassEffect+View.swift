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
            // `.glass` is unavailable on these OS versions; both `.automatic` and `.material`
            // deliberately route through the fallback modifier.
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
            // Pre-iOS 26 the native glass APIs do not exist, so all render modes share
            // the material fallback path for consistency.
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
            // Fallback always draws material here because liquid glass is unavailable.
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
            // Prior to iOS 26 we only have the material fallback, regardless of rendering mode.
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

#if DEBUG
#Preview("Universal glass modifiers") {
    @Previewable @Namespace var namespace
    @Previewable @State var showDetail = true

    UniversalGlassEffectContainer(rendering: .automatic) {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .universalGlassEffect()
                    .universalGlassEffectUnion(id: "cluster", namespace: namespace)

                Image(systemName: "moon.stars")
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .universalGlassEffect(.regular.tint(.purple))
                    .universalGlassEffectUnion(id: "cluster", namespace: namespace)
            }

            if showDetail {
                Text("Matched geometry joins the icons into one glass slab on older OS versions.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .universalGlassEffect(
                        .clear.interactive(),
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
                    .universalGlassEffectTransition(.materialize)
            }

            Toggle("Show Details", isOn: $showDetail)
                .toggleStyle(.switch)
                .padding(.horizontal, 32)
        }
        .padding(24)
    }
    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showDetail)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.10, blue: 0.28), Color(red: 0.10, green: 0.30, blue: 0.42)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    )
}
#endif
