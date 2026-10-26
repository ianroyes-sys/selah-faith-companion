import SwiftUI

// MARK: - The Selah Loop — the daily wellness rhythm the whole app hangs on.
// Morning: check in (how's your heart). Midday: the Word (devotional or syllabus day).
// Evening: the Reflection (guided, mood-aware). Close all three, the loop seals,
// the streak grows, and the day gets a shareable seal.

enum LoopTracker {
    static var dayKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    private static var yesterdayKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    }

    static func markWord() {
        UserDefaults.standard.set(dayKey, forKey: "selah.loop.wordDay")
    }
    static var wordDone: Bool {
        UserDefaults.standard.string(forKey: "selah.loop.wordDay") == dayKey
    }
    static var reflectDone: Bool {
        UserDefaults.standard.string(forKey: "selah.loop.reflectDay") == dayKey
    }

    /// Called when the reflection is sealed. Returns the updated loop streak.
    static func sealDay() -> Int {
        UserDefaults.standard.set(dayKey, forKey: "selah.loop.reflectDay")
        let last = UserDefaults.standard.string(forKey: "selah.loop.lastClosed") ?? ""
        var streak = UserDefaults.standard.integer(forKey: "selah.loop.streak")
        if last == dayKey { return max(streak, 1) }
        streak = (last == yesterdayKey) ? streak + 1 : 1
        UserDefaults.standard.set(streak, forKey: "selah.loop.streak")
        UserDefaults.standard.set(dayKey, forKey: "selah.loop.lastClosed")
        return streak
    }

    static var streak: Int { UserDefaults.standard.integer(forKey: "selah.loop.streak") }
}

// MARK: - Loop card (Today)

struct LoopCard: View {
    @EnvironmentObject var store: UserStore
    @AppStorage("selah.loop.wordDay") private var wordDay: String = ""
    @AppStorage("selah.loop.reflectDay") private var reflectDay: String = ""
    @AppStorage("selah.loop.streak") private var loopStreak: Int = 0
    @State private var showReflection = false

    private var checkinDone: Bool { store.todayMood != nil }
    private var wordDone: Bool { wordDay == LoopTracker.dayKey }
    private var reflectDone: Bool { reflectDay == LoopTracker.dayKey }
    private var doneCount: Int { [checkinDone, wordDone, reflectDone].filter { $0 }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("The Selah Loop".uppercased())
                    .font(.label(10, weight: .semibold))
                    .kerning(1.2)
                    .foregroundStyle(Palette.mocha)
                Spacer()
                if loopStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 10))
                        Text("\(loopStreak)-day loop")
                            .font(.label(11, weight: .semibold))
                    }
                    .foregroundStyle(Palette.bronze)
                }
            }

            HStack(spacing: 10) {
                loopStep(n: 1, title: "Check in", symbol: "heart", done: checkinDone)
                connector(filled: checkinDone && wordDone)
                loopStep(n: 2, title: "The Word", symbol: "book", done: wordDone)
                connector(filled: wordDone && reflectDone)
                loopStep(n: 3, title: "Reflect", symbol: "moon.stars", done: reflectDone)
            }

            if reflectDone {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.bronze)
                    Text("Today is sealed. Sleep easy.")
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    ShareLink(item: "Day sealed. \(max(loopStreak, 1)) days of checking in with God, morning and night — with Selah. https://selah.app") {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.bronze)
                    }
                }
            } else {
                Button {
                    Haptics.tap(); showReflection = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 13))
                        Text(doneCount == 2 ? "One step left — close your loop" : "Tonight, close your loop")
                            .font(.label(14, weight: .semibold))
                    }
                    .foregroundStyle(Palette.onInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background { Capsule().fill(Palette.ink) }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .glassCard(corner: 26)
        .sheet(isPresented: $showReflection) { ReflectionSheet() }
    }

    private func loopStep(n: Int, title: String, symbol: String, done: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(done ? Palette.bronze : Palette.linen)
                    .frame(width: 40, height: 40)
                Image(systemName: done ? "checkmark" : symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(done ? Palette.cream : Palette.onLinenSoft)
            }
            Text(title)
                .font(.label(10, weight: done ? .semibold : .medium))
                .foregroundStyle(done ? Palette.ink : Palette.taupe)
        }
        .frame(maxWidth: .infinity)
    }

    private func connector(filled: Bool) -> some View {
        Rectangle()
            .fill(filled ? Palette.bronze : Palette.sand.opacity(0.5))
            .frame(height: 2)
            .frame(maxWidth: 26)
            .offset(y: -10)
    }
}

// MARK: - Evening reflection

