<div align="center">
  <img width="270" height="270" src="/assets/icon.png" alt="UniversalGlass Logo">
  <h1><b>UniversalGlass</b></h1>
  <p>
    Bring SwiftUI’s iOS 26 glass APIs to earlier deployments with lightweight shims—keep your UI consistent on iOS 18+, yet automatically defer to the real implementations wherever they exist.
    <br>
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://badgen.net/badge/iOS/17+/purple" alt="iOS 17+"></a>
  <a href="https://www.apple.com/macos/"><img src="https://badgen.net/badge/macOS/13+/blue" alt="macOS 13+"></a>
  <a href="https://developer.apple.com/tvos/"><img src="https://badgen.net/badge/tvOS/17+/blue" alt="tvOS 17+"></a>
  <a href="https://developer.apple.com/watchos/"><img src="https://badgen.net/badge/watchOS/10+/blue" alt="watchOS 10+"></a>
  <a href="https://swift.org/"><img src="https://badgen.net/badge/Swift/6.2/orange" alt="Swift 6.2"></a>
  <a href="https://developer.apple.com/xcode/"><img src="https://badgen.net/badge/Xcode/16+/blue" alt="Xcode 16"></a>
</p>
        
---

## Why UniversalGlass?

OS 26 introduces new SwiftUI glass APIs, but these only ship on the latest platforms. UniversalGlass **isn't** a pixel-perfect recreation; it offers compatibility layers and API conveniences so your code paths stay unified on older systems, then quietly defers to Apple’s implementation on platforms that ship it.

![CleanShot 2025-09-28 at 00 52 41](https://github.com/user-attachments/assets/2bb99027-e86a-4c98-84d1-86b527336be8)

---

## Highlights

- **Glass for every surface** – Apply `universalGlassEffect` to any view, shape, or custom `UniversalGlass` configuration. Liquid accents, tinting, and interactivity
- **Buttons that feel native** – `.universalGlass()` and `.universalGlassProminent()` mirror the future SwiftUI button styles, including a custom material fallback that respects tint, control size, and press animations
- **Containers & morphing** – Drop content into `UniversalGlassEffectContainer` and use union/ID helpers to bridge to SwiftUI’s morphing APIs
- **Backports when you want them** – Import the optional `UniversalGlassBackports` target to get `.glass`, `.glassProminent`, and `.glassEffect`. They’re convenience shims that forward to the true SwiftUI APIs on iOS 26.
- **Modular design** – Glass effects, button styles, transitions, and previews live in focused files

---

## Known Issues

- On pre-OS 26 systems the fallback `UniversalGlassEffectContainer` ignores the public `spacing` parameter; a fix is planned.

---

## Installation

Add UniversalGlass to your Package.swift dependencies:

```swift
.package(url: "https://github.com/Aeastr/UniversalGlass.git", branch: "main")
```

Then add the target to any product that needs it:

```swift
    dependencies: [
        .product(name: "UniversalGlass", package: "UniversalGlass")
    ]
```

Need the optional shorthand APIs (`.glass`, `.glassEffect`, etc.)? Add the backport module too:

```swift
    dependencies: [
        .product(name: "UniversalGlass", package: "UniversalGlass"),
        .product(name: "UniversalGlassBackports", package: "UniversalGlass")
    ]
```

---

## Usage

### Glass Effects

```swift
import UniversalGlass
// import UniversalGlassBackports if you prefer the native names

struct Card: View {
    var body: some View {
        Text("Cosmic Glass")
            .font(.headline)
            .padding(.horizontal, 36)
            .padding(.vertical, 18)
            .universalGlassEffect(.regular.tint(.purple))
            .padding()
            .background(
                LinearGradient(
                    colors: [.black, .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
```

Need a custom shape?

```swift
Circle()
    .frame(width: 120, height: 120)
    .universalGlassEffect(in: Circle())
```

### Glass Button Styles

```swift
Button("Join Beta") {
    // action
}
.tint(.pink)
.controlSize(.large)
.buttonStyle(
    .universalGlassProminent()
)
```

Legacy fallbacks apply a capsule material with tint-aware highlights, drop shadow, and press animations

### Effect Containers & Morphing

```swift
@Namespace private var glassNamespace

UniversalGlassEffectContainer(spacing: 24) {
    HStack(spacing: 16) {
        AvatarView()
            .universalGlassEffect()
            .universalGlassEffectUnion(id: "profile", namespace: glassNamespace)

        DetailsView()
            .universalGlassEffect()
            .universalGlassEffectTransition(.matchedGeometry)
    }
}
```

When a runtime supports `GlassEffectContainer` or `glassEffectTransition`, UniversalGlass forwards automatically; otherwise it falls back to material and blur transitions.

### Transitions

```swift
@State private var showSettings = false

VStack {
    if showSettings {
        SettingsPanel()
            .transition(.blurSmooth)
    }

    Toggle("Show Settings", isOn: $showSettings)
        .universalGlassButtonStyle()
}
.animation(.easeInOut(duration: 0.3), value: showSettings)
```

### Opt-in Backports

```swift
import UniversalGlassBackports

Button("RSVP") {}
    .buttonStyle(.glassProminent)

CardView()
    .glassEffect(.regular.tint(.mint))
```

SwiftUI’s real implementations automatically replace these extensions when available.

---

## Contributing

Contributions are welcome—bug reports, feature proposals, docs, or polish. Before submitting a PR, please:

1. Create an issue outlining the change (optional for small fixes).
2. Follow the existing Swift formatting and file organisation.
3. Ensure `swift build` succeeds and add previews/tests where relevant.

---

## Support

If UniversalGlass helps your project, consider starring the repo or sharing it with your team. Feedback, ideas, and issues are all appreciated!

---

## Where to find me  
- here, obviously.  
- [Twitter](https://x.com/AetherAurelia)  
- [Threads](https://www.threads.net/@aetheraurelia)  
- [Bluesky](https://bsky.app/profile/aethers.world)  
- [LinkedIn](https://www.linkedin.com/in/willjones24)

---

<p align="center">Built with 🍏💦🔍 by Aether</p>
