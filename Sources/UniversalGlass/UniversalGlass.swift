import SwiftUI

// MARK: - Backward Compatible Liquid Glass Effects

public extension View {

    /// Applies a glass effect with backward compatibility to Material on older iOS versions
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect(rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(.regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: .capsule)
            case .automatic, .forceGlass:
                self.glassEffect()
            }
        } else {
            self.background(.regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: .capsule)
        }
    }

    /// Applies a glass effect with custom shape and backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(in shape: S, rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
                    .background(.regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: shape)
            case .automatic, .forceGlass:
                self.glassEffect(in: shape)
            }
        } else {
            self
                .background(.regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: shape)
        }
    }

    /// Applies a glass effect with custom glass configuration and backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect(_ glass: CompatibleGlass, rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: .capsule)
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass)
                } else {
                    self.glassEffect()
                }
            }
        } else {
            self.background(glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: .capsule)
        }
    }

    /// Applies a glass effect with custom glass configuration and shape with backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(_ glass: CompatibleGlass, in shape: S, rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
                    .background(glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: shape)
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass, in: shape)
                } else {
                    self.glassEffect(in: shape)
                }
            }
        } else {
            self
                .background(glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)), in: shape)
        }
    }
}

// MARK: - Compatible Glass Configuration

/// A configuration type that provides liquid glass effects on iOS 26+ and material fallbacks on older versions
public struct CompatibleGlass {
    let fallbackMaterial: Material
    private let _liquidGlass: Any?

    @available(iOS 26.0, macOS 26.0, *)
    public var liquidGlass: Glass? {
        return _liquidGlass as? Glass
    }

    private init(fallbackMaterial: Material, liquidGlass: Any? = nil) {
        self.fallbackMaterial = fallbackMaterial
        self._liquidGlass = liquidGlass
    }

    /// Regular liquid glass effect with regular material fallback
    nonisolated(unsafe) public static let regular: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(fallbackMaterial: .regularMaterial, liquidGlass: Glass.regular)
        } else {
            return CompatibleGlass(fallbackMaterial: .regularMaterial)
        }
    }()

    /// Thick liquid glass effect with thick material fallback
    nonisolated(unsafe) public static let thick: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(fallbackMaterial: .thickMaterial, liquidGlass: Glass.regular)
        } else {
            return CompatibleGlass(fallbackMaterial: .thickMaterial)
        }
    }()

    /// Thin liquid glass effect with thin material fallback
    nonisolated(unsafe) public static let thin: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(fallbackMaterial: .thinMaterial, liquidGlass: Glass.regular)
        } else {
            return CompatibleGlass(fallbackMaterial: .thinMaterial)
        }
    }()

    /// Ultra thin liquid glass effect with ultra thin material fallback
    nonisolated(unsafe) public static let ultraThin: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial, liquidGlass: Glass.regular)
        } else {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()

    /// Clear liquid glass effect with ultra thin material fallback
    nonisolated(unsafe) public static let clear: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial, liquidGlass: Glass.clear)
        } else {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()

    /// Creates a tinted liquid glass effect with the specified color
    /// Falls back to regular material on older versions
    public func tint(_ color: Color) -> CompatibleGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let tintedGlass: Any = existingGlass.tint(color)
                return CompatibleGlass(fallbackMaterial: fallbackMaterial, liquidGlass: tintedGlass)
            } else {
                let tintedGlass: Any = Glass.regular.tint(color)
                return CompatibleGlass(fallbackMaterial: fallbackMaterial, liquidGlass: tintedGlass)
            }
        } else {
            return CompatibleGlass(fallbackMaterial: fallbackMaterial)
        }
    }

    /// Creates an interactive liquid glass effect
    /// Falls back to the same material on older versions
    public func interactive(_ isInteractive: Bool = true) -> CompatibleGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let interactiveGlass: Any = existingGlass.interactive(isInteractive)
                return CompatibleGlass(fallbackMaterial: fallbackMaterial, liquidGlass: interactiveGlass)
            } else {
                let interactiveGlass: Any = Glass.regular.interactive(isInteractive)
                return CompatibleGlass(fallbackMaterial: fallbackMaterial, liquidGlass: interactiveGlass)
            }
        } else {
            return CompatibleGlass(fallbackMaterial: fallbackMaterial)
        }
    }
}

// MARK: - Compatible Glass Rendering

/// Determines how compatible glass APIs render across different iOS versions.
public enum CompatibleGlassRendering {
    /// Uses glass on supported versions and falls back automatically otherwise.
    case automatic
    /// Forces the use of glass on supported versions, falling back to material when unavailable.
    @available(iOS 26.0, macOS 26.0, *)
    case forceGlass
    /// Forces the material fallback even on platforms that support glass.
    case forceMaterial
}

