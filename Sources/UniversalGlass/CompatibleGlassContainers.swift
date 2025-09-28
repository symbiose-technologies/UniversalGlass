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
            self
        }
    }
}

#if DEBUG

#Preview("Container: CompatibleGlassEffectContainer") {
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
    .padding()
}

#Preview("Modifier: compatibleGlassEffectUnion") {
    @Previewable @Namespace var namespace
    @Previewable @State var mergeHighlights = true

    let cards: [(title: String, subtitle: String, systemImage: String)] = [
        ("Primary", "Core functions", "app.badge.fill"),
        ("Secondary", "Assistive tools", "wand.and.stars"),
        ("Background", "Support services", "bolt.fill")
    ]

    return VStack(spacing: 20) {
        Text("Toggle to see how glass unions merge adjacent cards inside a container.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

        CompatibleGlassEffectContainer(spacing: mergeHighlights ? 12 : 28, rendering: .automatic) {
            HStack(spacing: mergeHighlights ? 12 : 20) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
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
    .padding()
}

#Preview("Modifier: compatibleGlassEffectID") {
    @Previewable @Namespace var namespace
    @Previewable @State var showDetails = false

    return VStack(spacing: 20) {
        Text("Toggle between compact and expanded cards that share the same glass identity.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

        CompatibleGlassEffectContainer(spacing: 24, rendering: .automatic) {
            Group {
                if showDetails {
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
                    .compatibleGlassEffectID("card", in: namespace)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Design Summary")
                            .font(.headline)
                        Text("Compact layout shares its glass identity with the expanded card.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .compatibleGlassEffect(rendering: .automatic)
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
    .padding()
}

#Preview("Modifier: compatibleGlassEffectTransition") {
    @Previewable @State var showMaterialize = true
    @Previewable @State var showGeometry = true
    @Previewable @State var showIdentity = true

    return CompatibleGlassEffectContainer(spacing: 18, rendering: .automatic) {
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
                .compatibleGlassEffect(rendering: .automatic)
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
                .compatibleGlassEffect(rendering: .automatic)
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
                .compatibleGlassEffect(rendering: .automatic)
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
            .compatibleGlassButtonStyle(rendering: .automatic)

            Button(showGeometry ? "Hide Matched" : "Show Matched") {
                withAnimation(.spring(duration: 0.45)) {
                    showGeometry.toggle()
                }
            }
            .compatibleGlassButtonStyle(rendering: .automatic)

            Button(showIdentity ? "Hide Identity" : "Show Identity") {
                withAnimation(.spring(duration: 0.45)) {
                    showIdentity.toggle()
                }
            }
            .compatibleGlassButtonStyle(rendering: .automatic)
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
#endif
