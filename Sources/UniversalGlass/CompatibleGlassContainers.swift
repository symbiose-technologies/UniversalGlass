import SwiftUI

// MARK: - Glass Effect Container

/// A container that optimizes rendering performance for multiple liquid glass effects
@MainActor @ViewBuilder
public func CompatibleGlassEffectContainer<Content: View>(
    spacing: CGFloat? = nil,
    rendering: CompatibleGlassRendering = .automatic,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    if #available(iOS 26.0, macOS 26.0, *) {
        switch rendering {
        case .forceMaterial:
            CompatibleGlassEffectContainerFallback(
                spacing: spacing,
                rendering: rendering,
                content: content
            )
        case .automatic, .forceGlass:
            GlassEffectContainer(spacing: spacing, content: content)
        }
    } else {
        CompatibleGlassEffectContainerFallback(
            spacing: spacing,
            rendering: rendering,
            content: content
        )
    }
}

// MARK: - Glass Effect Morphing Helpers

public extension View {
    
    /// Applies a glass effect union for morphing transitions with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectUnion<ID: Hashable & Sendable>(
        id: ID,
        namespace: Namespace.ID,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
                    .transformEnvironment(\.glassEffectParticipantContext) { context in
                        context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
                    }
            case .automatic, .forceGlass:
                self.glassEffectUnion(id: id, namespace: namespace)
            }
        } else {
            self
                .transformEnvironment(\.glassEffectParticipantContext) { context in
                context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
            }
        }
    }
    
    /// Applies a glass effect ID for morphing transitions with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectID<ID: Hashable & Sendable>(
        _ id: ID,
        in namespace: Namespace.ID,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                self.glassEffectID(id, in: namespace)
            }
        } else {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                self.transformEnvironment(\.glassEffectParticipantContext) { context in
                    context.effectID = AnyHashable(id)
                    context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
                }
            }
        }
    }
}

// MARK: - Compatible Glass Effect Transition

public enum CompatibleGlassEffectTransition {
    case materialize
    case matchedGeometry
    case identity
}

public extension View {
    
    /// Applies a glass effect transition with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectTransition(
        _ transition: CompatibleGlassEffectTransition
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch transition {
            case .materialize:
                self.glassEffectTransition(.materialize)
            case .matchedGeometry:
                if #available(iOS 26.1, macOS 26.1, *) {
                    self.glassEffectTransition(.matchedGeometry)
                } else {
                    self
                }
            case .identity:
                self.glassEffectTransition(.identity)
            }
        } else {
            switch transition {
            case .materialize:
                self.transition(.blur)
            case .matchedGeometry:
                self.transition(.blur)
            case .identity:
                self
            }
        }
    }
}

// MARK: - Fallback Container Rendering

private struct CompatibleGlassEffectContainerFallback<Content: View>: View {
    let spacing: CGFloat?
    let rendering: CompatibleGlassRendering
    let content: () -> Content

    var body: some View {
        GlassEffectContainerRenderer(rendering: rendering, content: content)
    }
}

private struct GlassEffectContainerRenderer<Content: View>: View {
    let rendering: CompatibleGlassRendering
    let content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            content()
                .environment(\.glassEffectParticipantContext, GlassEffectParticipantContext())
                .environment(\.isInCompatibleGlassContainer, true)
        }
        .backgroundPreferenceValue(GlassEffectParticipantsKey.self) { participants in
            GeometryReader { proxy in
                GlassEffectFallbackOverlay(participants: participants, proxy: proxy)
            }
        }
    }
}

private struct ResolvedGlassEffectParticipant: Identifiable {
    let id: UUID
    let frame: CGRect
    let union: GlassEffectUnion?
    let effectID: AnyHashable?
    let transition: CompatibleGlassEffectTransition?
    let shape: AnyGlassShape?
    let glass: CompatibleGlass?
    let fallbackMaterial: Material
    let rendering: CompatibleGlassRendering
    let drawsOwnBackground: Bool
    let order: Int