// MARK: - Compatible Button Styles

public extension View {
    @ViewBuilder
    func compatibleGlassButtonStyle(
        isProminent: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.buttonStyle(.bordered)
            case .automatic, .forceGlass:
                self.buttonStyle(.glass)
            }
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

public extension View {
    @ViewBuilder
    func compatibleGlassProminentButtonStyle(
        isProminent: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.buttonStyle(.borderedProminent)
            case .automatic, .forceGlass:
                self.buttonStyle(.glassProminent)
            }
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}
// MARK: - Glass Effect Container

/// A container that optimizes rendering performance for multiple liquid glass effects
@MainActor @ViewBuilder
public func CompatibleGlassEffectContainer<Content: View>(
    spacing: CGFloat,
    rendering: CompatibleGlassRendering = .automatic,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    if #available(iOS 26.0, macOS 26.0, *) {
        switch rendering {
        case .forceMaterial:
            content()
        case .automatic, .forceGlass:
            GlassEffectContainer(spacing: spacing, content: content)
        }
    } else {
        content()
    }
}

// MARK: - Glass Effect Modifiers

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
            case .automatic, .forceGlass:
                self.glassEffectUnion(id: id, namespace: namespace)
            }
        } else {
            self
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
            self
        }
    }

    /// Sets scroll extension mode with backward compatibility
    @ViewBuilder
    func compatibleScrollExtensionMode(_ mode: CompatibleScrollExtensionMode) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch mode {
            case .underSidebar:
                // Note: This API may not exist yet, commenting out for now
                self // self.scrollExtensionMode(.underSidebar)
            case .none:
                self
            }
        } else {
            self
        }
    }

    /// Applies a glass effect transition with backward compatibility
    @ViewBuilder
    func compatibleGlassEffectTransition(
        _ transition: CompatibleGlassEffectTransition,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self
            case .automatic, .forceGlass:
                switch transition {
                case .materialize:
                    self.glassEffectTransition(.materialize)
                case .none:
                    self
                }
            }
        } else {
            self
        }
    }
}

// MARK: - Compatible Scroll Extension Mode

public enum CompatibleScrollExtensionMode {
    case underSidebar
    case none
}

// MARK: - Compatible Glass Effect Transition

public enum CompatibleGlassEffectTransition {
    case materialize
    case none
}

// MARK: - Previews

#if DEBUG
#Preview("Modifier: compatibleGlassEffect") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Text("Automatic Glass")
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .compatibleGlassEffect(rendering: .automatic)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 280)
    .padding()
}

#Preview("Modifier: compatibleGlassEffect (Shape)") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Text("Custom Shape")
            .font(.title3.weight(.semibold))
            .padding(28)
            .compatibleGlassEffect(
                in: RoundedRectangle(cornerRadius: 28, style: .continuous),
                rendering: .automatic
            )
    }
    .frame(maxWidth: .infinity)
    .frame(height: 280)
    .padding()
}

#Preview("Modifier: compatibleGlassEffect (Custom Glass)") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Text("Tinted Regular Glass")
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .compatibleGlassEffect(CompatibleGlass.regular.tint(.cyan), rendering: .automatic)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 280)
    .padding()
}

#Preview("Modifier: compatibleGlassEffect (Glass + Shape)") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Text("Clear Capsule")
            .font(.title3.weight(.semibold))
            .padding(28)
            .compatibleGlassEffect(
                CompatibleGlass.clear,
                in: Capsule(),
                rendering: .automatic
            )
    }
    .frame(maxWidth: .infinity)
    .frame(height: 280)
    .padding()
}

#Preview("Modifier: compatibleGlassButtonStyle") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Button("Glass Button") {}
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .compatibleGlassButtonStyle(isProminent: false, rendering: .automatic)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 220)
    .padding()
}

#Preview("Modifier: compatibleGlassProminentButtonStyle") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Button("Prominent Glass Button") {}
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .compatibleGlassProminentButtonStyle(isProminent: true, rendering: .automatic)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 220)
    .padding()
}

