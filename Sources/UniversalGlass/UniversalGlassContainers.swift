import SwiftUI

// MARK: - Glass Effect Container

/// A container that optimizes rendering performance for multiple liquid glass effects
@MainActor @ViewBuilder
public func UniversalGlassEffectContainer<Content: View>(
    spacing: CGFloat? = nil,
    rendering: UniversalGlassRendering = .automatic,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    #if !os(visionOS)
    if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
        switch rendering {
        case .material:
            FallbackGlassEffectContainerRenderer(
                spacing: spacing,
                rendering: rendering,
                content: content
            )
        case .automatic, .glass:
            GlassEffectContainer(spacing: spacing, content: content)
        }
    } else {
        FallbackGlassEffectContainerRenderer(
            spacing: spacing,
            rendering: rendering,
            content: content
        )
    }
    #else
    // visionOS doesn't have GlassEffectContainer, always use fallback
    FallbackGlassEffectContainerRenderer(
        spacing: spacing,
        rendering: rendering,
        content: content
    )
    #endif
}

// MARK: - Glass Effect Morphing Helpers

public extension View {
    
    /// Applies a glass effect union for morphing transitions with backward compatibility
    @ViewBuilder
    func universalGlassEffectUnion<ID: Hashable & Sendable>(
        id: ID,
        namespace: Namespace.ID,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            switch rendering {
            case .material:
                self
                    .transformEnvironment(\.glassEffectParticipantContext) { context in
                        context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
                    }
            case .automatic, .glass:
                self.glassEffectUnion(id: id, namespace: namespace)
            }
        } else {
            // `.glass` is not available before iOS 26, so `.automatic` and `.material`
            // both update the fallback participant context.
            self
                .transformEnvironment(\.glassEffectParticipantContext) { context in
                    context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
                }
        }
        #else
        // visionOS doesn't have glassEffectUnion, always use fallback context
        self
            .transformEnvironment(\.glassEffectParticipantContext) { context in
                context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
            }
        #endif
    }
    
    /// Applies a glass effect ID for morphing transitions with backward compatibility
    @ViewBuilder
    func universalGlassEffectID<ID: Hashable & Sendable>(
        _ id: ID,
        in namespace: Namespace.ID,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            switch rendering {
            case .material:
                self.transformEnvironment(\.glassEffectParticipantContext) { context in
                    context.effectID = AnyHashable(id)
                    context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
                }
            case .automatic, .glass:
                self.glassEffectID(id, in: namespace)
            }
        } else {
            // Older OS versions rely entirely on the fallback container, so we always
            // capture the identifiers in the participant context.
            self.transformEnvironment(\.glassEffectParticipantContext) { context in
                context.effectID = AnyHashable(id)
                context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
            }
        }
        #else
        // visionOS doesn't have glassEffectID, always use fallback context
        self.transformEnvironment(\.glassEffectParticipantContext) { context in
            context.effectID = AnyHashable(id)
            context.union = GlassEffectUnion(id: AnyHashable(id), namespace: namespace)
        }
        #endif
    }
}

// MARK: - Universal Glass Effect Transition

public enum UniversalGlassEffectTransition {
    case materialize
    case matchedGeometry
    case identity
}

public extension View {
    
    /// Applies a glass effect transition with backward compatibility
    @ViewBuilder
    func universalGlassEffectTransition(
        _ transition: UniversalGlassEffectTransition
    ) -> some View {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            switch transition {
            case .materialize:
                self.glassEffectTransition(.materialize)
            case .matchedGeometry:
                if #available(iOS 26.1, macOS 26.1, tvOS 26.1, watchOS 26.1, *) {
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
                self.transition(.universalGlassMaterialBlur)
            case .matchedGeometry:
                self.transition(.universalGlassMaterialBlur)
            case .identity:
                self
            }
        }
        #else
        // visionOS doesn't have glassEffectTransition, always use material transitions
        switch transition {
        case .materialize:
            self.transition(.universalGlassMaterialBlur)
        case .matchedGeometry:
            self.transition(.universalGlassMaterialBlur)
        case .identity:
            self
        }
        #endif
    }
}

// MARK: - Fallback Container Rendering

private struct FallbackGlassEffectContainerRenderer<Content: View>: View {
    var spacing: CGFloat? = .zero
    let rendering: UniversalGlassRendering
    let content: () -> Content

    // NOTE: Dynamic masking approach didn't work as expected. May revisit for future improvements.
//    @State private var participants: [GlassEffectParticipant] = []

