//
//  AnimatedWaveform.swift
//  AnimatedWaveform
//
//  Created by Kevin Deffke on 09.01.22.
//

import SwiftUI

// MARK: - AnimatedWaveformView

/// An animated version of the `waveform.circle` SF Symbol.
///
/// The view is intrinsically square: it fits itself into whatever space it is
/// offered, so there is no need to add `scaledToFit()` at the call site.
///
/// ```swift
/// AnimatedWaveformView(style: .mint)
/// ```
///
/// Any `ShapeStyle` works, so the waveform can be drawn with a gradient or a
/// material just as easily as with a color.
///
/// When the *Reduce Motion* accessibility setting is on, the waveform is drawn
/// in its resting state instead of animating.
///
/// - Note: Shapes are not accessibility elements, so the waveform is invisible
///   to assistive technologies. If it conveys information — a recording state,
///   for example — add an `accessibilityLabel(_:)` where you use it.
public struct AnimatedWaveformView: View {

    /// Determines how the ring is styled relative to the bars.
    ///
    /// Modelling this as a value with factory methods rather than a plain enum
    /// keeps the secondary style attached to the one mode that uses it, so a
    /// secondary style without ``palette(secondary:)`` — or the other way
    /// around — cannot be expressed.
    public struct RenderingMode: Sendable {

        enum Kind: Sendable {
            case hierarchical
            case monochrome
            case palette(AnyShapeStyle)
        }

        let kind: Kind

        private init(_ kind: Kind) {
            self.kind = kind
        }

        /// The ring uses a dimmed version of the bar style.
        public static let hierarchical = RenderingMode(.hierarchical)

        /// Ring and bars use the same style.
        public static let monochrome = RenderingMode(.monochrome)

        /// The ring uses `secondary` while the bars keep the primary style.
        public static func palette(secondary: some ShapeStyle) -> RenderingMode {
            RenderingMode(.palette(AnyShapeStyle(secondary)))
        }

        /// The style the ring uses, or `nil` when it follows the bar style.
        var secondaryStyle: AnyShapeStyle? {
            switch kind {
            case .hierarchical, .monochrome: nil
            case .palette(let style): style
            }
        }

        /// How much of the ring shows through, dimming it for ``hierarchical``.
        var ringOpacity: Double {
            switch kind {
            case .hierarchical: 0.5
            case .monochrome, .palette: 1
            }
        }
    }

    private let style: AnyShapeStyle
    private let renderingMode: RenderingMode
    private let animated: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates an animated waveform.
    ///
    /// - Parameters:
    ///   - style: The style of the bars, and of the ring in every rendering mode
    ///     but ``RenderingMode/palette(secondary:)``. Defaults to the current tint.
    ///   - renderingMode: How the ring is styled relative to the bars.
    ///     Defaults to ``RenderingMode/monochrome``.
    ///   - animated: Whether the bars animate. Defaults to `true`.
    public init(
        style: some ShapeStyle = .tint,
        renderingMode: RenderingMode = .monochrome,
        animated: Bool = true
    ) {
        self.style = AnyShapeStyle(style)
        self.renderingMode = renderingMode
        self.animated = animated
    }

    /// The style the ring is drawn with: the secondary style when the rendering
    /// mode supplies one, otherwise the bar style.
    var ringStyle: AnyShapeStyle {
        renderingMode.secondaryStyle ?? style
    }

    /// The states the waveform cycles through, back to front and around again.
    static let phases: [BarLengths] = [.resting, .active]

    /// How long a single leg of the animation takes. Cycling two phases at this
    /// duration matches the 1.4s round trip of an auto-reversing animation.
    static let phaseDuration = 0.7

    /// Whether the bars should be moving, honouring the *Reduce Motion* setting.
    private var isAnimating: Bool {
        animated && !reduceMotion
    }

