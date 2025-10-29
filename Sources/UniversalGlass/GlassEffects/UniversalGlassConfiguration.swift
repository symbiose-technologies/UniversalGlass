import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Helpers

private extension UniversalGlassConfiguration {
    static func systemBackgroundTint(opacity: Double) -> Color {
        let base: Color
#if canImport(UIKit)
        base = Color(UIColor.systemBackground)
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        base = Color(NSColor.windowBackgroundColor)
#else
        base = Color.white
#endif
        return base.opacity(opacity)
    }
}
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

// MARK: - Universal Glass Shadow

/// Defines shadow properties for glass effect fallbacks.
public struct UniversalGlassShadow: Equatable {
    public let color: Color
    public let radius: CGFloat

    /// Creates a custom shadow configuration.
    /// - Parameters:
    ///   - color: The shadow color.
    ///   - radius: The shadow blur radius.
    public init(color: Color, radius: CGFloat) {
        self.color = color
        self.radius = radius
    }

    /// Default shadow with subtle black blur.
    nonisolated(unsafe) public static let `default` = UniversalGlassShadow(
        color: .black.opacity(0.04),
        radius: 8
    )

    /// No shadow.
    nonisolated(unsafe) public static let none = UniversalGlassShadow(
        color: .clear,
        radius: 0
    )
}

// MARK: - Universal Glass Configuration

/// A configuration type that provides liquid glass effects on iOS 26+ and material fallbacks on older versions.
public struct UniversalGlassConfiguration {
    let fallbackMaterial: Material?
    let fallbackTint: Color?
    let fallbackShadow: UniversalGlassShadow
    private let _liquidGlass: Any?

    #if !os(visionOS)
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    public var liquidGlass: Glass? {
        _liquidGlass as? Glass
    }
    #endif

    private init(
        fallbackMaterial: Material?,
        fallbackTint: Color? = nil,
        fallbackShadow: UniversalGlassShadow = .default,
        liquidGlass: Any? = nil
    ) {
        self.fallbackMaterial = fallbackMaterial
        self.fallbackTint = fallbackTint
        self.fallbackShadow = fallbackShadow
        self._liquidGlass = liquidGlass
    }
    
