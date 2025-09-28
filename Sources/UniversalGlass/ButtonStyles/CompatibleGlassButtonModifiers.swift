import SwiftUI

// MARK: - Static Helpers

public extension PrimitiveButtonStyle where Self == CompatibleGlassButtonStyle {
    static func compatibleGlass(
        rendering: CompatibleGlassRendering = .automatic
    ) -> CompatibleGlassButtonStyle {
        CompatibleGlassButtonStyle(rendering: rendering)
    }
}

public extension PrimitiveButtonStyle where Self == CompatibleGlassProminentButtonStyle {
    static func compatibleGlassProminent(
        rendering: CompatibleGlassRendering = .automatic
    ) -> CompatibleGlassProminentButtonStyle {
        CompatibleGlassProminentButtonStyle(rendering: rendering)
    }
}

// MARK: - Backwards Compatible Modifiers

public extension View {
    @ViewBuilder
    func compatibleGlassButtonStyle(
        isProminent _: Bool = false,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        self.buttonStyle(
            .compatibleGlass(rendering: rendering)
        )
    }

    @ViewBuilder
    func compatibleGlassProminentButtonStyle(
        isProminent _: Bool = true,
        rendering: CompatibleGlassRendering = .automatic
    ) -> some View {
        self.buttonStyle(
            .compatibleGlassProminent(rendering: rendering)
        )
    }
}

#if DEBUG
#Preview("ButtonStyle: .glass") {
    let sizes: [ControlSize] = [.mini, .small, .regular, .large, .extraLarge]

    ScrollView {
        ForEach(sizes, id: \.self) { size in
            VStack {
                Button("Glass Button") {}
                    .tint(.blue)
                    .font(.headline)
                    .buttonStyle(
                        .compatibleGlass()
                    )

                Button("Glass Button") {}
                    .tint(.blue)
                    .font(.headline)
                    .buttonStyle(.compatibleGlass(rendering: .forceMaterial))
            }
            .padding(.vertical, 20)
            .controlSize(size)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("ButtonStyle: .glassProminent") {
    let sizes: [ControlSize] = [.mini, .small, .regular, .large, .extraLarge]

    ScrollView {
        ForEach(sizes, id: \.self) { size in
            VStack {
                Button("Prominent Glass Button") {}
                    .tint(.purple)
                    .font(.headline)
                    .buttonStyle(
                        .compatibleGlassProminent()
                    )

                Button("Prominent Glass Button") {}
                    .tint(.purple)
                    .font(.headline)
                    .buttonStyle(.compatibleGlassProminent(rendering: .forceMaterial))
            }
            .padding(.vertical, 20)
            .controlSize(size)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("ButtonStyle: .glass (Material Fallback)") {
    Button("Fallback Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .buttonStyle(
            .compatibleGlass(rendering: .forceMaterial)
        )
}

#Preview("ButtonStyle: .glassProminent (Tinted Fallback)") {
    Button("Tinted Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .tint(.pink)
        .buttonStyle(
            .compatibleGlassProminent(rendering: .forceMaterial)
        )
}
#endif
