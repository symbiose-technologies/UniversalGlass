import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Helpers

private extension UniversalGlass {
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

// MARK: - Universal Glass Configuration

/// A configuration type that provides liquid glass effects on iOS 26+ and material fallbacks on older versions.
public struct UniversalGlass {
    let fallbackMaterial: Material
    private let _liquidGlass: Any?
    
    @available(iOS 26.0, macOS 26.0, *)
    public var liquidGlass: Glass? {
        _liquidGlass as? Glass
    }
    
    private init(fallbackMaterial: Material, liquidGlass: Any? = nil) {
        self.fallbackMaterial = fallbackMaterial
        self._liquidGlass = liquidGlass
    }
    
    /// Regular liquid glass effect with regular material fallback.
    nonisolated(unsafe) public static let regular: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .regularMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return UniversalGlass(fallbackMaterial: .regularMaterial)
        }
    }()
    
    /// Thick liquid glass effect with thick material fallback and subtle background tint.
    nonisolated(unsafe) public static let thick: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.28)
            let tintedGlass: Any = Glass.regular.tint(tint)
            return UniversalGlass(
                fallbackMaterial: .thickMaterial,
                liquidGlass: tintedGlass
            )
        } else {
            return UniversalGlass(fallbackMaterial: .thickMaterial)
        }
    }()
    
    /// Ultra thick liquid glass effect with ultra thick material fallback and stronger tinting.
    nonisolated(unsafe) public static let ultraThick: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.42)
            let tintedGlass: Any = Glass.regular.tint(tint)
            return UniversalGlass(
                fallbackMaterial: .ultraThickMaterial,
                liquidGlass: tintedGlass
            )
        } else {
            return UniversalGlass(fallbackMaterial: .ultraThickMaterial)
        }
    }()
    
    /// Thin liquid glass effect with thin material fallback and a faint background tint.
    nonisolated(unsafe) public static let thin: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            let tint = systemBackgroundTint(opacity: 0.18)
            let tintedGlass: Any = Glass.clear.tint(tint)
            return UniversalGlass(
                fallbackMaterial: .thinMaterial,
                liquidGlass: tintedGlass
            )
        } else {
            return UniversalGlass(fallbackMaterial: .thinMaterial)
        }
    }()
    
    /// Ultra thin liquid glass effect with ultra thin material fallback using clear glass.
    nonisolated(unsafe) public static let ultraThin: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .ultraThinMaterial,
                liquidGlass: Glass.clear
            )
        } else {
            return UniversalGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()
    
    /// Clear liquid glass effect with ultra thin material fallback.
    nonisolated(unsafe) public static let clear: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .ultraThinMaterial,
                liquidGlass: Glass.clear
            )
        } else {
            return UniversalGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()
    
    /// Creates a tinted liquid glass effect with the specified color.
    /// Falls back to regular material on older versions.
    public func tint(_ color: Color) -> UniversalGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let tintedGlass: Any = existingGlass.tint(color)
                return UniversalGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: tintedGlass
                )
            } else {
                let tintedGlass: Any = Glass.regular.tint(color)
                return UniversalGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: tintedGlass
                )
            }
        } else {
            return UniversalGlass(fallbackMaterial: fallbackMaterial)
        }
    }
    
    /// Creates an interactive liquid glass effect.
    /// Falls back to the same material on older versions.
    public func interactive(_ isInteractive: Bool = true) -> UniversalGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let interactiveGlass: Any = existingGlass.interactive(isInteractive)
                return UniversalGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: interactiveGlass
                )
            } else {
                let interactiveGlass: Any = Glass.regular.interactive(isInteractive)
                return UniversalGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: interactiveGlass
                )
            }
        } else {
            return UniversalGlass(fallbackMaterial: fallbackMaterial)
        }
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
