import SwiftUI

// MARK: - Compatible Scroll Extension Mode

public enum CompatibleScrollExtensionMode {
    case underSidebar
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

#endif
