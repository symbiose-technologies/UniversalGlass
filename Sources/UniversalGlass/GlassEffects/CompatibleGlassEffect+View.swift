import SwiftUI

// MARK: - Backward Compatible Liquid Glass Effects

public extension View {
    /// Applies a glass effect with backward compatibility to Material on older versions.
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

    /// Applies a glass effect with custom shape and backward compatibility.
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

    /// Applies a glass effect with custom glass configuration and backward compatibility.
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

    /// Applies a glass effect with custom glass configuration and shape.
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
