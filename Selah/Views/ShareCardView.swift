import SwiftUI

// MARK: - Shareable verse cards — the viral engine.
// Generates an aesthetic 1080×1920 story-format image entirely on-device
// with ImageRenderer, watermarked "Selah", ready for IG stories / TikTok.

struct ShareCardSheet: View {
    let verse: Verse
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var style: CardStyle = .dusk
    @State private var rendered: UIImage?

    enum CardStyle: String, CaseIterable, Identifiable {
        case dusk, cream, bronze
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(spacing: 20) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5).padding(.top, 14)
                Text("Share the word")
                    .font(.display(24))
                    .foregroundStyle(Palette.ink)

                VerseCard(verse: verse, style: style)
                    .frame(width: 250, height: 444)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: Palette.espresso.opacity(0.25), radius: 24, y: 12)

                HStack(spacing: 8) {
                    ForEach(CardStyle.allCases) { s in
                        Button {
                            Haptics.soft(); style = s
                        } label: {
                            PillChip(text: s.title, selected: style == s)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let rendered {
                    ShareLink(
                        item: Image(uiImage: rendered),
                        preview: SharePreview(verse.reference, image: Image(uiImage: rendered))
                    ) {
                        Text("Share to Story")
                            .font(.label(16, weight: .semibold))
                            .foregroundStyle(Palette.onInk)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.ink) }
                    }
                    .simultaneousGesture(TapGesture().onEnded { Haptics.success() })
                    .padding(.horizontal, 24)
                }

                Button("Done") { dismiss() }
                    .font(.label(14, weight: .medium))
                    .foregroundStyle(Palette.mocha)
                    .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .onAppear { render() }
        .onChange(of: style) { _, _ in render() }
    }

    @MainActor
    private func render() {
        let renderer = ImageRenderer(content: VerseCard(verse: verse, style: style).frame(width: 540, height: 960))
        renderer.scale = 2
        rendered = renderer.uiImage
    }
}

struct VerseCard: View {
    let verse: Verse
    var style: ShareCardSheet.CardStyle

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "sparkle")
                    .font(.system(size: 20))
                    .foregroundStyle(accent)
                Spacer().frame(height: 28)
                Text("“\(verse.text)”")
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(9)
                    .foregroundStyle(primary)
                    .minimumScaleFactor(0.55)
                    .padding(.horizontal, 44)
                Spacer().frame(height: 26)
                Text(verse.reference.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .kerning(2.5)
                    .foregroundStyle(accent)
                Spacer()
                Text("SELAH")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .kerning(5)
                    .foregroundStyle(primary.opacity(0.45))
                    .padding(.bottom, 36)
            }
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .dusk:
            LinearGradient(colors: [Color(hex: 0x402F22), Color(hex: 0x2C1F16)],
                           startPoint: .top, endPoint: .bottom)
        case .cream:
            ZStack {
                Palette.cream
                Circle().fill(Color(hex: 0xE8D5C0).opacity(0.7)).frame(width: 420).blur(radius: 80).offset(y: -280)
                Circle().fill(Palette.sand.opacity(0.5)).frame(width: 400).blur(radius: 90).offset(y: 320)
            }
        case .bronze:
            LinearGradient(colors: [Palette.bronze, Color(hex: 0x7A5C43)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var primary: Color {
        style == .cream ? Palette.espresso : Palette.cream
    }
    private var accent: Color {
        style == .cream ? Palette.bronze : Palette.sand
    }
}
