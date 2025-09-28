import SwiftUI

// MARK: - Compatible Scroll Extension Mode

public enum CompatibleScrollExtensionMode {
    case underSidebar
    case none
}

// MARK: - Compatible Glass Effect Transition

public enum CompatibleGlassEffectTransition {
    case materialize
    case matchedGeometry
    case identity
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
        _ transition: CompatibleGlassEffectTransition
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
                switch transition {
                case .materialize:
                    self.glassEffectTransition(.materialize)
                case .matchedGeometry:
                    self.glassEffectTransition(.matchedGeometry)
                case .identity:
                    self.glassEffectTransition(.identity)
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
    @Previewable @State var showMaterialize: Bool = true
    @Previewable @State var showGeometry: Bool = true
    @Previewable @State var showNone: Bool = true
    
    CompatibleGlassEffectContainer{
        VStack(spacing: 20) {
            if showMaterialize{
                VStack(spacing: 12) {
                    Text("Materialize transition.")
                        .font(.headline)
                }
                .padding(24)
                .compatibleGlassEffect()
                .compatibleGlassEffectTransition(.materialize)
            }
            
            if showGeometry{
                VStack(spacing: 12) {
                    Text("MatchedGeometry Transition.")
                        .font(.headline)
                }
                .padding(24)
                .compatibleGlassEffect()
                .compatibleGlassEffectTransition(.matchedGeometry)
            }
            
            if showNone{
                VStack(spacing: 12) {
                    Text("No Transition.")
                        .font(.headline)
                }
                .padding(24)
                .compatibleGlassEffect()
                .compatibleGlassEffectTransition(.identity)
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .safeAreaInset(edge: .bottom, content: {
        VStack{
            Button("Toggle Materialize"){
                withAnimation{
                    showMaterialize.toggle()
                }
            }
            Button("Toggle MatchedGeometry"){
                withAnimation{
                    showGeometry.toggle()
                }
            }
            Button("Toggle None"){
                withAnimation{
                    showNone.toggle()
                }
            }
        }
        .foregroundStyle(.white)
    })
    .background(.pink.gradient)
}
#endif
