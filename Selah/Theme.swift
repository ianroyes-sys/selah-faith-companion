import SwiftUI
import UIKit

// MARK: - Selah Design System — "Quiet Luxury"
// Light: warm cream, taupe, mocha, espresso, brushed bronze.
// Dark: deep espresso canvas with lighter mocha-brown module surfaces.
// Editorial serif display type over calm sans body.

enum Palette {
    // Fixed tones — identical in both appearances.
    static let cream      = Color(hex: 0xF7F2EA)   // light text / fills on dark surfaces
    static let sand       = Color(hex: 0xD9C6AC)   // soft fills, secondary text on dark
    static let espresso   = Color(hex: 0x33241A)   // fixed dark fills / shadows
    static let bronze     = Color(hex: 0xB08347)   // brand accent
    static let sage       = Color(hex: 0x8A9080)   // quiet secondary accent

    // Adaptive tones — light appearance / dark appearance.
    static let canvas     = dynamic(0xF7F2EA, 0x33241A)   // app background
    static let linen      = dynamic(0xEFE7DA, 0xB49B7F)   // module / pill fill (tan in dark)
    static let onLinen    = Color(hex: 0x33241A)           // primary content on linen (fixed dark)
    static let onLinenSoft = Color(hex: 0x3E2A1B)          // secondary content on linen (fixed dark for legibility)
    static let taupe      = dynamic(0xB49B7F, 0xC2A886)   // muted accents
    static let mocha      = dynamic(0x7A5C43, 0xCBB093)   // secondary text / icons
    static let blush      = dynamic(0xE8D5C0, 0x5A4433)   // warm highlight
    static let deepBrown  = dynamic(0x402F22, 0x4A382A)   // dark hero surfaces
    static let nightBrown = dynamic(0x2C1F16, 0x3B2C20)   // darkest hero surface
    static let ink        = dynamic(0x33241A, 0xF3EBDF)   // primary text
    static let onInk      = dynamic(0xF7F2EA, 0x33241A)   // text on ink-filled controls
    static let tabBar     = dynamic(0x33241A, 0x231711)   // floating pill nav
    static let glow       = dynamic(0xD9C6AC, 0x46352A)   // background blur accent

    /// Text-field surface: translucent white in light, faint glass in dark.
    static let field = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.08)
            : UIColor(white: 1, alpha: 0.7)
    })

    private static func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Appearance

enum Appearance: String, CaseIterable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
    var title: String { rawValue.capitalized }
}

// MARK: - Typography

extension Font {
    /// Large all-caps editorial headline, like "DISCOVER NEW LUXURY".
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
    static func scripture(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func label(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

struct EditorialCaps: ViewModifier {
    var size: CGFloat
    var color: Color
    func body(content: Content) -> some View {
        content
            .font(.display(size))
            .textCase(.uppercase)
            .kerning(size * 0.06)
            .foregroundStyle(color)
    }
}

extension View {
    func editorialCaps(_ size: CGFloat, color: Color = Palette.ink) -> some View {
        modifier(EditorialCaps(size: size, color: color))
    }
}

// MARK: - Surfaces

struct GlassCard: ViewModifier {
    var corner: CGFloat = 28
    var tint: Color = .white.opacity(0.55)
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(scheme == .dark ? Color.white.opacity(0.07) : tint)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .strokeBorder(.white.opacity(scheme == .dark ? 0.1 : 0.5), lineWidth: 1)
                    }
                    .shadow(color: Palette.espresso.opacity(0.07), radius: 18, y: 8)
            }
    }
}

struct SolidCard: ViewModifier {
    var corner: CGFloat = 28
    var fill: Color = Palette.linen
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(fill)
                    .shadow(color: Palette.espresso.opacity(0.06), radius: 14, y: 6)
            }
    }
}

extension View {
    func glassCard(corner: CGFloat = 28, tint: Color = .white.opacity(0.55)) -> some View {
        modifier(GlassCard(corner: corner, tint: tint))
    }
    func solidCard(corner: CGFloat = 28, fill: Color = Palette.linen) -> some View {
        modifier(SolidCard(corner: corner, fill: fill))
    }
}

/// Tall arch-shaped card silhouette used for reading plans, echoing the
/// rounded arch imagery in the reference design.
struct ArchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = rect.width / 2
        let bottomCorner: CGFloat = min(28, r * 0.5)
        p.move(to: CGPoint(x: 0, y: rect.maxY - bottomCorner))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addArc(center: CGPoint(x: r, y: r), radius: r,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomCorner))
        p.addArc(center: CGPoint(x: rect.maxX - bottomCorner, y: rect.maxY - bottomCorner),
                 radius: bottomCorner, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: bottomCorner, y: rect.maxY))
        p.addArc(center: CGPoint(x: bottomCorner, y: rect.maxY - bottomCorner),
                 radius: bottomCorner, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.closeSubpath()
        return p
    }
}

// MARK: - Buttons

struct BronzeButtonStyle: ButtonStyle {
    var prominent = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.label(16, weight: .semibold))
            .foregroundStyle(prominent ? Palette.onInk : Palette.ink)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background {
                Capsule().fill(prominent ? Palette.ink : Palette.sand.opacity(0.5))
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PillChip: View {
    var text: String
    var selected: Bool
    var body: some View {
        Text(text)
            .font(.label(13, weight: selected ? .semibold : .medium))
            .foregroundStyle(selected ? Palette.onInk : Palette.onLinenSoft)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background {
                Capsule().fill(selected ? Palette.ink : Palette.linen)
                    .overlay { Capsule().strokeBorder(Palette.sand.opacity(selected ? 0 : 0.5), lineWidth: 1) }
            }
    }
}

// MARK: - Haptics

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func soft() { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
}

// MARK: - Backgrounds

/// The warm layered background used across the app —
/// cream in light appearance, deep espresso brown in dark.
struct SelahBackground: View {
    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            Circle()
                .fill(Palette.blush.opacity(0.55))
                .frame(width: 420)
                .blur(radius: 90)
                .offset(x: -140, y: -320)
            Circle()
                .fill(Palette.glow.opacity(0.4))
                .frame(width: 380)
                .blur(radius: 100)
                .offset(x: 170, y: 320)
        }
    }
}

/// Dark mocha hero background (evening / sleep / paywall surfaces).
struct DuskBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            Circle()
                .fill(Palette.bronze.opacity(0.22))
                .frame(width: 400)
                .blur(radius: 110)
                .offset(x: 120, y: -260)
        }
    }
}
