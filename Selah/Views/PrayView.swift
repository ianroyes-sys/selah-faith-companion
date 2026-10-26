import SwiftUI

struct PrayView: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var community = CommunityStore.shared
    @State private var mode: Mode = .wall
    @State private var feed: Feed = .requests
    @State private var showComposer = false
    @State private var showSOS = false
    @State private var showBlessing = false

    enum Mode: String, CaseIterable { case wall = "Wall", circles = "Circles", vault = "Vault", journal = "Journal" }
    enum Feed: String, CaseIterable { case requests = "Requests", answered = "Answered" }

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(spacing: 0) {
                header
                picker
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        switch mode {
                        case .wall: wallSection
                        case .circles: CirclesSection(community: community)
                        case .vault: VaultSection()
                        case .journal: journalList
                        }
                        Spacer().frame(height: 110)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .refreshable {
                    switch mode {
                    case .wall:
                        await community.refreshWall()
                        await community.refreshTestimonies()
                    case .circles:
                        await community.refreshCircles()
                    default: break
                    }
                }
            }
        }
        .sheet(isPresented: $showComposer) { PrayerComposer() }
        .sheet(isPresented: $showBlessing) { BlessingSheet() }
        .fullScreenCover(isPresented: $showSOS) { SOSView() }
        .task {
            await community.register(name: store.name)
            await community.heartbeat()
            await community.refreshWall()
            await community.refreshTestimonies()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Pray")
                    .font(.display(30))
                    .foregroundStyle(Palette.ink)
                HStack(spacing: 6) {
                    if community.prayingNow > 1 {
                        Circle().fill(Palette.sage).frame(width: 6, height: 6)
                        Text("\(community.prayingNow) praying right now")
                    } else {
                        Text("\(community.communityPrayed) prayers prayed with others")
                    }
                }
                .font(.label(12))
                .foregroundStyle(Palette.mocha)
            }
            Spacer()
            Button {
                Haptics.tap(); showBlessing = true
            } label: {
                Image(systemName: "waveform.and.mic")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.onLinen)
                    .frame(width: 40, height: 40)
                    .background { Circle().fill(Palette.linen) }
            }
            .buttonStyle(.plain)
            Button {
                Haptics.tap(); showSOS = true
            } label: {
                Image(systemName: "lifepreserver")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.cream)
                    .frame(width: 40, height: 40)
                    .background { Circle().fill(Palette.bronze) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private var picker: some View {
        HStack(spacing: 8) {
            ForEach(Mode.allCases, id: \.self) { m in
                Button {
                    Haptics.soft()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { mode = m }
                } label: {
                    PillChip(text: m.rawValue, selected: mode == m)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Button {
                Haptics.tap(); showComposer = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.onLinen)
                    .frame(width: 38, height: 38)
                    .background { Circle().fill(Palette.linen) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    // MARK: Wall — the real, shared prayer wall.

    @ViewBuilder private var wallSection: some View {
        CommonsCard(community: community)
        RelayCard(community: community)

        HStack(spacing: 8) {
            ForEach(Feed.allCases, id: \.self) { f in
                Button {
                    Haptics.soft()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { feed = f }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: f == .requests ? "hands.and.sparkles" : "checkmark.seal")
                            .font(.system(size: 11, weight: .medium))
                        Text(f.rawValue)
                    }
                    .font(.label(12, weight: feed == f ? .semibold : .medium))
                    .foregroundStyle(feed == f ? Palette.onInk : Palette.onLinenSoft)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background { Capsule().fill(feed == f ? Palette.ink : Palette.linen) }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.top, 2)

        switch feed {
        case .requests: requestsFeed
        case .answered: answeredFeed
        }
    }

    @ViewBuilder private var requestsFeed: some View {
        switch community.wallState {
        case .idle, .loading:
            loadingCards
        case .failed(let message):
            ErrorCard(message: message) { Task { await community.refreshWall() } }
        case .loaded:
            if community.wall.isEmpty {
                emptyWall
            } else {
                ForEach(community.wall) { prayer in
                    CommunityWallCard(prayer: prayer, community: community)
                }
            }
        }
    }

    @ViewBuilder private var answeredFeed: some View {
        switch community.testimonyState {
        case .idle, .loading:
            loadingCards
        case .failed(let message):
            ErrorCard(message: message) { Task { await community.refreshTestimonies() } }
        case .loaded:
            if community.testimonies.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 28))
                        .foregroundStyle(Palette.taupe)
                    Text("No testimonies yet")
                        .font(.display(19))
                        .foregroundStyle(Palette.ink)
                    Text("When God answers a prayer in your vault,\nyou can share the story here — a feed\nmade of nothing but answered prayers.")
                        .font(.label(13))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.mocha)
                        .lineSpacing(3)
                }
                .padding(.vertical, 44)
            } else {
                ForEach(community.testimonies) { testimony in
                    TestimonyCard(testimony: testimony, community: community)
                }
            }
        }
    }

    private var loadingCards: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Palette.linen.opacity(0.6))
                    .frame(height: 118)
            }
        }
        .redacted(reason: .placeholder)
    }

    private var emptyWall: some View {
        VStack(spacing: 12) {
            Image(systemName: "hands.and.sparkles")
                .font(.system(size: 28))
                .foregroundStyle(Palette.taupe)
            Text("The wall is quiet")
                .font(.display(19))
                .foregroundStyle(Palette.ink)
            Text("Be one of the first to lay a prayer here.\nSomeone will pick it up.")
                .font(.label(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.mocha)
                .lineSpacing(3)
            Button {
                showComposer = true
            } label: {
                Text("Lay one down")
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(Palette.onInk)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background { Capsule().fill(Palette.ink) }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 50)
    }

    // MARK: Journal (stays fully private, on-device)

    @ViewBuilder private var journalList: some View {
        if store.journal.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "book.closed")
                    .font(.system(size: 30))
                    .foregroundStyle(Palette.taupe)
                Text("Your journal is quiet")
                    .font(.display(20))
                    .foregroundStyle(Palette.ink)
                Text("Capture what God is doing —\nyou'll want to remember this season.")
                    .font(.label(13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.mocha)
                Button {
                    showComposer = true
                } label: {
                    Text("First entry")
                        .font(.label(14, weight: .semibold))
                        .foregroundStyle(Palette.onInk)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background { Capsule().fill(Palette.ink) }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 70)
        } else {
            ForEach(store.journal) { entry in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle().fill(Palette.linen).frame(width: 38, height: 38)
                        Image(systemName: entry.mood.symbol)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Palette.onLinenSoft)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.label(11, weight: .semibold))
                                .foregroundStyle(Palette.taupe)
                            if entry.kind == "reflection" {
                                HStack(spacing: 3) {
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 8))
                                    Text("Evening reflection")
                                        .font(.label(9, weight: .semibold))
                                }
                                .foregroundStyle(Palette.bronze)
                            }
                        }
                        Text(entry.text)
                            .font(.label(14))
                            .lineSpacing(4)
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                }
                .padding(18)
                .glassCard(corner: 24)
            }
        }
    }
}

