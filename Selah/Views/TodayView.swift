import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var community = CommunityStore.shared
    @StateObject private var life = LifeContext()
    @State private var showDevotional = false
    @State private var showShare = false
    @State private var showOffice = false
    @State private var explanation: String?
    @State private var explaining = false

    private var verse: Verse { ContentLibrary.verseOfToday }
    private var devo: Devotional { ContentLibrary.devotionalOfToday }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case ..<12: return "Good morning"
        case ..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    loveCard
                    shieldBanner
                    verseHero
                    LoopCard()
                    blessingCard
                    officeCard
                    moodRow
                    SyllabusTodayCard()
                    SoundtrackCard()
                    presenceRow
                    evidenceCard
                    devotionalCard
                    contextCard
                    challengeCard
                    Spacer().frame(height: 90)
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showDevotional) { DevotionalSheet(devotional: devo) }
        .sheet(isPresented: $showShare) { ShareCardSheet(verse: verse) }
        .sheet(isPresented: $showOffice) { AudioOfficeSheet(life: life) }
        .onAppear { life.refresh() }
        .task {
            await community.register(name: store.name)
            await community.heartbeat()
            await community.refreshLatestBlessing()
            await community.refreshActivity()
        }
    }

    // MARK: Personalized audio office
    private var officeCard: some View {
        let evening = Calendar.current.component(.hour, from: Date()) >= 17
        return Button {
            Haptics.tap(); showOffice = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Palette.bronze, Palette.mocha],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: evening ? "moon.stars" : "sun.horizon")
                        .font(.system(size: 18))
                        .foregroundStyle(Palette.cream)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(evening ? "Evening Wind-Down" : "Morning Reset")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text(life.todaySummary.map { "Prayed around \($0)" }
                         ?? "A prayer written over your actual day")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "text.alignleft")
                    .foregroundStyle(Palette.bronze)
            }
            .padding(16)
            .glassCard(corner: 26)
        }
        .buttonStyle(.plain)
    }

    // MARK: While you were away — love that landed on your posts.
    @ViewBuilder private var loveCard: some View {
        if community.newLove > 0 {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.bronze.opacity(0.18)).frame(width: 44, height: 44)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Palette.bronze)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("While you were away")
                        .font(.label(11, weight: .semibold))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.mocha)
                    Text(community.newLove == 1
                         ? "Someone prayed over what you shared."
                         : "\(community.newLove) people prayed over what you shared.")
                        .font(.scripture(15))
                        .foregroundStyle(Palette.ink)
                }
                Spacer()
            }
            .padding(16)
            .glassCard(corner: 24)
            .transition(.opacity)
        }
    }

    // MARK: Streak Shield save notice (Selah+).
    @ViewBuilder private var shieldBanner: some View {
        if store.shieldSaved {
            HStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 18))
                    .foregroundStyle(Palette.bronze)
                Text("Streak Shield caught you — your \(store.streak)-day streak survived yesterday.")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(2)
                Spacer()
            }
            .padding(16)
            .glassCard(corner: 24)
            .transition(.opacity)
        }
    }

    // MARK: A blessing from your circle, spoken over your morning.
    @ViewBuilder private var blessingCard: some View {
        if let blessing = community.latestBlessing {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.and.horizon")
                        .foregroundStyle(Palette.bronze)
                    Text("From your circle")
                        .font(.label(11, weight: .semibold))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.mocha)
                }
                Text("“\(blessing.body)”")
                    .font(.scripture(16))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.ink)
                Text("— \(blessing.authorName)")
                    .font(.label(12, weight: .medium))
                    .foregroundStyle(Palette.mocha)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .solidCard(corner: 26, fill: Palette.blush.opacity(0.55))
            .transition(.opacity)
        }
    }

    // MARK: Live presence — you never pray alone.
    @ViewBuilder private var presenceRow: some View {
        if community.prayingNow > 1 {
            HStack(spacing: 8) {
                Circle().fill(Palette.sage).frame(width: 7, height: 7)
                Text("\(community.prayingNow) people are praying right now")
                    .font(.label(12, weight: .medium))
                    .foregroundStyle(Palette.mocha)
                Spacer()
            }
            .padding(.horizontal, 6)
        }
    }

    // MARK: Evidence — your own answered prayers, surfaced in low moments.
    @ViewBuilder private var evidenceCard: some View {
        if let mood = store.todayMood,
           [.anxious, .overwhelmed, .lonely, .tired].contains(mood),
           let stone = store.evidenceStone {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Palette.bronze)
                    Text("Remember your evidence")
                        .font(.label(11, weight: .semibold))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.sand)
                }
                Text("You once prayed: “\(stone.text)” — and God answered\(stone.answeredNote.isEmpty ? "." : ": “\(stone.answeredNote)”")")
                    .font(.scripture(16))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.cream)
                Text("He did it then. He's not done now.")
                    .font(.label(12, weight: .medium))
                    .foregroundStyle(Palette.sand)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .transition(.opacity)
        }
    }

    // MARK: Calendar personalization opt-in
    @ViewBuilder private var contextCard: some View {
        if !life.granted {
            Button {
                Haptics.tap(); life.requestAccess()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20))
                        .foregroundStyle(Palette.onLinenSoft)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Personalize your mornings")
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.onLinen)
                        Text("Selah prays around what's actually on your plate — read on-device, never uploaded")
                            .font(.label(12))
                            .foregroundStyle(Palette.onLinenSoft)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Palette.onLinenSoft)
                }
                .padding(18)
                .solidCard(corner: 26)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting.uppercased())
                    .font(.label(11, weight: .semibold))
                    .kerning(1.5)
                    .foregroundStyle(Palette.mocha)
                Text(store.name.isEmpty ? "Friend" : store.name)
                    .font(.display(30))
                    .foregroundStyle(Palette.ink)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Palette.bronze)
                Text("\(store.streak)")
                    .font(.label(16, weight: .bold))
                    .foregroundStyle(Palette.ink)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassCard(corner: 20)
        }
    }

    // MARK: Verse of the day — dark editorial hero
    private var verseHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Verse of the day")
                .font(.label(11, weight: .semibold))
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Palette.sand)
            Text("“\(verse.text)”")
                .font(.scripture(23))
                .foregroundStyle(Palette.cream)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
            Text(verse.reference)
                .font(.label(13, weight: .semibold))
                .kerning(1)
                .textCase(.uppercase)
                .foregroundStyle(Palette.bronze)

            if let explanation {
                Text(explanation)
                    .font(.label(14))
                    .foregroundStyle(Palette.sand)
                    .lineSpacing(4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    guard explanation == nil, !explaining else { return }
                    explaining = true
                    Task {
                        let text = await IntelligenceEngine.explainVerse(verse)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            explanation = text
                        }
                        explaining = false
                        store.versesRead += 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        if explaining { ProgressView().tint(Palette.cream).scaleEffect(0.8) }
                        Text(explaining ? "Thinking…" : "Unpack this")
                            .font(.label(14, weight: .semibold))
                    }
                    .foregroundStyle(Palette.cream)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background { Capsule().fill(.white.opacity(0.14)) }
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.tap(); showShare = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(Palette.espresso)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Palette.espresso.opacity(0.25), radius: 24, y: 12)
        }
    }

    // MARK: Mood check-in
    private var moodRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How's your heart?")
                .font(.display(19))
                .foregroundStyle(Palette.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Mood.allCases) { m in
                        Button {
                            Haptics.soft()
                            withAnimation { store.todayMood = m }
                            Task { await community.checkIn(mood: m) }
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: m.symbol)
                                    .font(.system(size: 12, weight: .medium))
                                Text(m.title)
                            }
                            .font(.label(13, weight: store.todayMood == m ? .semibold : .medium))
                            .foregroundStyle(store.todayMood == m ? Palette.onInk : Palette.onLinenSoft)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background {
                                Capsule().fill(store.todayMood == m ? Palette.ink : Palette.linen)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if community.checkedInToday {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.sage)
                    Text(community.checkInStreak > 1
                         ? "Checked in — day \(community.checkInStreak). Your circles can see you showed up."
                         : "Checked in. Your circles can see you showed up.")
                        .font(.label(12, weight: .medium))
                        .foregroundStyle(Palette.mocha)
                }
                .transition(.opacity)
            }
            if let mood = store.todayMood,
               let v = ContentLibrary.verses(for: mood).first, v.reference != verse.reference {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .foregroundStyle(Palette.bronze)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(v.text)
                            .font(.scripture(15))
                            .foregroundStyle(Palette.ink)
                            .lineSpacing(3)
                        Text(v.reference)
                            .font(.label(11, weight: .semibold))
                            .foregroundStyle(Palette.mocha)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard(corner: 24)
                .transition(.opacity)
            }
        }
    }

    // MARK: Daily devotional
    private var devotionalCard: some View {
        Button {
            Haptics.tap()
            LoopTracker.markWord()
            showDevotional = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.sand, Palette.taupe],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 64, height: 84)
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 24))
                        .foregroundStyle(Palette.cream)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's devotional".uppercased())
                        .font(.label(10, weight: .semibold))
                        .kerning(1.2)
                        .foregroundStyle(Palette.mocha)
                    Text(devo.title)
                        .font(.display(20))
                        .foregroundStyle(Palette.ink)
                    Text("3 min · \(devo.verse.reference)")
                        .font(.label(12))
                        .foregroundStyle(Palette.taupe)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.mocha)
            }
            .padding(16)
            .glassCard(corner: 26)
        }
        .buttonStyle(.plain)
    }

    // MARK: Weekly challenge teaser
    private var challengeCard: some View {
        let c = ContentLibrary.challengeOfWeek
        return HStack(spacing: 14) {
            Image(systemName: "sunrise")
                .font(.system(size: 22))
                .foregroundStyle(Palette.onLinenSoft)
            VStack(alignment: .leading, spacing: 3) {
                Text(c.title)
                    .font(.label(15, weight: .semibold))
                    .foregroundStyle(Palette.onLinen)
                Text(c.subtitle)
                    .font(.label(12))
                    .foregroundStyle(Palette.onLinenSoft)
            }
            Spacer()
            Text("Invite friends")
                .font(.label(12, weight: .semibold))
                .foregroundStyle(Palette.cream)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background { Capsule().fill(Palette.espresso) }
        }
        .padding(18)
        .solidCard(corner: 26)
    }
}

