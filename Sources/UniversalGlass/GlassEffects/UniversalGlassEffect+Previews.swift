import SwiftUI

#if DEBUG
#Preview("Modifier: universalGlassEffect") {
    Text("Glass Effect")
        .font(.title3.weight(.semibold))
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .universalGlassEffect()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.32),
                    Color(red: 0.05, green: 0.38, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}

#Preview("Modifier: universalGlassEffect (Shape)") {
    Text("Custom Shape")
        .font(.title3.weight(.semibold))
        .padding(28)
        .universalGlassEffect(
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.32),
                    Color(red: 0.05, green: 0.38, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}

#Preview("Modifier: universalGlassEffect (Custom Glass)") {
    Text("Tinted Regular Glass")
        .font(.title3.weight(.semibold))
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .universalGlassEffect(.regular.tint(.cyan))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.32),
                    Color(red: 0.05, green: 0.38, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}

#Preview("Modifier: universalGlassEffect (Glass + Shape)") {
    Text("Clear Capsule")
        .font(.title3.weight(.semibold))
        .padding(28)
        .universalGlassEffect(
            .clear,
            in: Capsule()
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.32),
                    Color(red: 0.05, green: 0.38, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}

#Preview("Modifier: universalGlassEffect (Glass + Interactive)") {
    Text("Clear Interactive")
        .font(.title3.weight(.semibold))
        .padding(28)
        .universalGlassEffect(
            .clear.interactive()
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.32),
                    Color(red: 0.05, green: 0.38, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
#endif