    var groupingKey: GlassEffectGroupingKey {
        if let union {
            return .union(union)
        }
        if let effectID {
            return .effectID(effectID)
        }
        return .single(id)
    }
}

private enum GlassEffectGroupingKey: Hashable, Identifiable {
    case union(GlassEffectUnion)
    case effectID(AnyHashable)
    case single(UUID)

    var id: AnyHashable {
        switch self {
        case .union(let union):
            return AnyHashable(union)
        case .effectID(let value):
            return value
        case .single(let uuid):
            return AnyHashable(uuid)
        }
    }
}
private extension GlassEffectParticipant {
    func resolve(in proxy: GeometryProxy, order: Int) -> ResolvedGlassEffectParticipant {
        ResolvedGlassEffectParticipant(
            id: id,
            frame: proxy[anchor],
            union: union,
            effectID: effectID,
            transition: transition,
            shape: shape,
            glass: glass,
            fallbackMaterial: fallbackMaterial,
            rendering: rendering,
            drawsOwnBackground: drawsOwnBackground,
            order: order
        )
    }
}

private struct GlassEffectFallbackOverlay: View {
    let participants: [GlassEffectParticipant]
    let proxy: GeometryProxy

    @State private var overlayVersion = 0

    var body: some View {
        let resolved = participants.enumerated().map { index, participant in
            participant.resolve(in: proxy, order: index)
        }

        var grouped: [GlassEffectGroupingKey: [ResolvedGlassEffectParticipant]] = [:]
        for participant in resolved {
            let key = participant.groupingKey
            grouped[key, default: []].append(participant)
        }

        let orderedKeys = grouped.keys.sorted(by: { $0.id.hashValue < $1.id.hashValue })

        return ZStack(alignment: .topLeading) {
            ForEach(orderedKeys) { key in
                if let members = grouped[key] {
                    GlassEffectUnionOverlay(members: members)
                        .transition(.blur)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: orderedKeys.count)
        .allowsHitTesting(false)
    }
}

private struct GlassEffectUnionOverlay: View {
    let members: [ResolvedGlassEffectParticipant]

    var body: some View {
        guard let anchor = members.min(by: { $0.order < $1.order }) else {
            return AnyView(EmptyView())
        }

        let bounds = members.reduce(anchor.frame) { partial, participant in
            partial.union(participant.frame)
        }

        let shape = anchor.shape ?? AnyGlassShape(Capsule())
        let material = anchor.glass?.fallbackMaterial ?? anchor.fallbackMaterial

        return AnyView(
            CompatibleGlassOverlay(material: material, shape: shape)
                .frame(width: bounds.width, height: bounds.height)
                .position(x: bounds.midX, y: bounds.midY)
        )
    }
}

private struct CompatibleGlassOverlay: View {
    let material: Material
    let shape: AnyGlassShape

    var body: some View {
        if #available(iOS 15.0, macOS 13.0, *) {
            Color.clear
                .background(material.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: shape)
        } else {
            Color.clear
                .background(material, in: shape)
        }
    }
}

private extension CGRect {
    func union(_ other: CGRect) -> CGRect {
        CGRect(x: min(minX, other.minX),
               y: min(minY, other.minY),
               width: max(maxX, other.maxX) - min(minX, other.minX),
               height: max(maxY, other.maxY) - min(minY, other.minY))
    }
}

// MARK: - Previews

#if DEBUG
private struct GlassEffectUnionPreview: View {
    @Namespace private var namespace
    @State private var showMoon = true

    var body: some View {
        HStack(spacing: 30){
            CompatibleGlassEffectContainer() {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        Image(systemName: "star")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect()
                            .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace)

                        if showMoon {
                            Image(systemName: "moon")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .compatibleGlassEffect()
                                .compatibleGlassEffectTransition(.matchedGeometry)
                                .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace)
                        }
                        
                    }

                    Image(systemName: "sparkle")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .compatibleGlassEffect()
                    
