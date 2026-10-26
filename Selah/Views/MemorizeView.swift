import SwiftUI

// MARK: - Verse memorization — spaced repetition, "hide it in your heart".
// Free: 3 verses in the deck. Selah+: unlimited.

struct MemorizeSection: View {
    @EnvironmentObject var store: UserStore
    @State private var practicing = false
    @State private var picking = false
    @State private var showPaywall = false

    static let freeDeckLimit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Hide it in your heart")
                    .font(.display(20))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Button {
                    Haptics.tap()
                    if !store.isPremium && store.memoryDeck.count >= Self.freeDeckLimit {
                        showPaywall = true
                    } else {
                        picking = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.onLinen)
                        .frame(width: 34, height: 34)
                        .background { Circle().fill(Palette.linen) }
                }
                .buttonStyle(.plain)
            }

            if store.memoryDeck.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "brain")
                        .font(.system(size: 20))
                        .foregroundStyle(Palette.bronze)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Memorize your first verse")
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Text("Spaced repetition keeps it with you for life")
                            .font(.label(12))
                            .foregroundStyle(Palette.mocha)
                    }
                    Spacer()
                }
                .padding(18)
                .glassCard(corner: 24)
                .onTapGesture { picking = true }
            } else {
                Button {
                    Haptics.tap(); practicing = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Palette.ink).frame(width: 46, height: 46)
                            Text("\(store.dueDeckVerses.count)")
                                .font(.label(16, weight: .bold))
                                .foregroundStyle(Palette.onInk)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.dueDeckVerses.isEmpty ? "All caught up" : "Verses due for review")
                                .font(.label(15, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                            Text("\(store.memoryDeck.count) in your deck")
                                .font(.label(12))
                                .foregroundStyle(Palette.mocha)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Palette.mocha)
                    }
                    .padding(16)
                    .glassCard(corner: 24)
                }
                .buttonStyle(.plain)
                .disabled(store.dueDeckVerses.isEmpty)
            }
        }
        .sheet(isPresented: $practicing) { PracticeSheet() }
        .sheet(isPresented: $picking) { VersePicker() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }
}

// MARK: Pick a verse to memorize

struct VersePicker: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    Text("Choose a verse")
                        .font(.display(26))
                        .foregroundStyle(Palette.ink)
                    ForEach(ContentLibrary.verses.prefix(20)) { v in
                        let inDeck = store.memoryDeck.contains { $0.reference == v.reference }
                        Button {
                            guard !inDeck else { return }
                            Haptics.success()
                            store.addToDeck(v)
                            dismiss()
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(v.reference)
                                        .font(.label(14, weight: .semibold))
                                        .foregroundStyle(Palette.ink)
                                    Text(v.text)
                                        .font(.label(12))
                                        .foregroundStyle(Palette.mocha)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: inDeck ? "checkmark.circle.fill" : "plus.circle")
                                    .foregroundStyle(inDeck ? Palette.sage : Palette.bronze)
                            }
                            .padding(14)
                            .glassCard(corner: 20)
                        }
                        .buttonStyle(.plain)
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

// MARK: Practice flow

struct PracticeSheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var revealed = false

    private var due: [MemoryVerse] { store.dueDeckVerses }

    var body: some View {
        ZStack {
            DuskBackground()
            if index < due.count {
                let verse = due[index]
                VStack(spacing: 0) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5).padding(.top, 14)
                    Spacer()
                    Text(verse.reference.uppercased())
                        .font(.label(13, weight: .semibold))
                        .kerning(2)
                        .foregroundStyle(Palette.bronze)
                    Spacer().frame(height: 26)

                    if revealed {
                        Text("“\(verse.text)”")
                            .font(.scripture(24))
                            .multilineTextAlignment(.center)
                            .lineSpacing(7)
                            .foregroundStyle(Palette.cream)
                            .padding(.horizontal, 36)
                            .transition(.opacity)
                    } else {
                        Text(firstLetters(of: verse.text))
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .foregroundStyle(Palette.sand)
                            .padding(.horizontal, 36)
                        Spacer().frame(height: 16)
                        Text("Say it out loud from the first letters")
                            .font(.label(12))
                            .foregroundStyle(Palette.taupe)
                    }

                    Spacer()

                    if revealed {
                        HStack(spacing: 12) {
                            gradeButton("Slipped", remembered: false, fill: .white.opacity(0.1), fg: Palette.sand)
                            gradeButton("Got it", remembered: true, fill: Palette.cream, fg: Palette.espresso)
                        }
                        .padding(.horizontal, 28)
                    } else {
                        Button {
                            Haptics.soft()
                            withAnimation { revealed = true }
                        } label: {
                            Text("Reveal")
                                .font(.label(16, weight: .semibold))
                                .foregroundStyle(Palette.espresso)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background { Capsule().fill(Palette.cream) }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)
                    }
                    Spacer().frame(height: 40)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Palette.bronze)
                    Text("Hidden in your heart")
                        .font(.display(26))
                        .foregroundStyle(Palette.cream)
                    Text("Come back when the next review is due.")
                        .font(.label(13))
                        .foregroundStyle(Palette.sand)
                    Button { dismiss() } label: {
                        Text("Done")
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.espresso)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                }
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }

    private func gradeButton(_ title: String, remembered: Bool, fill: some ShapeStyle, fg: Color) -> some View {
        Button {
            Haptics.tap()
            let verse = due[index]
            store.reviewDeckVerse(verse, remembered: remembered)
            revealed = false
            // dueDeckVerses shrinks when a verse is rescheduled, so index stays put.
            if index >= store.dueDeckVerses.count { index = store.dueDeckVerses.count }
        } label: {
            Text(title)
                .font(.label(15, weight: .semibold))
                .foregroundStyle(fg)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background { Capsule().fill(fill) }
        }
        .buttonStyle(.plain)
    }

    private func firstLetters(of text: String) -> String {
        text.split(separator: " ")
            .map { word -> String in
                let first = word.prefix(1)
                return String(first) + "―"
            }
            .joined(separator: " ")
    }
}
