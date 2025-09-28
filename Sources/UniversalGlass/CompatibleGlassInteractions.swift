import SwiftUI

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

// MARK: - Interaction Helpers

public extension View {

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

#if DEBUG

#Preview("Modifier: compatibleScrollExtensionMode") {
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

#Preview("Modifier: compatibleGlassEffectTransition") {
    VStack(spacing: 20) {
        Text("Materialize transition applied to incoming content.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

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

        VStack(spacing: 12) {
            Text("Static State")
                .font(.headline)
            Text("No transition modifier applied here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .compatibleGlassEffect(rendering: .automatic)
        .compatibleGlassEffectTransition(.none)
    }
    .padding()
}
#endif
