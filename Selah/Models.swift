import SwiftUI

// MARK: - Content models

struct Verse: Identifiable, Codable, Hashable {
    var id: String { reference }
    let text: String
    let reference: String
    let moods: [Mood]
    let topics: [String]
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case grateful, anxious, tired, hopeful, lonely, tempted, joyful, overwhelmed
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .grateful: "hands.sparkles"
        case .anxious: "water.waves"
        case .tired: "zzz"
        case .hopeful: "sunrise"
        case .lonely: "cloud.moon"
        case .tempted: "shield"
        case .joyful: "sun.max"
        case .overwhelmed: "leaf"
        }
    }
    var title: String { rawValue.capitalized }
}

struct Devotional: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let verse: Verse
    let body: String
    let reflection: String
    let prayer: String
}

struct ReadingPlan: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let days: Int
    let gradient: [UInt32]
    let symbol: String
    let premium: Bool
}

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var mood: Mood
    var text: String
    /// nil = regular entry; "reflection" = an evening loop reflection.
    var kind: String?

    init(mood: Mood, text: String, kind: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.mood = mood
        self.text = text
        self.kind = kind
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: Role
    var text: String
    enum Role { case user, companion }
}

/// A personal prayer tracked over time — the heart of the Answered Prayer Vault.
struct PersonalPrayer: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var createdAt: Date
    var status: Status
    var answeredAt: Date?
    var answeredNote: String

    enum Status: String, Codable { case open, answered, released }

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.status = .open
        self.answeredAt = nil
        self.answeredNote = ""
    }
}

/// A verse being memorized with a lightweight spaced-repetition schedule.
struct MemoryVerse: Identifiable, Codable, Hashable {
    var id: String { reference }
    let reference: String
    let text: String
    var intervalDays: Int
    var dueAt: Date
    var reps: Int

    init(verse: Verse) {
        self.reference = verse.reference
        self.text = verse.text
        self.intervalDays = 1
        self.dueAt = Date()
        self.reps = 0
    }

    mutating func review(remembered: Bool) {
        if remembered {
            reps += 1
            intervalDays = min(intervalDays * 2, 60)
        } else {
            reps = 0
            intervalDays = 1
        }
        dueAt = Calendar.current.date(byAdding: .day, value: intervalDays, to: Date()) ?? Date()
    }
}

// MARK: - App state

@MainActor
final class UserStore: ObservableObject {
    @AppStorage("selah.name") var name: String = ""
    @AppStorage("selah.onboarded") var onboarded: Bool = false
    @AppStorage("selah.premium") var isPremium: Bool = false
    @AppStorage("selah.streak") var streak: Int = 0
    @AppStorage("selah.bestStreak") var bestStreak: Int = 0
    @AppStorage("selah.lastOpenDay") private var lastOpenDay: String = ""
    @AppStorage("selah.versesRead") var versesRead: Int = 0
    @AppStorage("selah.freeChatToday") var freeChatToday: Int = 0
    @AppStorage("selah.freeUseDay") private var freeUseDay: String = ""

    @Published var todayMood: Mood? { didSet { persistMood() } }
    @Published var shieldSaved = false
    @Published var remindedPrayers: Set<String> = []
    @AppStorage("selah.moodDay") private var moodDay: String = ""
    @AppStorage("selah.moodRaw") private var moodRaw: String = ""
    @AppStorage("selah.shieldWeek") private var shieldWeek: String = ""
    @Published var journal: [JournalEntry] = []
    @Published var vault: [PersonalPrayer] = []
    @Published var memoryDeck: [MemoryVerse] = []

    static let freeDailyChats = 5

    private let journalURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("journal.json")
    private let vaultURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("vault.json")
    private let deckURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("deck.json")

    init() {
        load()
        touchStreak()
        resetDailyLimitsIfNeeded()
        restoreMood()
        remindedPrayers = Set(UserDefaults.standard.stringArray(forKey: "selah.remindedPrayers") ?? [])
    }

    // MARK: Mood — one heart check-in per day, survives relaunch.

    private static var dayKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private static var weekKey: String {
        let cal = Calendar.current
        return "\(cal.component(.yearForWeekOfYear, from: Date()))-\(cal.component(.weekOfYear, from: Date()))"
    }

    private func restoreMood() {
        if moodDay == Self.dayKey, let m = Mood(rawValue: moodRaw) {
            todayMood = m
        }
    }

    private func persistMood() {
        guard let mood = todayMood else { return }
        moodDay = Self.dayKey
        moodRaw = mood.rawValue
    }

    func toggleReminder(for prayer: PersonalPrayer) {
        if remindedPrayers.contains(prayer.id.uuidString) {
            remindedPrayers.remove(prayer.id.uuidString)
            NotificationService.shared.cancelPrayerReminder(prayer)
        } else {
            remindedPrayers.insert(prayer.id.uuidString)
            NotificationService.shared.schedulePrayerReminder(prayer)
        }
        UserDefaults.standard.set(Array(remindedPrayers), forKey: "selah.remindedPrayers")
    }