    var body: some View {
        ZStack(alignment: .topLeading) {
            content()
                .environment(\.glassEffectParticipantContext, GlassEffectParticipantContext())
                .environment(\.isInFallbackGlassContainer, true)
        }
        // NOTE: Overlay masking approach didn't work as expected. May revisit for future improvements.
//        .overlayPreferenceValue(GlassEffectParticipantsKey.self) { participants in
//            GeometryReader { proxy in
//                GlassEffectFallbackMask(participants: participants, proxy: proxy)
//            }
//        }
        .backgroundPreferenceValue(GlassEffectParticipantsKey.self) { participants in
            GeometryReader { proxy in
                GlassEffectFallbackBackground(participants: participants, proxy: proxy)
            }
        }
       
    }
}

private struct ResolvedGlassEffectParticipant: Identifiable {
    let id: UUID
    let frame: CGRect
    let union: GlassEffectUnion?
    let effectID: AnyHashable?
    let transition: UniversalGlassEffectTransition?
    let shape: AnyGlassShape?
    let glass: UniversalGlassConfiguration?
    let fallbackMaterial: Material?
    let fallbackTint: Color?
    let rendering: UniversalGlassRendering
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
            fallbackTint: fallbackTint,
            rendering: rendering,
            drawsOwnBackground: drawsOwnBackground,
            order: order
        )
    }
}

private struct GlassEffectFallbackBackground: View {
    let participants: [GlassEffectParticipant]
    let proxy: GeometryProxy

