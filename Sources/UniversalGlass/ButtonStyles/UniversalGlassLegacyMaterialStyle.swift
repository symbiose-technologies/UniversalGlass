import SwiftUI

// MARK: - Legacy Fallback Rendering

enum UniversalGlassLegacyVariant {
    case standard
    case prominent
}

struct UniversalGlassLegacyMaterialStyle: ButtonStyle {
    let variant: UniversalGlassLegacyVariant
    
    func makeBody(configuration: Configuration) -> some View {
        UniversalGlassLegacyMaterialBody(
            configuration: configuration,
            variant: variant
        )
    }
}

private struct UniversalGlassLegacyMaterialBody: View {
    let configuration: ButtonStyle.Configuration
    let variant: UniversalGlassLegacyVariant
    
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        styledLabel
            .padding(padding)
            .contentShape(.capsule)
            .background(background)
            .clipShape(Capsule())
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowYOffset)
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(animation, value: configuration.isPressed)
    }
    
    @ViewBuilder
    private var styledLabel: some View {
        switch variant {
        case .standard:
            configuration.label
                .foregroundStyle(.tint)
        case .prominent:
            configuration.label
                .foregroundStyle(Color.white.opacity(isEnabled ? 0.95 : 0.6))
        }
    }
    
    private var padding: EdgeInsets {
        let metrics = metrics(for: controlSize)
        return EdgeInsets(
            top: metrics.vertical,
            leading: metrics.horizontal,
            bottom: metrics.vertical,
            trailing: metrics.horizontal
        )
    }
    
    private func metrics(for controlSize: ControlSize) -> (horizontal: CGFloat, vertical: CGFloat) {
        let prominent = variant == .prominent
        
        switch controlSize {
        case .mini:
            return prominent ? (12, 5) : (12, 5)
        case .small:
            return prominent ? (12, 6) : (12, 6)
        case .regular:
            return prominent ? (12, 7) : (12, 7)
        case .large:
            return prominent ? (20, 15) : (20, 15)
        case .extraLarge:
            return prominent ? (20, 15) : (20, 15)
        @unknown default:
            return prominent ? (12, 7) : (12, 7)
        }
    }
    
    @ViewBuilder
    private var background: some View {
        ZStack {
            Color.clear
                .universalGlassEffect(backgroundGlass, in: Capsule(), rendering: .material)
            
            if variant == .prominent {
                Capsule()
                    .fill(.tint)
                    .opacity(isEnabled ? 1.0 : 0.32)
            }
            
            Capsule()
                .strokeBorder(Color.white.opacity(0.4), lineWidth: borderWidth)
                .opacity(borderOpacity)
        }
    }
    
    private var backgroundGlass: UniversalGlass {
        let glass: UniversalGlass
        
        switch variant {
        case .standard:
            glass = .clear
        case .prominent:
            glass = .regular
        }
        
        return glass.interactive()
    }
    
    private var borderWidth: CGFloat {
        variant == .prominent ? 1.4 : 1
    }
    
    private var borderOpacity: CGFloat {
        let base: CGFloat = variant == .prominent ? 0.7 : 0.5
        return base * (isEnabled ? 1 : 0.45)
    }
    
    private var shadowColor: Color {
        let base: Double = variant == .prominent ? 0.1 : 0.02
        return Color.black.opacity(isEnabled ? base : base * 0.35)
    }
    
    private var shadowRadius: CGFloat {
        variant == .prominent ? 14 : 10
    }
    
    private var shadowYOffset: CGFloat {
        variant == .prominent ? 4 : 3
    }
    
    private var animation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.12)
    }
}

#if DEBUG
#Preview("Legacy Material Buttons") {
    
    VStack(spacing: 20) {
        Button("UniversalGlassLegacyMaterialStyle Standard") { }
            .tint(.pink)
            .buttonStyle(
                UniversalGlassLegacyMaterialStyle(
                    variant: .standard
                )
            )
            .controlSize(.large)
        
        Button("UniversalGlassLegacyMaterialStyle Prominent") { }
            .tint(.pink)
            .controlSize(.large)
            .buttonStyle(
                UniversalGlassLegacyMaterialStyle(
                    variant: .prominent
                )
            )
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    .background(
        Image("tulips", bundle: .module)
            .resizable()
        .ignoresSafeArea()
        
        // Photo by <a href="https://unsplash.com/@mike_loftus?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Michael Loftus</a> on <a href="https://unsplash.com/photos/a-field-of-yellow-tulips-under-a-blue-sky-aK4Slh-4uhU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
    )
}
#endif
