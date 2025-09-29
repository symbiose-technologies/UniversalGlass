import SwiftUI

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

    /// Thick liquid glass effect with thick material fallback.
    nonisolated(unsafe) public static let thick: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .thickMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return UniversalGlass(fallbackMaterial: .thickMaterial)
        }
    }()

    /// Thin liquid glass effect with thin material fallback.
    nonisolated(unsafe) public static let thin: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .thinMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return UniversalGlass(fallbackMaterial: .thinMaterial)
        }
    }()

    /// Ultra thin liquid glass effect with ultra thin material fallback.
    nonisolated(unsafe) public static let ultraThin: UniversalGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return UniversalGlass(
                fallbackMaterial: .ultraThinMaterial,
                liquidGlass: Glass.regular
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

#if DEBUG
#Preview("UniversalGlass presets") {
    let glasses: [(title: String, configuration: UniversalGlass)] = [
        ("Regular", .regular),
        ("Clear + Tint", .clear.tint(.cyan)),
        ("Ultrathin", .ultraThin),
        ("Thin", .thin),
        ("Regular", .regular),
        ("Thick", .thick),
        ("Interactive", .regular.interactive())
    ]

    return VStack(spacing: 24) {
        ForEach(Array(glasses.enumerated()), id: \.offset) { entry in
            Label(entry.element.title, systemImage: "sparkles")
                .font(.headline)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .universalGlassEffect(entry.element.configuration)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.18, blue: 0.34), Color(red: 0.04, green: 0.32, blue: 0.44)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    )
}
#endif