    var body: some View {
        let resolved = participants.enumerated().map { index, participant in
            participant.resolve(in: proxy, order: index)
        }

        var grouped: [GlassEffectGroupingKey: [ResolvedGlassEffectParticipant]] = [:]
        for participant in resolved {
            grouped[participant.groupingKey, default: []].append(participant)
        }

        let orderedKeys = grouped.keys.sorted { $0.id.hashValue < $1.id.hashValue }

        return ZStack(alignment: .topLeading) {
            ForEach(orderedKeys) { key in
                if let members = grouped[key] {
                    GlassEffectUnionBackground(members: members)
                        .transition(.universalGlassMaterialFallbackBlur)
                        .id(key.id)
                }
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        .allowsHitTesting(false)
    }
}

private struct GlassEffectFallbackMask: View {
    let participants: [GlassEffectParticipant]
    let proxy: GeometryProxy

    var body: some View {
        let resolved = participants.enumerated().map { index, participant in
            participant.resolve(in: proxy, order: index)
        }

        if resolved.isEmpty {
            return AnyView(Color.white)
        }

        var grouped: [GlassEffectGroupingKey: [ResolvedGlassEffectParticipant]] = [:]
        for participant in resolved {
            grouped[participant.groupingKey, default: []].append(participant)
        }

        let orderedKeys = grouped.keys.sorted { $0.id.hashValue < $1.id.hashValue }

        return AnyView(
            ZStack(alignment: .topLeading) {
                ForEach(orderedKeys) { key in
                    if let members = grouped[key] {
                        GlassEffectUnionMask(members: members)
                            .transition(.universalGlassMaterialFallbackBlur)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .allowsHitTesting(false)
        )
    }
}

private struct GlassEffectUnionBackground: View {
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
        let tint = anchor.glass?.fallbackTint ?? anchor.fallbackTint
        let shadow = anchor.glass?.fallbackShadow ?? .default

        if let material = material {
            return AnyView(
                ZStack {
                    if let tint {
                        shape.fill(tint)
                    }
                    if #available(iOS 15.0, macOS 13.0, *) {
                        shape
                            .fill(material)
                            .shadow(color: shadow.color, radius: shadow.radius)
                    } else {
                        shape.fill(material)
                    }
                }
                .frame(width: bounds.width, height: bounds.height)
                .position(x: bounds.midX, y: bounds.midY)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

private struct GlassEffectUnionMask: View {
    let members: [ResolvedGlassEffectParticipant]

    var body: some View {
        guard let anchor = members.min(by: { $0.order < $1.order }) else {
            return AnyView(EmptyView())
        }

        let bounds = members.reduce(anchor.frame) { partial, participant in
            partial.union(participant.frame)
        }

        let shape = anchor.shape ?? AnyGlassShape(Capsule())

        return AnyView(
            Color.white
                .clipShape(shape)
                .frame(width: bounds.width, height: bounds.height)
                .position(x: bounds.midX, y: bounds.midY)
        )
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
    @State private var showMoon = false

    var body: some View {
        VStack(spacing: 30){
            UniversalGlassEffectContainer() {
                HStack(spacing: 20) {
                    HStack(spacing: 0) {
                        
                        if showMoon {
                            Image(systemName: "moon")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .universalGlassEffect()
                                .universalGlassEffectTransition(.matchedGeometry)
                                .universalGlassEffectUnion(id: "star and moon", namespace: namespace)
                        }
                        Image(systemName: "star")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .universalGlassEffect()
                            .universalGlassEffectUnion(id: "star and moon", namespace: namespace)
                        
                    }
                    
                    Image(systemName: "sparkle")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .universalGlassEffect()
                    
                    if showMoon {
                    HStack(spacing: 0) {
                        Image(systemName: "cloud")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .universalGlassEffect()
                            .universalGlassEffectTransition(.matchedGeometry)
                            .universalGlassEffectUnion(id: "star2 and moon", namespace: namespace)
                    
                    
                    Image(systemName: "sunglasses")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .universalGlassEffect()
                        .universalGlassEffectTransition(.matchedGeometry)
                        .universalGlassEffectUnion(id: "star2 and moon", namespace: namespace)
                    
                }
                    }
                    
                }
            }
            .overlay(content: {
                HStack{
                    Text("Liquid Glass · iOS 26").frame(maxWidth: .infinity)
                }
                .offset(y: -100)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
            })
            
            UniversalGlassEffectContainer(rendering: .material) {
                HStack(spacing: 20) {
                    HStack(spacing: 0) {
                        

                    if showMoon {
                        Image(systemName: "moon")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .universalGlassEffect(rendering: .material)
                            .universalGlassEffectTransition(.matchedGeometry)
                            .universalGlassEffectUnion(id: "star and moon", namespace: namespace, rendering: .material)
                    }
                        Image(systemName: "star")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .universalGlassEffect(rendering: .material)
                            .universalGlassEffectUnion(id: "star and moon", namespace: namespace, rendering: .material)
                        
                    }

                    Image(systemName: "sparkle")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .universalGlassEffect(rendering: .material)
                    
                        if showMoon {
                    HStack(spacing: 0) {
                            Image(systemName: "cloud")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .universalGlassEffect(rendering: .material)
                                .universalGlassEffectTransition(.matchedGeometry)
                                .universalGlassEffectUnion(id: "star2 and moon", namespace: namespace, rendering: .material)
                        
                        
                            Image(systemName: "sunglasses")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .universalGlassEffect(rendering: .material)
                                .universalGlassEffectTransition(.matchedGeometry)
                                .universalGlassEffectUnion(id: "star2 and moon", namespace: namespace, rendering: .material)
                        }
                    }
                }
            }.frame(maxWidth: .infinity)
                .overlay(content: {
                    HStack{
                        Text("Fallback · iOS 18").frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 60)
                    .offset(y: 100)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                })
            
        }
        .padding(.horizontal, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(showMoon ? "Hide" : "Show") {
                    withAnimation(.spring(duration: 0.45)) {
                        showMoon.toggle()
                    }
                }
                .universalGlassButtonStyle()
            }
        }
        
        .background(
            Image("tulips", bundle: .module)
                .resizable()
            .ignoresSafeArea()
            
            // Photo by <a href="https://unsplash.com/@mike_loftus?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Michael Loftus</a> on <a href="https://unsplash.com/photos/a-field-of-yellow-tulips-under-a-blue-sky-aK4Slh-4uhU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
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
        UniversalGlassEffectContainer() {
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
                    .universalGlassEffect()
                    .universalGlassEffectTransition(.materialize)
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
                    .universalGlassEffect()
                    .universalGlassEffectTransition(.matchedGeometry)
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
                    .universalGlassEffect()
                    .universalGlassEffectTransition(.identity)
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
                .universalGlassButtonStyle()

                Button(showGeometry ? "Hide Matched" : "Show Matched") {
                    withAnimation(.spring(duration: 0.45)) {
                        showGeometry.toggle()
                    }
                }
                .universalGlassButtonStyle()

                Button(showIdentity ? "Hide Identity" : "Show Identity") {
                    withAnimation(.spring(duration: 0.45)) {
                        showIdentity.toggle()
                    }
                }
                .universalGlassButtonStyle()
            }
        }
        
        .background(
            Image("tulips", bundle: .module)
                .resizable()
            .ignoresSafeArea()
            
            // Photo by <a href="https://unsplash.com/@mike_loftus?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Michael Loftus</a> on <a href="https://unsplash.com/photos/a-field-of-yellow-tulips-under-a-blue-sky-aK4Slh-4uhU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
        )
    }
}

#Preview("Modifier: universalGlassEffectTransition") {
    GlassEffectTransitionPreview()
}
#endif