    // MARK: Streak — opening the app on consecutive days keeps the flame alive.
    private func touchStreak() {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        guard lastOpenDay != today else { return }
        let yesterday = f.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        let dayBefore = f.string(from: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)
        if lastOpenDay == yesterday {
            streak += 1
        } else if lastOpenDay == dayBefore, isPremium, shieldWeek != Self.weekKey, streak >= 2 {
            // Streak Shield (Selah+): one missed day a week doesn't break you.
            streak += 1
            shieldWeek = Self.weekKey
            shieldSaved = true
        } else {
            streak = 1
        }
        bestStreak = max(bestStreak, streak)
        lastOpenDay = today
    }

    private func resetDailyLimitsIfNeeded() {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        if freeUseDay != today {
            freeUseDay = today
            freeChatToday = 0
        }
    }

    var canChat: Bool { isPremium || freeChatToday < Self.freeDailyChats }

    // MARK: Persistence
    func load() {
        if let d = try? Data(contentsOf: journalURL),
           let e = try? JSONDecoder().decode([JournalEntry].self, from: d) { journal = e }
        if let d = try? Data(contentsOf: vaultURL),
           let v = try? JSONDecoder().decode([PersonalPrayer].self, from: d) { vault = v }
        if let d = try? Data(contentsOf: deckURL),
           let m = try? JSONDecoder().decode([MemoryVerse].self, from: d) { memoryDeck = m }
    }

    func save() {
        if let d = try? JSONEncoder().encode(journal) { try? d.write(to: journalURL) }
        if let d = try? JSONEncoder().encode(vault) { try? d.write(to: vaultURL) }
        if let d = try? JSONEncoder().encode(memoryDeck) { try? d.write(to: deckURL) }
    }

    func addJournal(_ entry: JournalEntry) {
        journal.insert(entry, at: 0)
        save()
    }

    // MARK: Vault

    func addVaultPrayer(_ text: String) {
        vault.insert(PersonalPrayer(text: text), at: 0)
        save()
    }

    func markAnswered(_ prayer: PersonalPrayer, note: String) {
        guard let i = vault.firstIndex(where: { $0.id == prayer.id }) else { return }
        vault[i].status = .answered
        vault[i].answeredAt = Date()
        vault[i].answeredNote = note
        save()
    }

    func release(_ prayer: PersonalPrayer) {
        guard let i = vault.firstIndex(where: { $0.id == prayer.id }) else { return }
        vault[i].status = .released
        save()
    }

    var answeredPrayers: [PersonalPrayer] { vault.filter { $0.status == .answered } }
    var openPrayers: [PersonalPrayer] { vault.filter { $0.status == .open } }

    /// The prayer Selah gently follows up on: oldest open prayer at least 5 days old.
    var followUpCandidate: PersonalPrayer? {
        openPrayers
            .filter { $0.createdAt < Calendar.current.date(byAdding: .day, value: -5, to: Date())! }
            .min { $0.createdAt < $1.createdAt }
    }

    /// A random answered prayer to hold up as evidence in a low moment.
    var evidenceStone: PersonalPrayer? { answeredPrayers.randomElement() }

    // MARK: Patterns

    /// Detects a repeating mood on a given weekday across the journal, e.g. "anxious Fridays".
    var moodPattern: (mood: Mood, weekday: String)? {
        var counts: [String: Int] = [:]
        let cal = Calendar.current
        for e in journal {
            let key = "\(e.mood.rawValue)|\(cal.component(.weekday, from: e.date))"
            counts[key, default: 0] += 1
        }
        guard let (key, n) = counts.max(by: { $0.value < $1.value }), n >= 3 else { return nil }
        let parts = key.split(separator: "|")
        guard let mood = Mood(rawValue: String(parts[0])), let wd = Int(parts[1]) else { return nil }
        return (mood, cal.weekdaySymbols[wd - 1])
    }

    // MARK: Companion memory — a compact local context string for the on-device model.

    func memoryContext() -> String {
        var lines: [String] = []
        if let mood = todayMood { lines.append("Today they said they feel \(mood.rawValue).") }
        let recentMoods = journal.prefix(6).map { $0.mood.rawValue }
        if !recentMoods.isEmpty { lines.append("Recent journal moods: \(recentMoods.joined(separator: ", ")).") }
        if let p = openPrayers.first {
            lines.append("They are currently praying about: \"\(p.text.prefix(90))\".")
        }
        if let a = answeredPrayers.first {
            lines.append("A prayer God answered for them recently: \"\(a.text.prefix(90))\".")
        }
        if let pattern = moodPattern {
            lines.append("Pattern noticed: they often feel \(pattern.mood.rawValue) on \(pattern.weekday)s.")
        }
        if streak > 3 { lines.append("They are on a \(streak)-day streak with the app.") }
        return lines.joined(separator: " ")
    }

    // MARK: Memorization deck

    func addToDeck(_ verse: Verse) {
        guard !memoryDeck.contains(where: { $0.reference == verse.reference }) else { return }
        memoryDeck.append(MemoryVerse(verse: verse))
        save()
    }

    func reviewDeckVerse(_ verse: MemoryVerse, remembered: Bool) {
        guard let i = memoryDeck.firstIndex(where: { $0.reference == verse.reference }) else { return }
        memoryDeck[i].review(remembered: remembered)
        save()
    }

    var dueDeckVerses: [MemoryVerse] { memoryDeck.filter { $0.dueAt <= Date() } }
}