struct ReflectionSheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var eveningMood: Mood?
    @State private var answer = ""
    @State private var gratitude = ""
    @State private var sealedStreak: Int?

    private var morningMood: Mood? { store.todayMood }

    /// Mood-aware evening question — the reflection knows how the day started.
    private var question: String {
        let mood = eveningMood ?? morningMood
        switch mood {
        case .anxious: return "What did the worry say today — and what turned out to be true instead?"
        case .overwhelmed: return "What's one thing you carried today that you can set down before bed?"
        case .tired: return "Where did today take more than it gave — and what would real rest look like tonight?"
        case .lonely: return "Who or what reminded you today that you're not invisible?"
        case .tempted: return "Where did the pull show up today — and what helped, even a little?"
        case .hopeful: return "What small thing today felt like a seed of something bigger?"
        case .grateful: return "What's one gift from today you almost didn't notice?"
        case .joyful: return "What made today good — and who could you tell about it?"
        case nil: return "Where did you see God in the ordinary parts of today?"
        }
    }

    private var benediction: Verse {
        ContentLibrary.verse(eveningMood == .anxious || morningMood == .anxious ? "Psalm 4:8" : "Numbers 6:24-25")
    }

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(spacing: 0) {
                header
                TabView(selection: $step) {
                    landing.tag(0)
                    writing.tag(1)
                    seal.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Palette.bronze : .white.opacity(0.15))
                        .frame(width: i == step ? 22 : 8, height: 5)
                }
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.sand)
                    .frame(width: 34, height: 34)
                    .background { Circle().fill(.white.opacity(0.1)) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    // Step 1 — how did the heart land?
    private var landing: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Evening\nReflection")
                    .font(.display(34))
                    .foregroundStyle(Palette.cream)
                if let morning = morningMood {
                    HStack(spacing: 8) {
                        Image(systemName: morning.symbol)
                            .font(.system(size: 12))
                        Text("This morning your heart was \(morning.rawValue).")
                            .font(.label(13))
                    }
                    .foregroundStyle(Palette.sand)
                }
                Text("And where did it land tonight?")
                    .font(.scripture(18))
                    .foregroundStyle(Palette.cream)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
                    ForEach(Mood.allCases) { m in
                        Button {
                            Haptics.soft()
                            withAnimation { eveningMood = m }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: m.symbol)
                                    .font(.system(size: 11, weight: .medium))
                                Text(m.title)
                                    .font(.label(12, weight: eveningMood == m ? .semibold : .medium))
                            }
                            .foregroundStyle(eveningMood == m ? Palette.espresso : Palette.sand)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                Capsule().fill(eveningMood == m ? Palette.cream : .white.opacity(0.08))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    Haptics.tap()
                    withAnimation { step = 1 }
                } label: {
                    Text("Continue")
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                .disabled(eveningMood == nil)
                .opacity(eveningMood == nil ? 0.45 : 1)
                .padding(.top, 6)
            }
            .padding(.horizontal, 26)
            .padding(.top, 18)
        }
    }

    // Step 2 — the guided look back.
    private var writing: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Look back gently")
                    .font(.display(28))
                    .foregroundStyle(Palette.cream)
                Text(question)
                    .font(.scripture(17))
                    .italic()
                    .lineSpacing(5)
                    .foregroundStyle(Palette.sand)

                TextField("Write it honestly…", text: $answer, axis: .vertical)
                    .font(.label(15))
                    .lineLimit(4...8)
                    .foregroundStyle(Palette.cream)
                    .tint(Palette.bronze)
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.white.opacity(0.08))
                    }

                Text("And one thing you're thankful for:")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Palette.sand)
                TextField("Even a small one counts…", text: $gratitude, axis: .vertical)
                    .font(.label(15))
                    .lineLimit(2...4)
                    .foregroundStyle(Palette.cream)
                    .tint(Palette.bronze)
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.white.opacity(0.08))
                    }

                Button {
                    sealTheDay()
                } label: {
                    Text("Seal the day")
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                .disabled(answer.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(answer.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)
                .padding(.top, 4)
            }
            .padding(.horizontal, 26)
            .padding(.top, 18)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // Step 3 — benediction + seal.
    private var seal: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Palette.bronze)
            Text("Sealed.")
                .font(.display(32))
                .foregroundStyle(Palette.cream)
            if let streak = sealedStreak, streak > 1 {
                Text("\(streak) days of closing the loop.")
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(Palette.bronze)
            }
            VStack(spacing: 10) {
                Text("“\(benediction.text)”")
                    .font(.scripture(17))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .foregroundStyle(Palette.cream)
                Text(benediction.reference)
                    .font(.label(11, weight: .semibold))
                    .kerning(1)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.bronze)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.white.opacity(0.07))
            }
            .padding(.horizontal, 26)
            Spacer()
            ShareLink(item: "Day sealed. Morning check-in, the Word, and an evening reflection — the Selah Loop, \(max(sealedStreak ?? 1, 1)) days strong. https://selah.app") {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share the seal")
                }
                .font(.label(15, weight: .semibold))
                .foregroundStyle(Palette.espresso)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background { Capsule().fill(Palette.cream) }
            }
            .padding(.horizontal, 26)
            Button("Goodnight") { dismiss() }
                .font(.label(14, weight: .medium))
                .foregroundStyle(Palette.sand)
                .padding(.bottom, 34)
        }
    }

    private func sealTheDay() {
        Haptics.success()
        let mood = eveningMood ?? morningMood ?? .grateful
        var text = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let thanks = gratitude.trimmingCharacters(in: .whitespacesAndNewlines)
        if !thanks.isEmpty { text += "\n\nThankful for: \(thanks)" }
        store.addJournal(JournalEntry(mood: mood, text: text, kind: "reflection"))
        sealedStreak = LoopTracker.sealDay()
        withAnimation { step = 2 }
    }
}
