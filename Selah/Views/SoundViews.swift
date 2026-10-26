import SwiftUI

// MARK: - Selah Sound views — your faith, in your genre.

// MARK: Today card

struct SoundtrackCard: View {
    @EnvironmentObject var store: UserStore
    @State private var showSound = false
    @AppStorage("selah.vibes") private var vibesRaw: String = ""

    private var vibes: [Vibe] { MusicLibrary.savedVibes() }

    private var lead: Song? {
        MusicLibrary.soundtrack(vibes: vibes, mood: store.todayMood, count: 1).first
    }

    var body: some View {
        Button {
            Haptics.tap(); showSound = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(
                            colors: (vibes.first?.gradient ?? [0xB08347, 0x7A5C43]).map { Color(hex: $0) },
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "music.note")
                        .font(.system(size: 18))
                        .foregroundStyle(Palette.cream)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(vibesRaw.isEmpty ? "Find your sound" : "Today's soundtrack")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    if vibesRaw.isEmpty {
                        Text("Christian music in the genres you actually play")
                            .font(.label(12))
                            .foregroundStyle(Palette.mocha)
                            .lineLimit(1)
                    } else if let lead {
                        Text("\(lead.title) — \(lead.artist)")
                            .font(.label(12))
                            .foregroundStyle(Palette.mocha)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.bronze)
            }
            .padding(16)
            .glassCard(corner: 26)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSound) { SoundSheet() }
    }
}

// MARK: Full sheet

