import SwiftUI

// MARK: - Static Helpers

public extension PrimitiveButtonStyle where Self == UniversalGlassButtonStyle {
    static func universalGlass(
        rendering: UniversalGlassRendering = .automatic
    ) -> UniversalGlassButtonStyle {
        UniversalGlassButtonStyle(rendering: rendering)
    }
}

public extension PrimitiveButtonStyle where Self == UniversalGlassProminentButtonStyle {
    static func universalGlassProminent(
        rendering: UniversalGlassRendering = .automatic
    ) -> UniversalGlassProminentButtonStyle {
        UniversalGlassProminentButtonStyle(rendering: rendering)
    }
}

// MARK: - Backwards Universal Modifiers

public extension View {
    @ViewBuilder
    func universalGlassButtonStyle(
        isProminent _: Bool = false,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        self.buttonStyle(
            .universalGlass(rendering: rendering)
        )
    }

    @ViewBuilder
    func universalGlassProminentButtonStyle(
        isProminent _: Bool = true,
        rendering: UniversalGlassRendering = .automatic
    ) -> some View {
        self.buttonStyle(
            .universalGlassProminent(rendering: rendering)
        )
    }
}

#if DEBUG
#Preview("ButtonStyle: .glass") {
    let sizes: [ControlSize] = [.mini, .small, .regular, .large]

    ScrollView {
        ForEach(sizes, id: \.self) { size in
            VStack {
                Button("Glass Button") {}
                    .tint(.blue)
                    .font(.headline)
                    .buttonStyle(
                        .universalGlass()
                    )

                Button("Glass Button") {}
                    .tint(.blue)
                    .font(.headline)
                    .buttonStyle(.universalGlass(rendering: .material))
            }
            .padding(.vertical, 20)
            .controlSize(size)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("ButtonStyle: .glassProminent") {
    let sizes: [ControlSize] = [.mini, .small, .regular, .large]

    ScrollView {
        ForEach(sizes, id: \.self) { size in
            VStack {
                Button("Prominent Glass Button") {}
                    .tint(.purple)
                    .font(.headline)
                    .buttonStyle(
                        .universalGlassProminent()
                    )

                Button("Prominent Glass Button") {}
                    .tint(.purple)
                    .font(.headline)
                    .buttonStyle(.universalGlassProminent(rendering: .material))
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
            .universalGlass(rendering: .material)
        )
}

#Preview("ButtonStyle: .glassProminent (Tinted Fallback)") {
    Button("Tinted Glass Button") {}
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .tint(.pink)
        .buttonStyle(
            .universalGlassProminent(rendering: .material)
        )
}
#endif