#Preview("Container: CompatibleGlassEffectContainer") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.15, blue: 0.32),
                Color(red: 0.32, green: 0.12, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        CompatibleGlassEffectContainer(spacing: 16, rendering: .automatic) {
            ForEach(1...3, id: \.self) { index in
                VStack(spacing: 8) {
                    Text("Item \(index)")
                        .font(.headline)
                    Text("Rendered inside a container optimized for liquid glass.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .compatibleGlassEffect(rendering: .automatic)
            }
        }
        .padding(.horizontal, 4)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 320)
    .padding()
}

#Preview("Modifier: compatibleGlassEffectUnion") {
    struct Demo: View {
        @Namespace private var namespace
        @State private var mergeHighlights = true

        private struct Card: Identifiable {
            let id = UUID()
            let title: String
            let subtitle: String
            let systemImage: String
        }

        private let cards: [Card] = [
            .init(title: "Primary", subtitle: "Core functions", systemImage: "app.badge.fill"),
            .init(title: "Secondary", subtitle: "Assistive tools", systemImage: "wand.and.stars"),
            .init(title: "Background", subtitle: "Support services", systemImage: "bolt.fill")
        ]

        private var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.32),
                    Color(red: 0.32, green: 0.12, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }

        var body: some View {
            ZStack {
                backgroundGradient

                VStack(spacing: 20) {
                    Text("Toggle to see how glass unions merge adjacent cards inside a container.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CompatibleGlassEffectContainer(spacing: mergeHighlights ? 12 : 28, rendering: .automatic) {
                        HStack(spacing: mergeHighlights ? 12 : 20) {
                            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: card.systemImage)
                                        .font(.system(size: 32, weight: .medium))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(card.title)
                                        .font(.headline)
                                    Text(card.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .compatibleGlassEffect(rendering: .automatic)
                                .compatibleGlassEffectUnion(
                                    id: mergeHighlights && index < 2 ? "primary" : "solo-\(index)",
                                    namespace: namespace
                                )
                            }
                        }
                    }

                    Button(mergeHighlights ? "Separate Highlights" : "Merge Highlights") {
                        withAnimation(.spring(duration: 0.45)) {
                            mergeHighlights.toggle()
                        }
                    }
                    .compatibleGlassButtonStyle(rendering: .automatic)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .padding()
        }
    }

    return Demo()
}

#Preview("Modifier: compatibleGlassEffectID") {
    struct Demo: View {
        @Namespace private var namespace
        @State private var showDetails = false

        private var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.32),
                    Color(red: 0.32, green: 0.12, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }

        var body: some View {
            ZStack {
                backgroundGradient

                VStack(spacing: 20) {
                    Text("Toggle between compact and expanded cards that share the same glass identity.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CompatibleGlassEffectContainer(spacing: 24, rendering: .automatic) {
                        Group {
                            if showDetails {
                                detailCard
                                    .compatibleGlassEffectID("card", in: namespace)
                            } else {
                                summaryCard
                                    .compatibleGlassEffectID("card", in: namespace)
                            }
                        }
                        .animation(.spring(duration: 0.45), value: showDetails)
                    }

                    Button(showDetails ? "Show Summary" : "Show Details") {
                        withAnimation(.spring(duration: 0.45)) {
                            showDetails.toggle()
                        }
                    }
                    .compatibleGlassProminentButtonStyle(rendering: .automatic)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .padding()
        }

        private var summaryCard: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Design Summary")
                    .font(.headline)
                Text("Compact layout shares its glass identity with the expanded card.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .compatibleGlassEffect(rendering: .automatic)
        }

        private var detailCard: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Expanded Details")
                    .font(.headline)
                Text("Liquid glass morphs smoothly thanks to matching IDs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Divider()
                Label("Status", systemImage: "checkmark.seal")
                    .font(.caption)
                Label("Next Step", systemImage: "arrow.forward.circle")
                    .font(.caption)
            }
            .padding(28)
            .compatibleGlassEffect(rendering: .automatic)
        }
    }

    return Demo()
}

#Preview("Modifier: compatibleScrollExtensionMode") {
    struct Demo: View {
        private var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.32),
                    Color(red: 0.32, green: 0.12, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }

        var body: some View {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(1...8, id: \.self) { index in
                            Label("Sidebar Row \(index)", systemImage: "rectangle.portrait")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .compatibleGlassEffect(rendering: .automatic)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
                .compatibleScrollExtensionMode(.underSidebar)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .padding()
        }
    }

    return Demo()
}

#Preview("Modifier: compatibleGlassEffectTransition") {
    struct Demo: View {
        @State private var showDetails = false

        private var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.32),
                    Color(red: 0.32, green: 0.12, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }

        var body: some View {
            ZStack {
                backgroundGradient

                VStack(spacing: 20) {
                    Text("Toggle the card to preview the materialize glass transition.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        if showDetails {
                            VStack(spacing: 12) {
                                Text("Now Playing")
                                    .font(.headline)
                                Text("Liquid glass animates in with a materialize transition.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(24)
                            .compatibleGlassEffect(rendering: .automatic)
                            .compatibleGlassEffectTransition(.materialize)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }
                    }
                    .frame(height: 160)

                    Button(showDetails ? "Hide Card" : "Show Card") {
                        withAnimation(.spring(duration: 0.45)) {
                            showDetails.toggle()
                        }
                    }
                    .compatibleGlassProminentButtonStyle(rendering: .automatic)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .padding()
        }
    }

    return Demo()
}
#endif
