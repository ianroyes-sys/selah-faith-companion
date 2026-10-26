import SwiftUI

// MARK: - The Syllabus — a devotional week written around today's heart.
// Fully on-device: the arc is curated per mood, then personalized with the
// user's name, open prayers, and journal patterns at generation time.

struct SyllabusDay: Identifiable, Codable, Hashable {
    let index: Int
    let title: String
    let verseRef: String
    let devotionalID: String?
    let practice: String
    var done: Bool = false

    var id: Int { index }
    var verse: Verse { ContentLibrary.verse(verseRef) }
    var devotional: Devotional? {
        guard let devotionalID else { return nil }
        return ContentLibrary.devotionals.first { $0.id == devotionalID }
    }
}

struct Syllabus: Codable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let mood: Mood
    let createdAt: Date
    var days: [SyllabusDay]

    var doneCount: Int { days.filter(\.done).count }
    var complete: Bool { doneCount == days.count }
    /// The day currently in front of the reader — first unfinished day.
    var current: SyllabusDay? { days.first { !$0.done } }
}

// MARK: - Store

@MainActor
final class SyllabusStore: ObservableObject {
    static let shared = SyllabusStore()

    @Published var current: Syllabus?

    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("syllabus.json")

    init() {
        if let d = try? Data(contentsOf: url),
           let s = try? JSONDecoder().decode(Syllabus.self, from: d) {
            current = s
        }
    }

