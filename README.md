![Latest release: 2.0.0](https://badgen.net/badge/release/2.0.0/pink)
![Supported platforms: iOS 17, macOS 14, tvOS 17, watchOS 10 and visionOS 1](https://badgen.net/badge/platforms/iOS%2017%20|%20macOS%2014%20|%20tvOS%2017%20|%20watchOS%2010%20|%20visionOS%201/blue?icon=apple)
![Written in Swift 6](https://badgen.net/badge/Swift/6/orange)
![Released under the MIT licence](https://badgen.net/badge/license/MIT/green)

# AnimatedWaveform

`AnimatedWaveform` is a Swift Package designed for SwiftUI.

It provides the user with an animated version of the `waveform.circle` SF Symbol.

![A circle with six vertical bars inside it, animating up and down like an audio level meter](/resources/example.gif)

## Requirements

iOS 17, macOS 14, tvOS 17, watchOS 10 or visionOS 1, built with Xcode 16 or later. The package has no dependencies.

If you need to support iOS 15 or 16, use the [1.x releases](https://github.com/Wavemaster111188/AnimatedWaveform/releases).

## Migrating from 1.x

`color` became `style` and now accepts any `ShapeStyle`. The separate `secondaryColor` parameter is gone — the secondary style is attached to the one rendering mode that uses it, so it can no longer be passed to a mode that ignores it.

| 1.x | 2.0 |
| --- | --- |
| `AnimatedWaveformView()` | `AnimatedWaveformView()` |
| `AnimatedWaveformView(color: .mint)` | `AnimatedWaveformView(style: .mint)` |
| `AnimatedWaveformView(color: .purple, renderingMode: .hierarchical)` | `AnimatedWaveformView(style: .purple, renderingMode: .hierarchical)` |
| `AnimatedWaveformView(color: .green, renderingMode: .palette, secondaryColor: .yellow)` | `AnimatedWaveformView(style: .green, renderingMode: .palette(secondary: .yellow))` |
| `AnimatedWaveformView(animated: false)` | `AnimatedWaveformView(animated: false)` |

The default style changed from `Color.accentColor` to `ShapeStyle.tint`. Both follow the tint you set with `tint(_:)`, so this is only visible if you were setting the accent color through `UIView.appearance` or an asset catalog `AccentColor` without a corresponding tint.

## Installation

Use the package dependency tab in your Xcode project to add AnimatedWaveform to your project via the url https://github.com/Wavemaster111188/AnimatedWaveform.

## Usage

```swift
// basic version (using the current tint)
AnimatedWaveformView()

// with a custom color
AnimatedWaveformView(style: .mint)

// render the AnimatedWaveform with a dimmed ring, using the renderingMode hierarchical
AnimatedWaveformView(style: .purple, renderingMode: .hierarchical)

// render the AnimatedWaveform with a separate ring style, using the renderingMode palette
AnimatedWaveformView(style: .green, renderingMode: .palette(secondary: .yellow))

// render the AnimatedWaveform without animation
AnimatedWaveformView(animated: false)
```

All parameters can be mixed and matched.

`style` takes any `ShapeStyle`, so gradients and materials work just as well as colors:

```swift
AnimatedWaveformView(
    style: .linearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
)
```

The view is square by itself and fits into whatever space it is offered, so give it a `frame` — or let its container size it — and it keeps its proportions at any size:

```swift
AnimatedWaveformView(color: .mint)
    .frame(width: 44)
```

## Accessibility

The waveform stops moving when the *Reduce Motion* accessibility setting is on, and is drawn in its resting state instead.

Shapes are not accessibility elements, so the waveform is invisible to assistive technologies. That is the right default for decoration, but if the waveform conveys information — a recording state, for example — describe it where you use it:

```swift
AnimatedWaveformView()
    .accessibilityLabel("Recording")
```

## Contributing
Pull requests are always welcome.

## Author
Kevin Deffke

## License
[MIT](https://choosealicense.com/licenses/mit/)