    /// Regular liquid glass effect with regular material fallback.
    nonisolated(unsafe) public static let regular: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return UniversalGlassConfiguration(
                fallbackMaterial: .regularMaterial,
                fallbackTint: nil,
                liquidGlass: Glass.regular
            )
        } else {
            return UniversalGlassConfiguration(fallbackMaterial: .regularMaterial)
        }
        #else
        return UniversalGlassConfiguration(fallbackMaterial: .regularMaterial)
        #endif
    }()
    
    /// Thick liquid glass effect with thick material fallback and subtle background tint.
    nonisolated(unsafe) public static let thick: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.4)
            let tintedGlass: Any = Glass.regular.tint(tint)
            return UniversalGlassConfiguration(
                fallbackMaterial: .thickMaterial,
                fallbackTint: tint,
                liquidGlass: tintedGlass
            )
        }
        #endif
        return UniversalGlassConfiguration(
            fallbackMaterial: .thickMaterial,
            fallbackTint: nil
        )
    }()

    /// Ultra thick liquid glass effect with ultra thick material fallback and stronger tinting.
    nonisolated(unsafe) public static let ultraThick: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.7)
            let tintedGlass: Any = Glass.regular.tint(tint)
            return UniversalGlassConfiguration(
                fallbackMaterial: .ultraThickMaterial,
                fallbackTint: tint,
                liquidGlass: tintedGlass
            )
        }
        #endif
        return UniversalGlassConfiguration(
            fallbackMaterial: .ultraThickMaterial,
            fallbackTint: nil
        )
    }()

    /// Thin liquid glass effect with thin material fallback and a faint background tint.
    nonisolated(unsafe) public static let thin: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.4)
            let tintedGlass: Any = Glass.clear.tint(tint)
            return UniversalGlassConfiguration(
                fallbackMaterial: .thinMaterial,
                fallbackTint: tint,
                liquidGlass: tintedGlass
            )
        }
        #endif
        return UniversalGlassConfiguration(
            fallbackMaterial: .thinMaterial,
            fallbackTint: nil
        )
    }()

    /// Ultra thin liquid glass effect with ultra thin material fallback using clear glass.
    nonisolated(unsafe) public static let ultraThin: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return UniversalGlassConfiguration(
                fallbackMaterial: .ultraThinMaterial,
                fallbackTint: nil,
                liquidGlass: Glass.clear
            )
        } else {
            return UniversalGlassConfiguration(fallbackMaterial: .ultraThinMaterial)
        }
        #else
        return UniversalGlassConfiguration(fallbackMaterial: .ultraThinMaterial)
        #endif
    }()

    /// Clear liquid glass effect with ultra thin material fallback.
    nonisolated(unsafe) public static let clear: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return UniversalGlassConfiguration(
                fallbackMaterial: .ultraThinMaterial,
                fallbackTint: nil,
                liquidGlass: Glass.clear
            )
        } else {
            return UniversalGlassConfiguration(fallbackMaterial: .ultraThinMaterial)
        }
        #else
        return UniversalGlassConfiguration(fallbackMaterial: .ultraThinMaterial)
        #endif
    }()

    /// Identity configuration with no glass effect or material.
    nonisolated(unsafe) public static let identity: UniversalGlassConfiguration = {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            return UniversalGlassConfiguration(
                fallbackMaterial: nil,
                fallbackTint: nil,
                liquidGlass: Glass.identity
            )
        } else {
            return UniversalGlassConfiguration(fallbackMaterial: nil)
        }
        #else
        return UniversalGlassConfiguration(fallbackMaterial: nil)
        #endif
    }()

    /// Creates a tinted liquid glass effect with the specified color.
    /// Falls back to regular material on older versions.
    public func tint(_ color: Color) -> UniversalGlassConfiguration {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let tintedGlass: Any = existingGlass.tint(color)
                return UniversalGlassConfiguration(
                    fallbackMaterial: fallbackMaterial,
                    fallbackTint: color,
                    fallbackShadow: fallbackShadow,
                    liquidGlass: tintedGlass
                )
            } else {
                let tintedGlass: Any = Glass.regular.tint(color)
                return UniversalGlassConfiguration(
                    fallbackMaterial: fallbackMaterial,
                    fallbackTint: color,
                    fallbackShadow: fallbackShadow,
                    liquidGlass: tintedGlass
                )
            }
        }
        #endif
        return UniversalGlassConfiguration(
            fallbackMaterial: fallbackMaterial,
            fallbackTint: color,
            fallbackShadow: fallbackShadow
        )
    }

    /// Creates an interactive liquid glass effect.
    /// Falls back to the same material on older versions.
    public func interactive(_ isInteractive: Bool = true) -> UniversalGlassConfiguration {
        #if !os(visionOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let interactiveGlass: Any = existingGlass.interactive(isInteractive)
                return UniversalGlassConfiguration(
                    fallbackMaterial: fallbackMaterial,
                    fallbackTint: fallbackTint,
                    fallbackShadow: fallbackShadow,
                    liquidGlass: interactiveGlass
                )
            } else {
                let interactiveGlass: Any = Glass.regular.interactive(isInteractive)
                return UniversalGlassConfiguration(
                    fallbackMaterial: fallbackMaterial,
                    fallbackTint: fallbackTint,
                    fallbackShadow: fallbackShadow,
                    liquidGlass: interactiveGlass
                )
            }
        }
        #endif
        return UniversalGlassConfiguration(
            fallbackMaterial: fallbackMaterial,
            fallbackTint: fallbackTint,
            fallbackShadow: fallbackShadow
        )
    }

    /// Customizes the fallback material and tint used on older OS versions.
    /// - Parameters:
    ///   - material: The Material to use when liquid glass is unavailable. Pass `nil` to remove material fallback.
    ///   - tint: Optional color tint to apply to the fallback. Pass `nil` to remove tint.
    /// - Returns: A new configuration with the specified fallback settings.
    public func fallback(material: Material?, tint: Color? = nil) -> UniversalGlassConfiguration {
        return UniversalGlassConfiguration(
            fallbackMaterial: material,
            fallbackTint: tint,
            fallbackShadow: fallbackShadow,
            liquidGlass: _liquidGlass
        )
    }

    /// Customizes the shadow applied to the fallback material on older OS versions.
    /// - Parameter shadow: The shadow configuration to use for the fallback.
    /// - Returns: A new configuration with the specified shadow settings.
    public func shadow(_ shadow: UniversalGlassShadow) -> UniversalGlassConfiguration {
        return UniversalGlassConfiguration(
            fallbackMaterial: fallbackMaterial,
            fallbackTint: fallbackTint,
            fallbackShadow: shadow,
            liquidGlass: _liquidGlass
        )
    }
}

// MARK: - Universal Glass Rendering

/// Determines how universal glass APIs render across different versions.
public enum UniversalGlassRendering {
    /// Uses glass on supported versions and falls back automatically otherwise.
    case automatic
    /// Forces the use of glass on supported versions, falling back to material when unavailable.
    @available(iOS 26.0, macOS 26.0, *)
    case glass
    /// Forces the material fallback even on platforms that support glass.
    case material
}
