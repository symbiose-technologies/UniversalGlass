import SwiftUI

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
}

#if DEBUG
private struct CompatibleGlassContainerPreviewBackground<Content: View>: View {
    private let height: CGFloat
    private let content: Content

    init(height: CGFloat = 320, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
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

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding()
    }
}

#Preview("Container: CompatibleGlassEffectContainer") {
    CompatibleGlassContainerPreviewBackground {
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
}

#Preview("Modifier: compatibleGlassEffectUnion") {
    CompatibleGlassContainerUnionDemo()
}

private struct CompatibleGlassContainerUnionDemo: View {
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

    var body: some View {
        CompatibleGlassContainerPreviewBackground(height: 260) {
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
        }
    }
}

#Preview("Modifier: compatibleGlassEffectID") {
    CompatibleGlassContainerIDDemo()
}

private struct CompatibleGlassContainerIDDemo: View {
    @Namespace private var namespace
    @State private var showDetails = false

    var body: some View {
        CompatibleGlassContainerPreviewBackground(height: 260) {
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
        }
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
#endif