// MARK: - Devotional reader

struct DevotionalSheet: View {
    let devotional: Devotional
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                    Text(devotional.title)
                        .font(.display(34))
                        .foregroundStyle(Palette.ink)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("“\(devotional.verse.text)”")
                            .font(.scripture(18))
                            .lineSpacing(5)
                            .foregroundStyle(Palette.cream)
                        Text(devotional.verse.reference)
                            .font(.label(12, weight: .semibold))
                            .kerning(1)
                            .textCase(.uppercase)
                            .foregroundStyle(Palette.bronze)
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Palette.deepBrown)
                    }
                    Text(devotional.body)
                        .font(.label(16))
                        .lineSpacing(7)
                        .foregroundStyle(Palette.ink.opacity(0.9))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reflect".uppercased())
                            .font(.label(11, weight: .semibold))
                            .kerning(1.4)
                            .foregroundStyle(Palette.mocha)
                        Text(devotional.reflection)
                            .font(.scripture(17))
                            .italic()
                            .lineSpacing(5)
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(corner: 24)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pray".uppercased())
                            .font(.label(11, weight: .semibold))
                            .kerning(1.4)
                            .foregroundStyle(Palette.mocha)
                        Text(devotional.prayer)
                            .font(.label(15))
                            .lineSpacing(6)
                            .foregroundStyle(Palette.ink.opacity(0.9))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .solidCard(corner: 24, fill: Palette.blush.opacity(0.6))
                    Button { dismiss() } label: { Text("Amen") }
                        .buttonStyle(BronzeButtonStyle())
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}