// MARK: - Composer (wall post or journal entry)

struct PrayerComposer: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var community = CommunityStore.shared
    @Environment(\.dismiss) private var dismiss
    @StateObject private var transcriber = PrayerTranscriber()
    @State private var text = ""
    @State private var destination: Destination = .wall
    @State private var mood: Mood = .hopeful
    @State private var anonymous = true
    @State private var posting = false
    @State private var errorMessage: String?
    @State private var showGuidelines = false

    enum Destination: String, CaseIterable { case wall = "Prayer Wall", journal = "Journal" }

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(alignment: .leading, spacing: 18) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)
                Text(destination == .wall ? "Ask for prayer" : "New entry")
                    .font(.display(26))
                    .foregroundStyle(Palette.ink)
                HStack(spacing: 8) {
                    ForEach(Destination.allCases, id: \.self) { d in
                        Button { destination = d } label: {
                            PillChip(text: d.rawValue, selected: destination == d)
                        }
                        .buttonStyle(.plain)
                    }
                }
                if destination == .journal {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Mood.allCases) { m in
                                Button { mood = m } label: {
                                    PillChip(text: m.title, selected: mood == m)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                TextField(destination == .wall
                          ? "What can we stand with you for?"
                          : "What is God doing in you today?",
                          text: $text, axis: .vertical)
                    .font(.label(16))
                    .lineLimit(5...10)
                    .padding(18)
                    .glassCard(corner: 22)

                PrivacyBadge(text: destination == .journal
                             ? "Stays on this phone — never uploaded, never sold."
                             : "No account behind this — only the name you choose is shown.")

                // Speak your prayer — on-device transcription straight into the entry.
                HStack(spacing: 10) {
                    Button {
                        Haptics.tap()
                        if transcriber.listening {
                            transcriber.stop()
                            if !transcriber.transcript.isEmpty {
                                text = text.isEmpty ? transcriber.transcript : text + " " + transcriber.transcript
                                transcriber.transcript = ""
                            }
                        } else {
                            transcriber.start()
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: transcriber.listening ? "waveform" : "mic.fill")
                                .symbolEffect(.pulse, isActive: transcriber.listening)
                            Text(transcriber.listening ? "Listening… tap when done" : "Speak it instead")
                        }
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(transcriber.listening ? Palette.cream : Palette.onLinenSoft)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background { Capsule().fill(transcriber.listening ? Palette.bronze : Palette.linen) }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                if transcriber.listening, !transcriber.transcript.isEmpty {
                    Text(transcriber.transcript)
                        .font(.scripture(14))
                        .italic()
                        .foregroundStyle(Palette.mocha)
                        .lineLimit(3)
                }
                if let err = transcriber.errorMessage {
                    Text(err)
                        .font(.label(11))
                        .foregroundStyle(Color(hex: 0x9C4A38))
                }
                if destination == .wall {
                    Button {
                        Haptics.soft()
                        withAnimation { anonymous.toggle() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: anonymous ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(anonymous ? Palette.bronze : Palette.taupe)
                            Text(anonymous || store.name.isEmpty
                                 ? "Post anonymously"
                                 : "Posting as \(store.name)")
                                .font(.label(13, weight: .medium))
                                .foregroundStyle(Palette.mocha)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                if let errorMessage {
                    Text(errorMessage)
                        .font(.label(12))
                        .foregroundStyle(Color(hex: 0x9C4A38))
                }
                Spacer()
                Button {
                    submit()
                } label: {
                    HStack(spacing: 8) {
                        if posting { ProgressView().tint(Palette.onInk).scaleEffect(0.85) }
                        Text(destination == .wall ? "Post to wall" : "Save entry")
                    }
                }
                .buttonStyle(BronzeButtonStyle())
                .disabled(posting)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .sheet(isPresented: $showGuidelines) {
            GuidelinesSheet(community: community) { submit() }
        }
    }

    private func submit() {
        if transcriber.listening {
            transcriber.stop()
            if !transcriber.transcript.isEmpty {
                text = text.isEmpty ? transcriber.transcript : text + " " + transcriber.transcript
            }
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if destination == .journal {
            Haptics.success()
            store.addJournal(JournalEntry(mood: mood, text: trimmed))
            dismiss()
            return
        }

        guard community.guidelinesAccepted else {
            showGuidelines = true
            return
        }

        posting = true
        errorMessage = nil
        Task {
            do {
                let author = anonymous || store.name.isEmpty ? "Anonymous" : store.name
                try await community.postPrayer(trimmed, authorName: author)
                Haptics.success()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            posting = false
        }
    }
}