    public var body: some View {
        GeometryReader { geometry in
            // Everything is measured against the side length so the waveform
            // scales as a whole instead of mixing in fixed point values.
            let side = min(geometry.size.width, geometry.size.height)
            let barLineWidth = side / 16

            ZStack {
                Circle()
                    .strokeBorder(ringStyle, lineWidth: barLineWidth + side / 50)
                    .opacity(renderingMode.ringOpacity)

                bars(lineWidth: barLineWidth)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// The bars, cycling through ``phases`` for as long as the view exists.
    ///
    /// When motion is off, the `PhaseAnimator` is left out of the hierarchy
    /// altogether rather than handed a `nil` animation — a phase animator with
    /// nothing to animate races through its phases instead of holding still.
    /// Adding and removing it also restarts the cycle cleanly whenever
    /// `animated` or *Reduce Motion* changes.
    @ViewBuilder
    private func bars(lineWidth: CGFloat) -> some View {
        if isAnimating {
            PhaseAnimator(Self.phases) { lengths in
                barShape(lengths, lineWidth: lineWidth)
            } animation: { _ in
                .linear(duration: Self.phaseDuration)
            }
        } else {
            barShape(.resting, lineWidth: lineWidth)
        }
    }

    private func barShape(_ lengths: BarLengths, lineWidth: CGFloat) -> some View {
        WaveformBars(lengths: lengths)
            .stroke(style, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}

// MARK: - WaveformBars

/// The vertical bars of the waveform.
///
/// The bars are laid out inside the largest square that fits the rectangle, so
/// they stay aligned with the circular ring even when handed a non-square one.
struct WaveformBars: Shape {

    var lengths: BarLengths

    var animatableData: BarLengths {
        get { lengths }
        set { lengths = newValue }
    }

    /// How far a bar may reach from the centre, in percent of the side length.
    /// Keeps the bars clear of the ring if an animation ever overshoots.
    static let maximumLength: CGFloat = 40

    func path(in rect: CGRect) -> Path {
        let values = lengths.values
        guard !values.isEmpty else { return Path() }

        let side = min(rect.width, rect.height)
        let unit = side / 100
        // For the six default bars this works out to 25%, 35% … 75% of the side
        // length, matching the proportions of the `waveform.circle` symbol.
        let spacing = 60 / CGFloat(values.count)
        let firstOffset = 50 - spacing * CGFloat(values.count - 1) / 2

        return Path { path in
            for (index, length) in values.enumerated() {
                let x = rect.midX - side / 2 + unit * (firstOffset + spacing * CGFloat(index))
                let reach = unit * min(max(length, 0), Self.maximumLength)
                path.move(to: CGPoint(x: x, y: rect.midY - reach))
                path.addLine(to: CGPoint(x: x, y: rect.midY + reach))
            }
        }
    }
}

// MARK: - BarLengths

/// The half-heights of the waveform bars, in percent of the view's side length.
///
/// Conforming to `VectorArithmetic` lets SwiftUI interpolate every bar
/// independently for any number of bars, without the nested `AnimatablePair`
/// tree a fixed-size layout would otherwise need. It also makes the type usable
/// as a `PhaseAnimator` phase, since `AdditiveArithmetic` implies `Equatable`.
struct BarLengths: VectorArithmetic, Sendable {

    /// The bar half-heights, from left to right.
    var values: [CGFloat]

    init(_ values: [CGFloat]) {
        self.values = values
    }

    /// The state the waveform rests in, chosen to match the `waveform.circle`
    /// SF Symbol.
    static let resting = BarLengths([5, 20, 30, 15, 25, 10])

    /// The state the waveform animates towards.
    static let active = BarLengths([20, 10, 2, 25, 10, 2])

    // MARK: - AdditiveArithmetic

    static let zero = BarLengths([])

    static func + (lhs: BarLengths, rhs: BarLengths) -> BarLengths {
        combine(lhs, rhs, +)
    }

    static func - (lhs: BarLengths, rhs: BarLengths) -> BarLengths {
        combine(lhs, rhs, -)
    }

    /// Applies `operation` element by element, padding the shorter operand with
    /// zeroes so that `zero` — which carries no bars at all — acts as an identity.
    private static func combine(
        _ lhs: BarLengths,
        _ rhs: BarLengths,
        _ operation: (CGFloat, CGFloat) -> CGFloat
    ) -> BarLengths {
        let count = max(lhs.values.count, rhs.values.count)
        return BarLengths((0..<count).map { index in
            operation(lhs.value(at: index), rhs.value(at: index))
        })
    }

    private func value(at index: Int) -> CGFloat {
        index < values.count ? values[index] : 0
    }

    // MARK: - VectorArithmetic

    mutating func scale(by rhs: Double) {
        for index in values.indices {
            values[index] *= CGFloat(rhs)
        }
    }

    var magnitudeSquared: Double {
        values.reduce(into: 0) { $0 += Double($1 * $1) }
    }
}

// MARK: - Previews

#Preview("Rendering modes") {
    HStack {
        // basic version (using the current tint)
        AnimatedWaveformView()

        // with a custom color
        AnimatedWaveformView(style: .mint)

        // a dimmed ring, using the renderingMode hierarchical
        AnimatedWaveformView(style: .purple, renderingMode: .hierarchical)

        // a separate ring style, using the renderingMode palette
        AnimatedWaveformView(style: .green, renderingMode: .palette(secondary: .yellow))

        // any ShapeStyle works, not just colors
        AnimatedWaveformView(
            style: .linearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
        )

        // without animation
        AnimatedWaveformView(animated: false)
    }
    .padding()
}

#Preview("Sizes") {
    // Every measurement scales with the view, so the ring keeps its proportions
    // at any size — and no `scaledToFit()` is needed to get a square.
    HStack(alignment: .center) {
        AnimatedWaveformView(style: .mint)
            .frame(width: 24)

        AnimatedWaveformView(style: .mint)
            .frame(width: 64)

        AnimatedWaveformView(style: .mint)
            .frame(width: 160)
    }
    .padding()
}
