![release 1.0.0](https://badgen.net/badge/release/1.0.0/pink)
![iOS 15](https://badgen.net/badge/platform/iOS%2015/blue?icon=apple)
![SwiftUI 3](https://badgen.net/badge/SwiftUI/3/cyan)
![Swift 5.5](https://badgen.net/badge/Swift/5.5/orange)
![MIT licence](https://badgen.net/badge/license/MIT/green)
![331kb](https://badgen.net/badge/small/331kb/yellow)

# AnimatedWaveform

`AnimatedWaveform` is a Swift Package designed for SwiftUI.

It provides the user with an animated version of the `waveform.circle` SF Symbol.

![animated example](/resources/example.gif)

## Installation

Use the package dependency tab in your Xcode project to add AnimatedWaveform to your project via the url https://github.com/Wavemaster111188/AnimatedWaveform.

## Usage

```swift
// basic version (using the .accentColor)
AnimatedWaveformView()
    .scaledToFit()

// with a custom color
AnimatedWaveformView(color: .mint)
    .scaledToFit()

// render the AnimatedWaveform with a slightly lighter ring, using the renderingMode hierarchical
AnimatedWaveformView(color: .purple, renderingMode: .hierarchical)
    .scaledToFit()

// render the AnimatedWaveform with custom colors, using the renderingMode palette
AnimatedWaveformView(color: .green, renderingMode: .palette, secondaryColor: .yellow)
    .scaledToFit()

// render the AnimatedWaveform without animation
AnimatedWaveformView(animated: false)
    .scaledToFit()
```

All parameters can be mixed and matched.

> Note: it's neccessary to add the `.scaledToFit()` modifier to make the wave form work properly.

## Contributing
Pull requests are always welcome.

## Author
Kevin Deffke

## License
[MIT](https://choosealicense.com/licenses/mit/)