    private func save() {
        if let s = current, let d = try? JSONEncoder().encode(s) {
            try? d.write(to: url)
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func generate(mood: Mood, focus: String?, store: UserStore) {
        current = SyllabusEngine.compose(mood: mood, focus: focus, store: store)
        save()
    }

    func markDone(_ day: SyllabusDay) {
        guard var s = current, let i = s.days.firstIndex(where: { $0.index == day.index }) else { return }
        s.days[i].done = true
        current = s
        save()
    }

    func clear() {
        current = nil
        save()
    }
}

// MARK: - Engine

enum SyllabusEngine {

    struct DayBlueprint {
        let title: String
        let verseRef: String
        let devotionalID: String?
        let practice: String
    }

    struct Arc {
        let title: String
        let subtitle: String
        let focuses: [String]
        let days: [DayBlueprint]
    }

    /// One curated week per mood — written, not templated, so every day earns its place.
    static let arcs: [Mood: Arc] = [
        .anxious: Arc(
            title: "Steady",
            subtitle: "Seven days from spiraling to anchored",
            focuses: ["My future", "My relationships", "My mind at night"],
            days: [
                DayBlueprint(title: "Name the storm", verseRef: "Psalm 46:10", devotionalID: "let-your-hands-drop",
                             practice: "Write the worry down in one sentence. Naming it shrinks it."),
                DayBlueprint(title: "Adjourn the committee", verseRef: "Matthew 6:34", devotionalID: "overthinking-at-1am",
                             practice: "When tomorrow-thoughts arrive tonight, say out loud: “That's tomorrow's. Not tonight's.”"),
                DayBlueprint(title: "Hand it over", verseRef: "1 Peter 5:7", devotionalID: nil,
                             practice: "Pray the verse with open palms — physically. Let your hands say what your heart is learning."),
                DayBlueprint(title: "Peace that stays", verseRef: "Isaiah 26:3", devotionalID: "peace-that-stays",
                             practice: "Pick one “home verse” your mind returns to today. Set it as your lock screen."),
                DayBlueprint(title: "Not the spirit of fear", verseRef: "2 Timothy 1:7", devotionalID: "spirit-of-power",
                             practice: "Do one small thing fear has been vetoing. Send the text. Ask the question."),
                DayBlueprint(title: "Through, not around", verseRef: "Isaiah 43:2", devotionalID: "walking-through-water",
                             practice: "Tell one trusted person what water you're in. Company is the promise."),
                DayBlueprint(title: "Unmoved", verseRef: "Psalm 46:5", devotionalID: "she-shall-not-be-moved",
                             practice: "Reread day 1's worry. Write one line about what held steady this week.")
            ]
        ),
        .overwhelmed: Arc(
            title: "Lighter",
            subtitle: "Seven days of putting things down",
            focuses: ["Too many demands", "People-pleasing", "Decisions I can't make"],
            days: [
                DayBlueprint(title: "Drop your hands", verseRef: "Psalm 46:10", devotionalID: "let-your-hands-drop",
                             practice: "List everything you're carrying. Circle what's actually yours. Cross out one thing that never was."),
                DayBlueprint(title: "The rest ethic", verseRef: "Psalm 23:2-3", devotionalID: "the-rest-ethic",
                             practice: "Schedule 15 unproductive minutes today and call it obedience."),
                DayBlueprint(title: "A clean no", verseRef: "Matthew 5:37", devotionalID: "yes-and-no",
                             practice: "Say one no today without a paragraph of apology attached."),
                DayBlueprint(title: "Ask for wisdom", verseRef: "James 1:5", devotionalID: nil,
                             practice: "Take the decision you keep postponing and pray one sentence: “God, which way?” Then listen."),
                DayBlueprint(title: "He fights for you", verseRef: "Exodus 14:14", devotionalID: nil,
                             practice: "Pick one battle to stop fighting today — and consciously leave it in stronger hands."),
                DayBlueprint(title: "The detour is the route", verseRef: "Proverbs 19:21", devotionalID: "god-of-the-detour",
                             practice: "Write down one “ruined plan” from your past that turned out to be redirection."),
                DayBlueprint(title: "Lighter now", verseRef: "Matthew 11:28", devotionalID: "tired-is-not-a-sin",
                             practice: "Compare your load to day 1's list. What did you actually put down this week?")
            ]
        ),
        .tired: Arc(
            title: "Replenish",
            subtitle: "Seven days for a soul running on fumes",
            focuses: ["Burnout", "No margin", "Spiritually dry"],
            days: [
                DayBlueprint(title: "Come as you are", verseRef: "Matthew 11:28", devotionalID: "tired-is-not-a-sin",
                             practice: "Cancel one nonessential thing today. Rest is fuel, not reward."),
                DayBlueprint(title: "Lie down on purpose", verseRef: "Psalm 23:2-3", devotionalID: "the-rest-ethic",
                             practice: "Find your green pasture — the thing that actually restores you — and do it for 20 minutes."),
                DayBlueprint(title: "New batch of mercy", verseRef: "Lamentations 3:22-23", devotionalID: "new-every-morning",
                             practice: "Before your phone: one deep breath and the words “new every morning.”"),
                DayBlueprint(title: "Wings like eagles", verseRef: "Isaiah 40:31", devotionalID: nil,
                             practice: "Go to bed 30 minutes early tonight. Waiting on God includes sleeping."),
                DayBlueprint(title: "Abide, don't strive", verseRef: "John 15:5", devotionalID: nil,
                             practice: "Do one task today slowly, as if connection mattered more than completion — because it does."),
                DayBlueprint(title: "Grace for the unfinished", verseRef: "Philippians 1:6", devotionalID: "the-unfinished-work",
                             practice: "Forgive yourself one unfinished thing out loud. The Builder isn't behind schedule."),
                DayBlueprint(title: "Strength returns", verseRef: "Galatians 6:9", devotionalID: nil,
                             practice: "Note one place your energy came back this week. Thank God for it specifically.")
            ]
        ),
        .lonely: Arc(
            title: "Seen",
            subtitle: "Seven days of finding out you're not alone",
            focuses: ["Friendship drought", "Heartbreak", "Far from home"],
            days: [
                DayBlueprint(title: "Near to the broken", verseRef: "Psalm 34:18", devotionalID: "the-lonely-hour",
                             practice: "Tell God the loneliest part of your day — the specific hour, the specific room."),
                DayBlueprint(title: "Already loved", verseRef: "Jeremiah 31:3", devotionalID: "already-loved",
                             practice: "Write “already loved” on a note where you'll see it tomorrow morning."),
                DayBlueprint(title: "He binds wounds", verseRef: "Psalm 147:3", devotionalID: nil,
                             practice: "Name the wound honestly in your journal. Healing starts at the naming."),
                DayBlueprint(title: "Lean in first", verseRef: "Proverbs 17:17", devotionalID: "friendship-drift",
                             practice: "Send the “hey, I miss us” text you've been drafting in your head."),
                DayBlueprint(title: "Belonging", verseRef: "1 John 3:1", devotionalID: nil,
                             practice: "Join one thing this week — a circle here, a group, a table. One chair."),
                DayBlueprint(title: "Another chair", verseRef: "John 13:35", devotionalID: "homesick-at-church",
                             practice: "Think of someone else who might be lonely in plain sight. Be the one who leans in."),
                DayBlueprint(title: "Fullness of joy", verseRef: "Psalm 16:11", devotionalID: nil,
                             practice: "Look back at day 1. Where did presence — God's or people's — find you this week?")
            ]
        ),
        .tempted: Arc(
            title: "Clean",
            subtitle: "Seven days of grace stronger than the pull",
            focuses: ["Breaking a habit", "Guarding my heart", "Shame spiral"],
            days: [
                DayBlueprint(title: "A way out exists", verseRef: "1 Corinthians 10:13", devotionalID: nil,
                             practice: "Identify your trigger moment — the time, place, or feeling. Plan one exit before it arrives."),
                DayBlueprint(title: "No condemnation", verseRef: "Romans 8:1", devotionalID: "clean-slate",
                             practice: "Say what happened plainly to God. Honesty, not perfection, is the condition."),
                DayBlueprint(title: "Guard the wellspring", verseRef: "Proverbs 4:23", devotionalID: "the-situationship-audit",
                             practice: "Remove one easy access point today — the app, the contact, the bookmark."),
                DayBlueprint(title: "Renew the mind", verseRef: "Romans 12:2", devotionalID: "the-comparison-fast",
                             practice: "Replace the scroll with scripture once today. Same thumb, different feed."),
                DayBlueprint(title: "Watch and pray", verseRef: "Matthew 26:41", devotionalID: nil,
                             practice: "Pray at your weakest hour today — before it, not after."),
                DayBlueprint(title: "Nothing separates", verseRef: "Romans 8:38-39", devotionalID: "nothing-can-separate",
                             practice: "Write the sentence shame keeps saying — then write “nothing means nothing” under it."),
                DayBlueprint(title: "A clean heart", verseRef: "Psalm 51:10", devotionalID: nil,
                             practice: "Tell one safe person about this week's fight. Hidden battles stay heavy; shared ones don't.")
            ]
        ),
        .hopeful: Arc(
            title: "Build",
            subtitle: "Seven days of stewarding what's stirring",
            focuses: ["A new dream", "A new season", "A big decision"],
            days: [
                DayBlueprint(title: "Draft boldly", verseRef: "Proverbs 16:9", devotionalID: "quiet-ambition",
                             practice: "Write the dream in one sentence — the honest, too-big version."),
                DayBlueprint(title: "Springs out now", verseRef: "Isaiah 43:19", devotionalID: "the-wilderness-era",
                             practice: "List two small signs that something new is already underway."),
                DayBlueprint(title: "The delight clause", verseRef: "Psalm 37:4", devotionalID: "the-delight-clause",
                             practice: "Before asking God for the desire today, spend five minutes just enjoying Him."),
                DayBlueprint(title: "Commit the way", verseRef: "Psalm 37:5-6", devotionalID: nil,
                             practice: "Take one concrete step on the dream today — small counts."),
                DayBlueprint(title: "Exceedingly abundantly", verseRef: "Ephesians 3:20", devotionalID: nil,
                             practice: "Pray the too-big version out loud. Let the ask match the God."),
                DayBlueprint(title: "Work as worship", verseRef: "Colossians 3:23", devotionalID: "work-as-worship",
                             practice: "Re-address today's most tedious task to a different recipient: do it for Him."),
                DayBlueprint(title: "Laugh at the future", verseRef: "Proverbs 31:25", devotionalID: "clothed-in-strength",
                             practice: "Write a note to yourself one year from now. Seal it with confidence, not dread.")
            ]
        ),
        .grateful: Arc(
            title: "Overflow",
            subtitle: "Seven days of letting thanks change you",
            focuses: ["Counting gifts", "Giving back", "Staying soft"],
            days: [
                DayBlueprint(title: "Begin the count", verseRef: "Psalm 136:1", devotionalID: nil,
                             practice: "List ten specific gifts from this week. Small ones count double."),
                DayBlueprint(title: "In everything", verseRef: "1 Thessalonians 5:18", devotionalID: nil,
                             practice: "Find one thanks inside the hard thing — not for it, but inside it."),
                DayBlueprint(title: "Where your treasure is", verseRef: "Matthew 6:21", devotionalID: "provision-math",
                             practice: "Give something away today — money, time, or the parking spot."),
                DayBlueprint(title: "Say it out loud", verseRef: "Psalm 118:24", devotionalID: nil,
                             practice: "Thank one person specifically for something they think nobody noticed."),
                DayBlueprint(title: "The smallest ministry", verseRef: "1 Corinthians 16:14", devotionalID: "do-it-in-love",
                             practice: "Run one routine task today at a warmer temperature."),
                DayBlueprint(title: "Radiance is directional", verseRef: "Psalm 34:5", devotionalID: "the-radiance-routine",
                             practice: "Give God your first look of the day tomorrow — before the feed."),
                DayBlueprint(title: "Overflow", verseRef: "Zephaniah 3:17", devotionalID: nil,
                             practice: "Reread your day 1 list. Share one gift from it with a friend — gratitude multiplies spoken.")
            ]
        ),
        .joyful: Arc(
            title: "Radiant",
            subtitle: "Seven days of joy that spreads",
            focuses: ["Celebrating well", "Sharing the light", "Staying grounded"],
            days: [
                DayBlueprint(title: "This is the day", verseRef: "Psalm 118:24", devotionalID: nil,
                             practice: "Celebrate on purpose today — name the win, mark it, don't rush past it."),
                DayBlueprint(title: "Light of the world", verseRef: "Matthew 5:14", devotionalID: nil,
                             practice: "Let one person see your joy up close today. Hidden light helps no one."),
                DayBlueprint(title: "He rejoices over you", verseRef: "Zephaniah 3:17", devotionalID: nil,
                             practice: "Sit with this: God is glad about you. Not your output. You."),
                DayBlueprint(title: "Fearfully, wonderfully", verseRef: "Psalm 139:14", devotionalID: "fearfully-wonderfully",
                             practice: "Thank God for one thing about how you're made — out loud, no critique allowed."),
                DayBlueprint(title: "Joy is loyal", verseRef: "Romans 12:12", devotionalID: nil,
                             practice: "Check on a friend in a harder season. Joy that shares itself keeps."),
                DayBlueprint(title: "Build someone", verseRef: "Ephesians 4:29", devotionalID: "the-group-chat",
                             practice: "Say something load-bearing about someone who isn't in the room."),
                DayBlueprint(title: "Winter is past", verseRef: "Song of Solomon 2:11-12", devotionalID: "winter-is-past",
                             practice: "Write down what this season of joy followed. You'll want the record later.")
            ]
        )
    ]

    /// Compose a personalized syllabus: curated arc + this person's actual life.
    @MainActor
    static func compose(mood: Mood, focus: String?, store: UserStore) -> Syllabus {
        let arc = arcs[mood] ?? arcs[.hopeful]!
        var days = arc.days.enumerated().map { i, bp in
            SyllabusDay(index: i + 1, title: bp.title, verseRef: bp.verseRef,
                        devotionalID: bp.devotionalID, practice: bp.practice)
        }

        // Weave their open prayer into midweek — the plan knows what they're carrying.
        if let prayer = store.openPrayers.first, days.count >= 3 {
            let excerpt = String(prayer.text.prefix(70))
            days[2] = SyllabusDay(
                index: 3, title: days[2].title, verseRef: days[2].verseRef,
                devotionalID: days[2].devotionalID,
                practice: "Pray today's verse directly over what you laid in your Vault: “\(excerpt)…”"
            )
        }

        // If their journal shows a weekday pattern, day 5 names it.
        if let pattern = store.moodPattern, pattern.mood == mood, days.count >= 5 {
            days[4] = SyllabusDay(
                index: 5, title: days[4].title, verseRef: days[4].verseRef,
                devotionalID: days[4].devotionalID,
                practice: "Your journal says \(pattern.weekday)s tend to feel \(pattern.mood.rawValue). Pray today's verse ahead of the next one — get there first."
            )
        }

        let name = store.name.isEmpty ? "you" : store.name
        var subtitle = arc.subtitle
        if let focus, !focus.isEmpty {
            subtitle = "\(arc.subtitle) — written for \(name), centered on \(focus.lowercased())"
        } else {
            subtitle = "\(arc.subtitle) — written for \(name)"
        }

        return Syllabus(id: UUID(), title: arc.title, subtitle: subtitle,
                        mood: mood, createdAt: Date(), days: days)
    }
}
