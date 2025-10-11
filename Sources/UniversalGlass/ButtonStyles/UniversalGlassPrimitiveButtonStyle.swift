import SwiftUI

// MARK: - Primitive Button Styles

public struct UniversalGlassButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: UniversalGlassRendering

    public init(
        rendering: UniversalGlassRendering = .automatic
    ) {
        self.rendering = rendering
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        AnyView(resolvedBody(configuration: configuration))
    }

    @ViewBuilder
    private func resolvedBody(configuration: Configuration) -> some View {
        if shouldUseGlass {
            if #available(iOS 26.0, macOS 26.0, *) {
                GlassButtonStyle().makeBody(configuration: configuration)
            } else {
                fallbackBody(configuration: configuration)
            }
        } else {
            fallbackBody(configuration: configuration)
        }
    }

    @ViewBuilder
    private func fallbackBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger) {
            configuration.label
        }
        .buttonStyle(.bordered)
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

public struct UniversalGlassProminentButtonStyle: PrimitiveButtonStyle {
    public typealias Body = AnyView

    private let rendering: UniversalGlassRendering

    public init(
        rendering: UniversalGlassRendering = .automatic
    ) {
        self.rendering = rendering
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        AnyView(resolvedBody(configuration: configuration))
    }

    @ViewBuilder
    private func resolvedBody(configuration: Configuration) -> some View {
        if shouldUseGlass {
            if #available(iOS 26.0, macOS 26.0, *) {
                GlassProminentButtonStyle().makeBody(configuration: configuration)
            } else {
                fallbackBody(configuration: configuration)
            }
        } else {
            fallbackBody(configuration: configuration)
        }
    }

    @ViewBuilder
    private func fallbackBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger) {
            configuration.label
        }
        .buttonStyle(.borderedProminent)
    }

    private var shouldUseGlass: Bool {
        resolveShouldUseGlass(for: rendering)
    }
}

// MARK: - Shared Resolution

// `@inline(__always)` requests the compiler to substitute the function body at every call site.
@inline(__always)
private func resolveShouldUseGlass(for rendering: UniversalGlassRendering) -> Bool {
    // Inline to keep the availability-heavy branching from adding extra view layers.
    if #available(iOS 26.0, macOS 26.0, *) {
        if case .material = rendering {
            return false
        }
        
        if case .glass = rendering {
            return true
        }
        
        return true
    } else {
        return false
    }
}

#if DEBUG
#Preview("Primitive Glass Buttons") {
    
    VStack(spacing: 24) {
        
        Button("Automatic") { }
            .buttonStyle(.universalGlass())
            .controlSize(.large)
            .tint(.purple)
        
        Button("Material Forced") { }
            .buttonStyle(.universalGlass(rendering: .material))
            .controlSize(.large)
            .tint(.purple)
        
        Button("Automatic Prominent") { }
            .buttonStyle(.universalGlassProminent())
            .controlSize(.large)
            .tint(.purple)
        
        Button("Material Forced Prominent") {}
            .buttonStyle(.universalGlassProminent(rendering: .material))
            .controlSize(.large)
            .tint(.purple)
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