                    if showMoon {
                        Image(systemName: "moon")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect()
                            .compatibleGlassEffectTransition(.matchedGeometry)
                            .compatibleGlassEffectUnion(id: "star2 and moon", namespace: namespace)
                    }
                    
                    if showMoon {
                        Image(systemName: "moon")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect()
                            .compatibleGlassEffectTransition(.matchedGeometry)
                            .compatibleGlassEffectUnion(id: "star2 and moon", namespace: namespace)
                    }
                    
                }
            }
            
            CompatibleGlassEffectContainer(rendering: .forceMaterial) {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        Image(systemName: "star")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect(rendering: .forceMaterial)
                            .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace, rendering: .forceMaterial)

                        if showMoon {
                            Image(systemName: "moon")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .compatibleGlassEffect(rendering: .forceMaterial)
                                .compatibleGlassEffectTransition(.matchedGeometry)
                                .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace, rendering: .forceMaterial)
                        }
                        
                    }

                    Image(systemName: "sparkle")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .compatibleGlassEffect()
                    
                    if showMoon {
                        Image(systemName: "moon")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect(rendering: .forceMaterial)
                            .compatibleGlassEffectTransition(.matchedGeometry)
                            .compatibleGlassEffectUnion(id: "star2 and moon", namespace: namespace, rendering: .forceMaterial)
                    }
                    
                    if showMoon {
                        Image(systemName: "moon")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .compatibleGlassEffect(rendering: .forceMaterial)
                            .compatibleGlassEffectTransition(.matchedGeometry)
                            .compatibleGlassEffectUnion(id: "star2 and moon", namespace: namespace, rendering: .forceMaterial)
                    }
                    
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(showMoon ? "Hide Moon" : "Show Moon") {
                    withAnimation(.spring(duration: 0.45)) {
                        showMoon.toggle()
                    }
                }
                .compatibleGlassButtonStyle()
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.08, blue: 0.32),
                    Color(red: 0.40, green: 0.10, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview("Modifier: glassEffectUnion") {
    GlassEffectUnionPreview()
}

private struct GlassEffectTransitionPreview: View {
    @State private var showMaterialize = true
    @State private var showGeometry = true
    @State private var showIdentity = true

    var body: some View {
        CompatibleGlassEffectContainer() {
            VStack(spacing: 20) {
                if showMaterialize {
                    VStack(spacing: 12) {
                        Text("Materialize Transition")
                            .font(.headline)
                        Text("Glass enters with liquid morphing.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .compatibleGlassEffect()
                    .compatibleGlassEffectTransition(.materialize)
                }

                if showGeometry {
                    VStack(spacing: 12) {
                        Text("Matched Geometry Transition")
                            .font(.headline)
                        Text("Shares movement with surrounding layout.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .compatibleGlassEffect()
                    .compatibleGlassEffectTransition(.matchedGeometry)
                }

                if showIdentity {
                    VStack(spacing: 12) {
                        Text("Identity Transition")
                            .font(.headline)
                        Text("Appears without morphing animation.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .compatibleGlassEffect()
                    .compatibleGlassEffectTransition(.identity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(showMaterialize ? "Hide Materialize" : "Show Materialize") {
                    withAnimation(.spring(duration: 0.45)) {
                        showMaterialize.toggle()
                    }
                }
                .compatibleGlassButtonStyle()

                Button(showGeometry ? "Hide Matched" : "Show Matched") {
                    withAnimation(.spring(duration: 0.45)) {
                        showGeometry.toggle()
                    }
                }
                .compatibleGlassButtonStyle()

                Button(showIdentity ? "Hide Identity" : "Show Identity") {
                    withAnimation(.spring(duration: 0.45)) {
                        showIdentity.toggle()
                    }
                }
                .compatibleGlassButtonStyle()
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.35),
                    Color(red: 0.32, green: 0.20, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview("Modifier: compatibleGlassEffectTransition") {
    GlassEffectTransitionPreview()
}
#endif
