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
    let glass: UniversalGlassConfiguration?
    let fallbackMaterial: Material
    let fallbackTint: Color?
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
        _ glass: UniversalGlassConfiguration,
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
        _ glass: UniversalGlassConfiguration,
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
        glassConfiguration: UniversalGlassConfiguration?,
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
    let glassConfiguration: UniversalGlassConfiguration?
    let shape: AnyGlassShape?
    let rendering: UniversalGlassRendering

    func body(content: Content) -> some View {
        let drawsBackground = !isInContainer
        let material = glassConfiguration?.fallbackMaterial ?? fallbackMaterial
        let tint = glassConfiguration?.fallbackTint
        let targetShape = shape ?? AnyGlassShape(Capsule())
        let base = drawsBackground
            ? AnyView(content.modifier(UniversalGlassFallbackBackground(material: material, tint: tint, shape: targetShape)))
            : AnyView(content)
        return base
            .transition(.universalGlassMaterialBlur)
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
                    fallbackTint: tint,
                    rendering: rendering,
                    drawsOwnBackground: drawsBackground
                )]
            }
            .environment(\.glassEffectParticipantContext, GlassEffectParticipantContext())
    }
}

private struct UniversalGlassFallbackBackground: ViewModifier {
    let material: Material
    let tint: Color?
    let shape: AnyGlassShape

    func body(content: Content) -> some View {
        content.background {
            ZStack {
                if let tint {
                    shape.fill(tint)
                }
                if #available(iOS 15.0, macOS 13.0, *) {
                    shape
                        .fill(material)
                        .shadow(color: Color.black.opacity(0.04), radius: 8)
                } else {
                    shape.fill(material)
                }
            }
        }
    }
}


#if DEBUG
#Preview("UniversalGlass presets") {
    let glassSamples: [(title: String, configuration: UniversalGlassConfiguration)] = [
        ("Clear", .clear.interactive()),
        ("Clear + Cyan Tint", .clear.tint(.cyan).interactive()),
        ("Regular", .regular.interactive())
    ]
    let materialSamples: [(title: String, configuration: UniversalGlassConfiguration)] = [
        ("Ultra Thin", .ultraThin.interactive()),
        ("Thin", .thin.interactive()),
        ("Regular", .regular.interactive()),
        ("Thick", .thick.interactive()),
        ("Ultra Thick", .ultraThick.interactive()),
    ]
    
    VStack(spacing: 24) {
//        Text("Glass Types")
//            .foregroundStyle(.white)
        VStack(spacing: 24) {
            ForEach(Array(glassSamples.enumerated()), id: \.offset) { entry in
                Label(entry.element.title, systemImage: "sparkles")
                    .font(.headline)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .universalGlassEffect(entry.element.configuration)
            }
        }
        
        Color.white.frame(height: 1.6)
            .opacity(0.5)
            .padding(.vertical)
            .frame(width: 200)
        
//        Text("Material Types")
//            .foregroundStyle(.white)
//            .font(.title2.weight(.bold))
        VStack(spacing: 24) {
            ForEach(Array(materialSamples.enumerated()), id: \.offset) { entry in
                Label(entry.element.title, systemImage: "sparkles")
                    .font(.headline)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .universalGlassEffect(entry.element.configuration)
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        Image("tulips", bundle: .module)
            .resizable()
        .ignoresSafeArea()
        
        // Photo by <a href="https://unsplash.com/@mike_loftus?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Michael Loftus</a> on <a href="https://unsplash.com/photos/a-field-of-yellow-tulips-under-a-blue-sky-aK4Slh-4uhU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
    )
}
#endif