struct SoundSheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selah.vibes") private var vibesRaw: String = ""
    @State private var browsing: Vibe?

    private var vibes: [Vibe] { MusicLibrary.savedVibes() }
    private var picking: Bool { vibes.isEmpty }

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)

                    if picking {
                        VibePicker()
                    } else {
                        soundtrackSection
                        browseSection
                        retuneRow
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .sheet(item: $browsing) { vibe in VibeBrowseSheet(vibe: vibe) }
    }

    private var soundtrackSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's soundtrack".uppercased())
                    .font(.label(10, weight: .semibold))
                    .kerning(1.4)
                    .foregroundStyle(Palette.mocha)
                Text(store.todayMood.map { "For a \($0.rawValue) heart" } ?? "For today")
                    .font(.display(28))
                    .foregroundStyle(Palette.ink)
                Text("Five songs from your vibes, retuned every morning\(store.todayMood != nil ? " to match your check-in" : "").")
                    .font(.label(13))
                    .foregroundStyle(Palette.mocha)
            }
            ForEach(MusicLibrary.soundtrack(vibes: vibes, mood: store.todayMood)) { song in
                SongRow(song: song)
            }
            ShareLink(item: shareText) {
                Label("Share today's mix", systemImage: "square.and.arrow.up")
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(Palette.onInk)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background { Capsule().fill(Palette.ink) }
            }
        }
    }

    private var shareText: String {
        let mix = MusicLibrary.soundtrack(vibes: vibes, mood: store.todayMood)
            .map { "• \($0.title) — \($0.artist)" }
            .joined(separator: "\n")
        let moodLine = store.todayMood.map { " for a \($0.rawValue) heart" } ?? ""
        return "My Selah soundtrack\(moodLine):\n\(mix)\n\nGet yours: https://selah.app"
    }

    private var browseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Browse by vibe")
                .font(.display(20))
                .foregroundStyle(Palette.ink)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                ForEach(Vibe.allCases) { vibe in
                    Button {
                        Haptics.tap(); browsing = vibe
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: vibe.symbol)
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(Palette.cream)
                            Spacer()
                            Text(vibe.title)
                                .font(.label(14, weight: .semibold))
                                .foregroundStyle(Palette.cream)
                                .multilineTextAlignment(.leading)
                            Text(vibe.tagline)
                                .font(.label(10))
                                .foregroundStyle(Palette.cream.opacity(0.75))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(LinearGradient(colors: vibe.gradient.map { Color(hex: $0) },
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var retuneRow: some View {
        Button {
            Haptics.tap()
            vibesRaw = ""
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                Text("Retune my vibes")
            }
            .font(.label(13, weight: .medium))
            .foregroundStyle(Palette.mocha)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Vibe picker (first run)

struct VibePicker: View {
    @AppStorage("selah.vibes") private var vibesRaw: String = ""
    @State private var chosen: Set<Vibe> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("What's your\nsound?")
                .font(.display(34))
                .foregroundStyle(Palette.ink)
            Text("Pick up to three. Selah builds your daily soundtrack from the genres you actually play — matched to how your heart is that morning.")
                .font(.label(14))
                .lineSpacing(4)
                .foregroundStyle(Palette.mocha)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                ForEach(Vibe.allCases) { vibe in
                    Button {
                        Haptics.soft()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            if chosen.contains(vibe) {
                                chosen.remove(vibe)
                            } else if chosen.count < 3 {
                                chosen.insert(vibe)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: vibe.symbol)
                                    .font(.system(size: 18, weight: .light))
                                Spacer()
                                if chosen.contains(vibe) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                }
                            }
                            .foregroundStyle(Palette.cream)
                            Spacer()
                            Text(vibe.title)
                                .font(.label(14, weight: .semibold))
                                .foregroundStyle(Palette.cream)
                                .multilineTextAlignment(.leading)
                            Text(vibe.tagline)
                                .font(.label(10))
                                .foregroundStyle(Palette.cream.opacity(0.75))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(LinearGradient(colors: vibe.gradient.map { Color(hex: $0) },
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .strokeBorder(Palette.cream.opacity(chosen.contains(vibe) ? 0.9 : 0), lineWidth: 2)
                                }
                        }
                        .scaleEffect(chosen.contains(vibe) ? 1.02 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                Haptics.success()
                MusicLibrary.saveVibes(Array(chosen))
                vibesRaw = UserDefaults.standard.string(forKey: "selah.vibes") ?? ""
            } label: {
                Text(chosen.isEmpty ? "Pick at least one" : "Build my soundtrack")
            }
            .buttonStyle(BronzeButtonStyle())
            .disabled(chosen.isEmpty)
            .opacity(chosen.isEmpty ? 0.5 : 1)
        }
    }
}

// MARK: Vibe browse sheet

struct VibeBrowseSheet: View {
    let vibe: Vibe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(LinearGradient(colors: vibe.gradient.map { Color(hex: $0) },
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 64, height: 64)
                            Image(systemName: vibe.symbol)
                                .font(.system(size: 24, weight: .light))
                                .foregroundStyle(Palette.cream)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vibe.title)
                                .font(.display(26))
                                .foregroundStyle(Palette.ink)
                            Text(vibe.tagline)
                                .font(.label(13))
                                .foregroundStyle(Palette.mocha)
                        }
                    }
                    ForEach(MusicLibrary.songs(for: vibe)) { song in
                        SongRow(song: song)
                    }
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}

// MARK: Song row

struct SongRow: View {
    let song: Song
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(LinearGradient(
                        colors: (song.vibes.first?.gradient ?? [0xB08347, 0x7A5C43]).map { Color(hex: $0) },
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 46, height: 46)
                Image(systemName: "music.note")
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.cream)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.label(12))
                    .foregroundStyle(Palette.mocha)
                    .lineLimit(1)
            }
            Spacer()
            Button {
                Haptics.tap(); openURL(song.appleMusicURL)
            } label: {
                Image(systemName: "applelogo")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.onLinen)
                    .frame(width: 34, height: 34)
                    .background { Circle().fill(Palette.linen) }
            }
            .buttonStyle(.plain)
            Button {
                Haptics.tap(); openURL(song.spotifyURL)
            } label: {
                Image(systemName: "waveform")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.onLinen)
                    .frame(width: 34, height: 34)
                    .background { Circle().fill(Palette.linen) }
            }
            .buttonStyle(.plain)
        }
        .padding(13)
        .glassCard(corner: 22)
    }
}
