import SwiftUI

// MARK: - Backward Compatible Liquid Glass Effects

public extension View {

    /// Applies a glass effect with backward compatibility to Material on older iOS versions
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect(rendering: CompatibleGlassRendering = .automatic) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(
                    .regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                    in: .capsule
                )
            case .automatic, .forceGlass:
                self.glassEffect()
            }
        } else {
            self.background(
                .regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                in: .capsule
            )
        }
    }

    /// Applies a glass effect with custom shape and backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(
                    .regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                    in: shape
                )
            case .automatic, .forceGlass:
                self.glassEffect(in: shape)
            }
        } else {
            self.background(
                .regularMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                in: shape
            )
        }
    }

    /// Applies a glass effect with custom glass configuration and backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect(
        _ glass: CompatibleGlass,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(
                    glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                    in: .capsule
                )
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass)
                } else {
                    self.glassEffect()
                }
            }
        } else {
            self.background(
                glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                in: .capsule
            )
        }
    }

    /// Applies a glass effect with custom glass configuration and shape with backward compatibility
    /// - Parameter rendering: Controls whether glass or material rendering is enforced.
    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(
        _ glass: CompatibleGlass,
        in shape: S,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            switch rendering {
            case .forceMaterial:
                self.background(
                    glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                    in: shape
                )
            case .automatic, .forceGlass:
                if let actualGlass = glass.liquidGlass {
                    self.glassEffect(actualGlass, in: shape)
                } else {
                    self.glassEffect(in: shape)
                }
            }
        } else {
            self.background(
                glass.fallbackMaterial.shadow(.drop(color: .black.opacity(0.04), radius: 8)),
                in: shape
            )
        }
    }
}

// MARK: - Compatible Glass Configuration

/// A configuration type that provides liquid glass effects on iOS 26+ and material fallbacks on older versions
public struct CompatibleGlass {
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

    /// Regular liquid glass effect with regular material fallback
    nonisolated(unsafe) public static let regular: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(
                fallbackMaterial: .regularMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return CompatibleGlass(fallbackMaterial: .regularMaterial)
        }
    }()

    /// Thick liquid glass effect with thick material fallback
    nonisolated(unsafe) public static let thick: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(
                fallbackMaterial: .thickMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return CompatibleGlass(fallbackMaterial: .thickMaterial)
        }
    }()

    /// Thin liquid glass effect with thin material fallback
    nonisolated(unsafe) public static let thin: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(
                fallbackMaterial: .thinMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return CompatibleGlass(fallbackMaterial: .thinMaterial)
        }
    }()

    /// Ultra thin liquid glass effect with ultra thin material fallback
    nonisolated(unsafe) public static let ultraThin: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(
                fallbackMaterial: .ultraThinMaterial,
                liquidGlass: Glass.regular
            )
        } else {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()

    /// Clear liquid glass effect with ultra thin material fallback
    nonisolated(unsafe) public static let clear: CompatibleGlass = {
        if #available(iOS 26.0, macOS 26.0, *) {
            return CompatibleGlass(
                fallbackMaterial: .ultraThinMaterial,
                liquidGlass: Glass.clear
            )
        } else {
            return CompatibleGlass(fallbackMaterial: .ultraThinMaterial)
        }
    }()

    /// Creates a tinted liquid glass effect with the specified color
    /// Falls back to regular material on older versions
    public func tint(_ color: Color) -> CompatibleGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let tintedGlass: Any = existingGlass.tint(color)
                return CompatibleGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: tintedGlass
                )
            } else {
                let tintedGlass: Any = Glass.regular.tint(color)
                return CompatibleGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: tintedGlass
                )
            }
        } else {
            return CompatibleGlass(fallbackMaterial: fallbackMaterial)
        }
    }

    /// Creates an interactive liquid glass effect
    /// Falls back to the same material on older versions
    public func interactive(_ isInteractive: Bool = true) -> CompatibleGlass {
        if #available(iOS 26.0, macOS 26.0, *) {
            if let existingGlass = liquidGlass {
                let interactiveGlass: Any = existingGlass.interactive(isInteractive)
                return CompatibleGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: interactiveGlass
                )
            } else {
                let interactiveGlass: Any = Glass.regular.interactive(isInteractive)
                return CompatibleGlass(
                    fallbackMaterial: fallbackMaterial,
                    liquidGlass: interactiveGlass
                )
            }
        } else {
            return CompatibleGlass(fallbackMaterial: fallbackMaterial)
        }
    }
}

// MARK: - Compatible Glass Rendering

/// Determines how compatible glass APIs render across different iOS versions.
public enum CompatibleGlassRendering {
    /// Uses glass on supported versions and falls back automatically otherwise.
    case automatic
    /// Forces the use of glass on supported versions, falling back to material when unavailable.
    @available(iOS 26.0, macOS 26.0, *)
    case forceGlass
    /// Forces the material fallback even on platforms that support glass.
    case forceMaterial
}

#if DEBUG

#Preview("Modifier: compatibleGlassEffect") {
        Text("Automatic Glass")
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .compatibleGlassEffect(rendering: .automatic)
}

#Preview("Modifier: compatibleGlassEffect (Shape)") {
    Text("Custom Shape")
        .font(.title3.weight(.semibold))
        .padding(28)
        .compatibleGlassEffect(
            in: RoundedRectangle(cornerRadius: 28, style: .continuous),
            rendering: .automatic
        )
}

#Preview("Modifier: compatibleGlassEffect (Custom Glass)") {
    Text("Tinted Regular Glass")
        .font(.title3.weight(.semibold))
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .compatibleGlassEffect(CompatibleGlass.regular.tint(.cyan), rendering: .automatic)
}

#Preview("Modifier: compatibleGlassEffect (Glass + Shape)") {
    Text("Clear Capsule")
        .font(.title3.weight(.semibold))
        .padding(28)
        .compatibleGlassEffect(
            CompatibleGlass.clear,
            in: Capsule(),
            rendering: .automatic
        )
}
#endif
