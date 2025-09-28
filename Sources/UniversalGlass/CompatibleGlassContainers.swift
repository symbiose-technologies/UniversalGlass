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
#Preview("Modifier: glassEffectUnion") {
    @Previewable @Namespace var namespace
    @Previewable @State var showMoon = true
    
    return CompatibleGlassEffectContainer() {
        VStack(spacing: 20) {
            VStack(spacing: 0){
                Image(systemName: "star")
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .compatibleGlassEffect()
                    .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace)
                
                if showMoon{
                    Image(systemName: "moon")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .compatibleGlassEffect()
                        .compatibleGlassEffectUnion(id: "star and moon", namespace: namespace)
                }
            }
            
            Image(systemName: "sparkle")
                .font(.title)
                .frame(width: 80, height: 80)
                .compatibleGlassEffect()
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

#Preview("Modifier: compatibleGlassEffectTransition") {
    @Previewable @State var showMaterialize = true
    @Previewable @State var showGeometry = true
    @Previewable @State var showIdentity = true
    
    return CompatibleGlassEffectContainer() {
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
                Color(red: 0.15, green: 0.08, blue: 0.32),
                Color(red: 0.40, green: 0.10, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
