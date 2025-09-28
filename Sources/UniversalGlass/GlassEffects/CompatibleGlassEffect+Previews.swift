import SwiftUI

#if DEBUG
#Preview("Modifier: compatibleGlassEffect") {
    Text("Glass Effect")
        .font(.title3.weight(.semibold))
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .compatibleGlassEffect()
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

#Preview("Modifier: compatibleGlassEffect (Shape)") {
    Text("Custom Shape")
        .font(.title3.weight(.semibold))
        .padding(28)
        .compatibleGlassEffect(
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

#Preview("Modifier: compatibleGlassEffect (Custom Glass)") {
    Text("Tinted Regular Glass")
        .font(.title3.weight(.semibold))
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .compatibleGlassEffect(.regular.tint(.cyan))
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

#Preview("Modifier: compatibleGlassEffect (Glass + Shape)") {
    Text("Clear Capsule")
        .font(.title3.weight(.semibold))
        .padding(28)
        .compatibleGlassEffect(
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

#Preview("Modifier: compatibleGlassEffect (Glass + Interactive)") {
    Text("Clear Interactive")
        .font(.title3.weight(.semibold))
        .padding(28)
        .compatibleGlassEffect(
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
