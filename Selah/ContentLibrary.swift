import Foundation

// MARK: - Bundled content — zero-cost, fully offline.
// Scripture text: World English Bible (public domain).

enum ContentLibrary {

    // MARK: Verses

    static let verses: [Verse] = [
        Verse(text: "Don't be anxious about anything, but in everything, by prayer and petition with thanksgiving, let your requests be made known to God.", reference: "Philippians 4:6", moods: [.anxious, .overwhelmed], topics: ["peace", "worry", "prayer"]),
        Verse(text: "Come to me, all you who labor and are heavily burdened, and I will give you rest.", reference: "Matthew 11:28", moods: [.tired, .overwhelmed], topics: ["rest", "burnout"]),
        Verse(text: "I can do all things through Christ who strengthens me.", reference: "Philippians 4:13", moods: [.hopeful, .tired], topics: ["strength", "ambition"]),
        Verse(text: "Be still, and know that I am God.", reference: "Psalm 46:10", moods: [.anxious, .overwhelmed], topics: ["peace", "stillness"]),
        Verse(text: "For I know the thoughts that I think toward you, says the LORD, thoughts of peace, and not of evil, to give you hope and a future.", reference: "Jeremiah 29:11", moods: [.hopeful, .anxious], topics: ["future", "purpose", "career"]),
        Verse(text: "The LORD is my shepherd; I shall lack nothing.", reference: "Psalm 23:1", moods: [.grateful, .anxious], topics: ["provision", "trust"]),
        Verse(text: "Trust in the LORD with all your heart, and don't lean on your own understanding.", reference: "Proverbs 3:5", moods: [.overwhelmed, .hopeful], topics: ["trust", "decisions"]),
        Verse(text: "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me.", reference: "Psalm 23:4", moods: [.lonely, .anxious], topics: ["fear", "presence"]),
        Verse(text: "Cast all your worries on him, because he cares for you.", reference: "1 Peter 5:7", moods: [.anxious, .overwhelmed], topics: ["worry", "care"]),
        Verse(text: "This is the day that the LORD has made. We will rejoice and be glad in it!", reference: "Psalm 118:24", moods: [.joyful, .grateful], topics: ["joy", "morning"]),
        Verse(text: "The LORD your God is among you, a mighty one who will save. He will rejoice over you with joy. He will quiet you with his love.", reference: "Zephaniah 3:17", moods: [.lonely, .joyful], topics: ["love", "identity"]),
        Verse(text: "No temptation has taken you except what is common to man. God is faithful, who will not allow you to be tempted above what you are able.", reference: "1 Corinthians 10:13", moods: [.tempted], topics: ["temptation", "self-control"]),
        Verse(text: "Watch and pray, that you don't enter into temptation. The spirit indeed is willing, but the flesh is weak.", reference: "Matthew 26:41", moods: [.tempted], topics: ["temptation", "discipline"]),
        Verse(text: "Give thanks to the LORD, for he is good, for his loving kindness endures forever.", reference: "Psalm 136:1", moods: [.grateful, .joyful], topics: ["gratitude"]),
        Verse(text: "But those who wait for the LORD will renew their strength. They will mount up with wings like eagles.", reference: "Isaiah 40:31", moods: [.tired, .hopeful], topics: ["strength", "patience"]),
        Verse(text: "God is our refuge and strength, a very present help in trouble.", reference: "Psalm 46:1", moods: [.anxious, .overwhelmed], topics: ["refuge", "crisis"]),
        Verse(text: "Draw near to God, and he will draw near to you.", reference: "James 4:8", moods: [.lonely, .hopeful], topics: ["intimacy", "return"]),
        Verse(text: "Create in me a clean heart, O God. Renew a right spirit within me.", reference: "Psalm 51:10", moods: [.tempted], topics: ["renewal", "forgiveness"]),
        Verse(text: "There is therefore now no condemnation to those who are in Christ Jesus.", reference: "Romans 8:1", moods: [.tempted, .lonely], topics: ["grace", "shame"]),
        Verse(text: "We know that all things work together for good for those who love God.", reference: "Romans 8:28", moods: [.hopeful, .overwhelmed], topics: ["purpose", "setbacks"]),
        Verse(text: "Let's not be weary in doing good, for we will reap in due season if we don't give up.", reference: "Galatians 6:9", moods: [.tired, .hopeful], topics: ["perseverance", "ambition"]),
        Verse(text: "In the morning, LORD, you will hear my voice. In the morning I will lay my requests before you, and will watch expectantly.", reference: "Psalm 5:3", moods: [.hopeful, .grateful], topics: ["morning", "prayer"]),
        Verse(text: "When I am afraid, I will put my trust in you.", reference: "Psalm 56:3", moods: [.anxious], topics: ["fear", "trust"]),
        Verse(text: "A man's heart plans his course, but the LORD directs his steps.", reference: "Proverbs 16:9", moods: [.hopeful, .overwhelmed], topics: ["decisions", "career", "future"]),
        Verse(text: "Love is patient and is kind. Love doesn't envy. Love doesn't brag, is not proud.", reference: "1 Corinthians 13:4", moods: [.joyful, .lonely], topics: ["love", "relationships"]),
        Verse(text: "Above all things, guard your heart, for out of it is the wellspring of life.", reference: "Proverbs 4:23", moods: [.tempted], topics: ["relationships", "purity", "heart", "dating"]),
        Verse(text: "How can a young man keep his way pure? By living according to your word.", reference: "Psalm 119:9", moods: [.tempted, .hopeful], topics: ["purity", "youth"]),
        Verse(text: "Don't be conformed to this world, but be transformed by the renewing of your mind.", reference: "Romans 12:2", moods: [.tempted, .hopeful], topics: ["identity", "culture", "mind"]),
        Verse(text: "You are the light of the world. A city located on a hill can't be hidden.", reference: "Matthew 5:14", moods: [.joyful, .hopeful], topics: ["purpose", "influence"]),
        Verse(text: "Yahweh is near to those who have a broken heart, and saves those who have a crushed spirit.", reference: "Psalm 34:18", moods: [.lonely], topics: ["heartbreak", "grief"]),
        Verse(text: "He heals the broken in heart, and binds up their wounds.", reference: "Psalm 147:3", moods: [.lonely], topics: ["heartbreak", "healing"]),
        Verse(text: "For where your treasure is, there your heart will be also.", reference: "Matthew 6:21", moods: [.grateful], topics: ["money", "priorities"]),
        Verse(text: "Seek first God's Kingdom and his righteousness, and all these things will be given to you as well.", reference: "Matthew 6:33", moods: [.anxious, .hopeful], topics: ["money", "provision", "priorities"]),
        Verse(text: "By this everyone will know that you are my disciples, if you have love for one another.", reference: "John 13:35", moods: [.joyful], topics: ["community", "love"]),
        Verse(text: "Iron sharpens iron; so a man sharpens his friend's countenance.", reference: "Proverbs 27:17", moods: [.joyful, .hopeful], topics: ["friendship", "community"]),
        Verse(text: "Come near to God and he will come near to you. In your presence is fullness of joy.", reference: "Psalm 16:11", moods: [.joyful, .lonely], topics: ["presence", "joy"]),
        Verse(text: "The LORD will fight for you, and you shall be still.", reference: "Exodus 14:14", moods: [.overwhelmed, .anxious], topics: ["battles", "rest"]),
        Verse(text: "My grace is sufficient for you, for my power is made perfect in weakness.", reference: "2 Corinthians 12:9", moods: [.tired, .lonely], topics: ["grace", "weakness"]),
        Verse(text: "If we confess our sins, he is faithful and righteous to forgive us the sins, and to cleanse us from all unrighteousness.", reference: "1 John 1:9", moods: [.tempted], topics: ["forgiveness", "confession"]),
        Verse(text: "In everything give thanks, for this is the will of God in Christ Jesus toward you.", reference: "1 Thessalonians 5:18", moods: [.grateful], topics: ["gratitude"]),
        Verse(text: "Yahweh bless you, and keep you. Yahweh make his face to shine on you, and be gracious to you.", reference: "Numbers 6:24-25", moods: [.grateful, .hopeful], topics: ["blessing", "evening"]),
        Verse(text: "In peace I will both lay myself down and sleep, for you alone, Yahweh, make me live in safety.", reference: "Psalm 4:8", moods: [.tired, .anxious], topics: ["sleep", "evening", "peace"]),

        // — Expanded library —
        Verse(text: "God is within her. She shall not be moved. God will help her at dawn.", reference: "Psalm 46:5", moods: [.anxious, .hopeful], topics: ["identity", "strength", "morning"]),
        Verse(text: "Strength and dignity are her clothing. She laughs at the time to come.", reference: "Proverbs 31:25", moods: [.hopeful, .joyful], topics: ["identity", "future", "confidence"]),
        Verse(text: "I will give thanks to you, for I am fearfully and wonderfully made. Your works are wonderful. My soul knows that very well.", reference: "Psalm 139:14", moods: [.lonely, .grateful], topics: ["identity", "body", "worth"]),
        Verse(text: "They looked to him, and were radiant. Their faces shall never be covered with shame.", reference: "Psalm 34:5", moods: [.joyful, .hopeful], topics: ["identity", "shame", "beauty"]),
        Verse(text: "Man looks at the outward appearance, but Yahweh looks at the heart.", reference: "1 Samuel 16:7", moods: [.lonely, .hopeful], topics: ["body", "worth", "appearance"]),
        Verse(text: "Don't you be afraid, for I am with you. Don't be dismayed, for I am your God. I will strengthen you. Yes, I will help you.", reference: "Isaiah 41:10", moods: [.anxious, .overwhelmed], topics: ["fear", "strength", "presence"]),
        Verse(text: "It is because of Yahweh's loving kindnesses that we are not consumed, because his compassion doesn't fail. They are new every morning.", reference: "Lamentations 3:22-23", moods: [.tired, .hopeful], topics: ["morning", "mercy", "restart"]),
        Verse(text: "For God didn't give us a spirit of fear, but of power, love, and self-control.", reference: "2 Timothy 1:7", moods: [.anxious, .hopeful], topics: ["fear", "courage", "mind"]),
        Verse(text: "Am I now seeking the favor of men, or of God? For if I were still pleasing men, I wouldn't be a servant of Christ.", reference: "Galatians 1:10", moods: [.overwhelmed, .tempted], topics: ["people-pleasing", "approval", "boundaries"]),
        Verse(text: "Be strong and courageous. Don't be afraid. Don't be dismayed, for Yahweh your God is with you wherever you go.", reference: "Joshua 1:9", moods: [.anxious, .hopeful], topics: ["courage", "new-seasons", "moving"]),
        Verse(text: "Therefore don't be anxious for tomorrow, for tomorrow will be anxious for itself. Each day's own evil is sufficient.", reference: "Matthew 6:34", moods: [.anxious, .overwhelmed], topics: ["worry", "future", "overthinking"]),
        Verse(text: "Weeping may stay for the night, but joy comes in the morning.", reference: "Psalm 30:5", moods: [.lonely, .hopeful], topics: ["grief", "hope", "morning"]),
        Verse(text: "Yahweh himself is who goes before you. He will be with you. He will not fail you nor forsake you.", reference: "Deuteronomy 31:8", moods: [.anxious, .hopeful], topics: ["future", "new-seasons", "presence"]),
        Verse(text: "I have loved you with an everlasting love. Therefore I have drawn you with loving kindness.", reference: "Jeremiah 31:3", moods: [.lonely, .grateful], topics: ["love", "worth", "identity"]),
        Verse(text: "For we are his workmanship, created in Christ Jesus for good works, which God prepared before that we would walk in them.", reference: "Ephesians 2:10", moods: [.hopeful], topics: ["purpose", "identity", "calling"]),
        Verse(text: "He who began a good work in you will complete it until the day of Jesus Christ.", reference: "Philippians 1:6", moods: [.hopeful, .tired], topics: ["growth", "becoming", "patience"]),
        Verse(text: "When you pass through the waters, I will be with you, and through the rivers, they will not overflow you.", reference: "Isaiah 43:2", moods: [.overwhelmed, .anxious], topics: ["crisis", "presence", "trials"]),
        Verse(text: "Behold, I will do a new thing. It springs out now. Don't you know it? I will even make a way in the wilderness.", reference: "Isaiah 43:19", moods: [.hopeful], topics: ["new-seasons", "change", "future"]),
        Verse(text: "Also delight yourself in Yahweh, and he will give you the desires of your heart.", reference: "Psalm 37:4", moods: [.hopeful, .joyful], topics: ["desires", "dreams", "waiting"]),
        Verse(text: "Now may the God of hope fill you with all joy and peace in believing, that you may abound in hope.", reference: "Romans 15:13", moods: [.hopeful, .joyful], topics: ["hope", "peace"]),
        Verse(text: "In the world you have trouble; but cheer up! I have overcome the world.", reference: "John 16:33", moods: [.overwhelmed, .hopeful], topics: ["trials", "courage"]),
        Verse(text: "Why are you in despair, my soul? Why are you disturbed within me? Hope in God, for I shall still praise him.", reference: "Psalm 42:11", moods: [.lonely, .tired], topics: ["sadness", "hope", "honesty"]),
        Verse(text: "Now to him who is able to do exceedingly abundantly above all that we ask or think.", reference: "Ephesians 3:20", moods: [.hopeful, .grateful], topics: ["dreams", "prayer", "future"]),
        Verse(text: "No good thing will he withhold from those who walk blamelessly.", reference: "Psalm 84:11", moods: [.hopeful, .anxious], topics: ["waiting", "trust", "comparison"]),
        Verse(text: "If any of you lacks wisdom, let him ask of God, who gives to all liberally and without reproach.", reference: "James 1:5", moods: [.overwhelmed], topics: ["wisdom", "decisions"]),
        Verse(text: "Ask, and it will be given you. Seek, and you will find. Knock, and it will be opened for you.", reference: "Matthew 7:7", moods: [.hopeful], topics: ["prayer", "asking"]),
        Verse(text: "I am the vine. You are the branches. He who remains in me and I in him bears much fruit, for apart from me you can do nothing.", reference: "John 15:5", moods: [.tired, .hopeful], topics: ["abiding", "rest", "growth"]),
        Verse(text: "Let's run with perseverance the race that is set before us, looking to Jesus, the author and perfecter of faith.", reference: "Hebrews 12:1-2", moods: [.tired, .hopeful], topics: ["perseverance", "focus"]),
        Verse(text: "He has shown you, O man, what is good. What does Yahweh require of you, but to act justly, to love mercy, and to walk humbly with your God?", reference: "Micah 6:8", moods: [.hopeful], topics: ["purpose", "simplicity"]),
        Verse(text: "For everything there is a season, and a time for every purpose under heaven.", reference: "Ecclesiastes 3:1", moods: [.overwhelmed, .hopeful], topics: ["seasons", "change", "patience"]),
        Verse(text: "In all your ways acknowledge him, and he will make your paths straight.", reference: "Proverbs 3:6", moods: [.hopeful], topics: ["decisions", "direction"]),
        Verse(text: "There are many plans in a man's heart, but Yahweh's counsel will prevail.", reference: "Proverbs 19:21", moods: [.overwhelmed, .hopeful], topics: ["plans", "detours", "surrender"]),
        Verse(text: "I will lift up my eyes to the hills. Where does my help come from? My help comes from Yahweh, who made heaven and earth.", reference: "Psalm 121:1-2", moods: [.overwhelmed, .anxious], topics: ["help", "trust"]),
        Verse(text: "He who dwells in the secret place of the Most High will rest in the shadow of the Almighty.", reference: "Psalm 91:1", moods: [.anxious, .tired], topics: ["refuge", "rest", "safety"]),
        Verse(text: "Wait for Yahweh. Be strong, and let your heart take courage. Yes, wait for Yahweh.", reference: "Psalm 27:14", moods: [.hopeful, .tired], topics: ["waiting", "courage", "singleness"]),
        Verse(text: "Let your beauty come from the hidden person of the heart, in the incorruptible adornment of a gentle and quiet spirit, which is very precious in God's sight.", reference: "1 Peter 3:4", moods: [.joyful, .hopeful], topics: ["beauty", "identity", "heart"]),
        Verse(text: "Don't you know that your body is a temple of the Holy Spirit who is in you? Therefore glorify God in your body.", reference: "1 Corinthians 6:19-20", moods: [.tempted, .hopeful], topics: ["body", "purity", "worth"]),
        Verse(text: "Whatever you do, work heartily, as for the Lord, and not for men.", reference: "Colossians 3:23", moods: [.tired, .hopeful], topics: ["work", "career", "excellence"]),
        Verse(text: "Put on therefore, as God's chosen ones, holy and beloved, a heart of compassion, kindness, lowliness, humility, and perseverance.", reference: "Colossians 3:12", moods: [.joyful, .grateful], topics: ["kindness", "character"]),
        Verse(text: "Neither death, nor life, nor things present, nor things to come, will be able to separate us from the love of God.", reference: "Romans 8:38-39", moods: [.lonely, .tempted], topics: ["love", "shame", "security"]),
        Verse(text: "Let all that you do be done in love.", reference: "1 Corinthians 16:14", moods: [.joyful, .grateful], topics: ["love", "kindness", "daily-life"]),
        Verse(text: "For, behold, the winter is past. The rain is over and gone. The flowers appear on the earth. The time of the singing has come.", reference: "Song of Solomon 2:11-12", moods: [.hopeful, .joyful], topics: ["new-seasons", "healing", "heartbreak"]),
        Verse(text: "He makes me lie down in green pastures. He leads me beside still waters. He restores my soul.", reference: "Psalm 23:2-3", moods: [.tired, .overwhelmed], topics: ["rest", "restoration", "peace"]),
        Verse(text: "You will keep whoever's mind is steadfast in perfect peace, because he trusts in you.", reference: "Isaiah 26:3", moods: [.anxious, .overwhelmed], topics: ["peace", "mind", "overthinking"]),
        Verse(text: "A friend loves at all times; and a brother is born for adversity.", reference: "Proverbs 17:17", moods: [.lonely, .grateful], topics: ["friendship", "loyalty"]),
        Verse(text: "Let no corrupt speech proceed out of your mouth, but only what is good for building others up as the need may be.", reference: "Ephesians 4:29", moods: [.tempted, .joyful], topics: ["words", "gossip", "speech"]),
        Verse(text: "But let your 'Yes' be 'Yes' and your 'No' be 'No.'", reference: "Matthew 5:37", moods: [.overwhelmed], topics: ["boundaries", "honesty"]),
        Verse(text: "See how great a love the Father has given to us, that we should be called children of God.", reference: "1 John 3:1", moods: [.grateful, .lonely], topics: ["identity", "love", "belonging"]),
        Verse(text: "Don't hide your face from me in the day of my distress. Turn your ear to me. Answer me quickly in the day when I call.", reference: "Psalm 102:2", moods: [.lonely, .overwhelmed], topics: ["honesty", "crisis", "prayer"]),
        Verse(text: "Yahweh is good to those who wait for him, to the soul who seeks him.", reference: "Lamentations 3:25", moods: [.hopeful, .tired], topics: ["waiting", "seeking"]),
        Verse(text: "Commit your way to Yahweh. Trust also in him, and he will do this: he will make your righteousness shine out like light.", reference: "Psalm 37:5-6", moods: [.hopeful], topics: ["trust", "surrender", "dreams"]),
        Verse(text: "Blessed are those who mourn, for they shall be comforted.", reference: "Matthew 5:4", moods: [.lonely], topics: ["grief", "comfort"]),
        Verse(text: "Rejoice in hope. Endure in troubles. Continue steadfastly in prayer.", reference: "Romans 12:12", moods: [.tired, .hopeful], topics: ["endurance", "prayer", "hope"])
    ]

    static var verseOfToday: Verse {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return verses[day % verses.count]
    }

    static func verses(for mood: Mood) -> [Verse] {
        verses.filter { $0.moods.contains(mood) }
    }

    static func verses(matching text: String) -> [Verse] {
        let lower = text.lowercased()
        let hits = verses.filter { v in
            v.topics.contains { lower.contains($0) }
        }
        return hits.isEmpty ? [verses.randomElement()!] : hits
    }

    /// Look up a verse by its reference; falls back to the verse of the day.
    static func verse(_ reference: String) -> Verse {
        verses.first { $0.reference == reference } ?? verseOfToday
    }

    // MARK: Devotionals — a 5-week rotation, one per day.

    static let devotionals: [Devotional] = [
        Devotional(
            id: "quiet-ambition", title: "Quiet Ambition",
            verse: verse("Proverbs 16:9"),
            body: "You have plans — the career, the platform, the life you keep building in your head at 1 a.m. None of that is wrong. Scripture never asks you to shrink your ambition; it asks you to hand over the steering. \"A man's heart plans his course, but the LORD directs his steps.\" The plan is yours to draft. The route is His to direct. The peace you're looking for lives in that division of labor.",
            reflection: "What's one plan you're gripping so tightly that God couldn't redirect it without a fight?",
            prayer: "Father, I bring You my ambition instead of hiding it from You. Direct my steps even when they diverge from my draft. Give me the courage to build and the humility to be redirected. Amen."
        ),
        Devotional(
            id: "the-comparison-fast", title: "The Comparison Fast",
            verse: verse("Romans 12:2"),
            body: "You checked the feed before your feet hit the floor. Someone got engaged. Someone got promoted. Someone's in Santorini. And a quiet verdict landed on your morning: behind. \"Don't be conformed to this world, but be transformed by the renewing of your mind.\" Conformity today isn't just behavior — it's letting an algorithm set your definition of enough. Renewal starts by choosing whose voice gets the first word of your day.",
            reflection: "Whose life did you compare yours to this week — and what did it cost you?",
            prayer: "Lord, renew my mind faster than the feed can shape it. Untangle my worth from the metrics. Let me want the life You're building, not the one I'm scrolling past. Amen."
        ),
        Devotional(
            id: "tired-is-not-a-sin", title: "Tired Is Not a Sin",
            verse: verse("Matthew 11:28"),
            body: "Somewhere along the way you started treating exhaustion like a virtue and rest like a confession of weakness. Jesus disagrees. \"Come to me, all you who labor and are heavily burdened, and I will give you rest.\" He doesn't say prove yourself first. He doesn't say once the semester ends. The invitation is present tense. Rest isn't the reward for finishing the work; it's the fuel for doing it.",
            reflection: "What would it look like to actually stop for fifteen minutes today — no screen, no guilt?",
            prayer: "Jesus, I've been running on fumes and calling it faithfulness. Teach me Your unforced rhythm of grace. I accept the rest You offer — not later, now. Amen."
        ),
        Devotional(
            id: "the-lonely-hour", title: "The Lonely Hour",
            verse: verse("Psalm 34:18"),
            body: "There's a specific kind of lonely that hits in a crowded room — surrounded, seen by no one. \"Yahweh is near to those who have a broken heart.\" Near. Not watching from a distance, not waiting for you to pull yourself together. The Hebrew word carries the sense of a neighbor close enough to hear you through the wall. You don't have to raise your voice tonight. He's already leaning in.",
            reflection: "Who in your life might be lonely in plain sight — and could you be the one who leans in?",
            prayer: "God, in the hour when no one texts back, You are near. Make Your presence more real than my isolation, and then make me that presence for someone else. Amen."
        ),
        Devotional(
            id: "clean-slate", title: "Clean Slate",
            verse: verse("1 John 1:9"),
            body: "You told yourself last time was the last time, and then it wasn't. Now shame is running its familiar script: don't pray now, not like this. But read the verse again — \"If we confess our sins, he is faithful and righteous to forgive.\" The condition isn't perfection; it's honesty. Confession isn't groveling. It's agreeing with God about what happened and letting Him do what only He does: make it clean.",
            reflection: "What have you been avoiding saying to God because you've said it before?",
            prayer: "Father, I'm done negotiating with shame. I confess it plainly and receive what You promised — forgiveness, cleansing, another morning. Keep me honest and keep me close. Amen."
        ),
        Devotional(
            id: "provision-math", title: "Provision Math",
            verse: verse("Matthew 6:33"),
            body: "Rent, loans, the number in your account that you check and re-check as if staring changes it. Jesus talked about money more than almost anything, and His math was strange: \"Seek first God's Kingdom... and all these things will be given to you as well.\" Not seek only. Seek first. The order of operations is the whole point. Anxiety puts provision first and God somewhere after; faith flips the sequence and finds the anxiety loses its grip.",
            reflection: "What's one financial worry you can name out loud to God today instead of carrying silently?",
            prayer: "Provider, You know my numbers better than I do. I put Your Kingdom back at the top of the sequence and trust You with the remainder. Amen."
        ),
        Devotional(
            id: "let-your-hands-drop", title: "Let Your Hands Drop",
            verse: verse("Psalm 46:10"),
            body: "\"Be still, and know that I am God.\" In Hebrew, be still — raphah — literally means let your hands drop. Stop gripping. The verse isn't a scented-candle sentiment; it's a command issued in the middle of a psalm about nations collapsing. Stillness isn't the absence of chaos. It's the decision to unclench inside it, because Someone stronger is holding what you keep trying to hold.",
            reflection: "What are you holding right now that was never yours to carry?",
            prayer: "God, I drop my hands. The outcomes, the timelines, the people I can't fix — I release my grip and remember that You were holding all of it anyway. Amen."
        ),
        Devotional(
            id: "she-shall-not-be-moved", title: "She Shall Not Be Moved",
            verse: verse("Psalm 46:5"),
            body: "\"God is within her. She shall not be moved. God will help her at dawn.\" Notice what the verse doesn't say. It doesn't say nothing will shake around her. The psalm is full of shaking — waters roaring, mountains trembling. It says she won't be moved, because of who is within her. Your steadiness was never supposed to come from a stable semester, a secure relationship, or a five-year plan that behaves. It comes from residency. He's not near you. He's in you.",
            reflection: "What currently feels like it's shaking — and what would 'unmoved' look like inside it?",
            prayer: "God, be louder in me than the shaking around me. When everything moves, remind me that You don't. Help me at dawn, like You promised. Amen."
        ),
        Devotional(
            id: "clothed-in-strength", title: "Laughing at the Future",
            verse: verse("Proverbs 31:25"),
            body: "\"Strength and dignity are her clothing. She laughs at the time to come.\" She laughs — not because the future is guaranteed easy, but because she's decided in advance who will be with her in it. Most of us dress for the future in dread: rehearsing worst cases, pre-living disasters that never arrive. This woman gets dressed differently. Strength and dignity aren't moods; they're a wardrobe you choose each morning. Put them on before you put on anything else.",
            reflection: "If you truly believed God was already in your future, what would you stop rehearsing?",
            prayer: "Father, dress me in strength and dignity today. Teach me to laugh at the time to come — not carelessly, but confidently, because You're already there. Amen."
        ),
        Devotional(
            id: "the-radiance-routine", title: "The Radiance Routine",
            verse: verse("Psalm 34:5"),
            body: "You have a routine for your skin. Cleanser, serum, the SPF you actually remember most days. Scripture has a one-step routine for your face: \"They looked to him, and were radiant.\" Radiance, it turns out, is directional — it comes from what you spend your attention on. Look at the feed long enough and you wear the anxiety. Look at Him first, and something in your face changes that no highlighter replicates. Glow is a byproduct of gaze.",
            reflection: "What gets your first look of the day — and what does it leave on your face?",
            prayer: "Lord, I turn my face toward You before anything else today. Make me radiant from the inside — unashamed, unhurried, unmistakably Yours. Amen."
        ),
        Devotional(
            id: "fearfully-wonderfully", title: "Fearfully, Wonderfully",
            verse: verse("Psalm 139:14"),
            body: "You know the angles you avoid in photos. The features you'd trade. The quiet audit you run every time you pass a mirror. Now hear David interrupt it: \"I am fearfully and wonderfully made.\" He says it as praise — not because he passed some ancient beauty standard, but because he understood who did the making. Criticizing the work insults the Artist. Your body is not a rough draft your discipline needs to fix. It's a signed original.",
            reflection: "What's one thing about how you're made that you could thank God for today instead of critiquing?",
            prayer: "Creator, You made me on purpose, with intention I don't always see. Quiet the audit. Teach my soul to know — really know — that Your work is wonderful. Amen."
        ),
        Devotional(
            id: "the-mirror-lies", title: "What the Mirror Can't See",
            verse: verse("1 Samuel 16:7"),
            body: "Samuel was sure the tall, impressive brother was the chosen one. God said no — and then said why: \"Man looks at the outward appearance, but Yahweh looks at the heart.\" Everything in your world is trained on the outside: the camera, the fitting room, the metrics. God's attention is fixed somewhere no filter reaches. That's not a consolation prize for the unphotogenic. It's the actual scoreboard. The thing God finds beautiful in you is the thing you've maybe never posted.",
            reflection: "If God described what He sees in your heart right now, what do you hope He'd say?",
            prayer: "Father, You see past everything I curate. Grow the hidden person of my heart until what You see and what I show are the same woman. Amen."
        ),
        Devotional(
            id: "new-every-morning", title: "New Every Morning",
            verse: verse("Lamentations 3:22-23"),
            body: "This verse lives in the saddest book of the Bible. Jeremiah writes it sitting in the rubble of everything he loved — and that's exactly why it holds. \"His compassion doesn't fail. They are new every morning.\" Not recycled. Not leftover grace from a better week. New. Whatever yesterday was — the argument, the relapse, the deadline you missed, the text you shouldn't have sent — it doesn't roll over. God's mercy runs on a daily reset, and today's batch was made for today's mess.",
            reflection: "What from yesterday are you still carrying that God has already reset?",
            prayer: "God, thank You that Your mercy doesn't have a memory like mine. I take today's grace for today's need, and I leave yesterday where You left it. Amen."
        ),
        Devotional(
            id: "the-situationship-audit", title: "The Situationship Audit",
            verse: verse("Proverbs 4:23"),
            body: "\"Above all things, guard your heart, for out of it is the wellspring of life.\" Above all things — that's high-priority language for the part of you handing itself to someone who won't define the relationship. Guarding your heart doesn't mean walls and cynicism. It means treating access to you like it costs something, because it does. Clarity is not too much to ask. Consistency is not too much to ask. If naming it ends it, it was never going where you hoped.",
            reflection: "Is there anywhere you're trading your peace for someone's potential?",
            prayer: "Lord, give me the courage to ask clear questions and hear honest answers. Guard my heart where I've left the door propped open. I trust You with the ones who walk away. Amen."
        ),
        Devotional(
            id: "unfollow", title: "The Approval Detox",
            verse: verse("Galatians 1:10"),
            body: "\"If I were still pleasing men, I wouldn't be a servant of Christ.\" Paul writes it like a math proof: you cannot maximize both. Somewhere today you'll feel the pull — shrink the conviction, laugh at the thing that isn't funny, say yes when your whole chest says no — because someone's approval feels load-bearing. It isn't. The exhausting career of managing everyone's opinion of you has no retirement plan. Serving an audience of One is the only job with rest in it.",
            reflection: "Whose approval are you working for that God never assigned you?",
            prayer: "Father, I resign from managing everyone's opinion of me. Make Your 'well done' the only review I refresh. Amen."
        ),
        Devotional(
            id: "yes-and-no", title: "Let Your No Be No",
            verse: verse("Matthew 5:37"),
            body: "\"Let your 'Yes' be 'Yes' and your 'No' be 'No.'\" Jesus said this about oaths, but it lands on every over-explained, guilt-padded text you've ever drafted and re-drafted. A boundary isn't unkind. A no doesn't need a paragraph of justification and three apologies. People who require you to abandon yourself to keep them were never offering relationship — they were offering a job. Holy honesty is lighter than managed niceness, and it's the only version of you that can actually love people.",
            reflection: "Where are you saying a padded yes that needs to become a clean no?",
            prayer: "Jesus, make me honest before I'm agreeable. Give me a yes with my whole heart behind it and a no I don't have to apologize for. Amen."
        ),
        Devotional(
            id: "while-you-wait", title: "While You Wait",
            verse: verse("Psalm 27:14"),
            body: "\"Wait for Yahweh. Be strong, and let your heart take courage.\" Notice that waiting, in scripture, is not passive. It's not the DMV. It takes strength and courage — because real waiting means staying soft and hopeful in a season that hands you no evidence. The friend group pairing off, the career that hasn't clicked, the prayer with no reply yet. Waiting on God is an active posture: building, praying, becoming — with your eyes still up. The wait is not wasted. It's where the roots go down.",
            reflection: "What are you waiting on — and what is God growing in you while you wait?",
            prayer: "Lord, make my waiting active and my heart courageous. Grow roots in me now that the coming season will need. Amen."
        ),
        Devotional(
            id: "the-delight-clause", title: "The Delight Clause",
            verse: verse("Psalm 37:4"),
            body: "\"Delight yourself in Yahweh, and he will give you the desires of your heart.\" We usually read this as a vending machine: insert delight, receive desires. But live with the verse a while and it turns inside out. Delight yourself in Him and your desires start changing shape — some intensify, some quietly fall off the list, and new ones appear you'd never have drafted. God isn't only promising to give you what your heart wants. He's offering to be the one who forms what it wants.",
            reflection: "How have your desires changed in the seasons you were closest to God?",
            prayer: "Father, I bring You my honest wants — the noble ones and the messy ones. Delight me in Yourself until my desires are worth granting. Amen."
        ),
        Devotional(
            id: "overthinking-at-1am", title: "The 1 A.M. Committee",
            verse: verse("Matthew 6:34"),
            body: "The committee convenes after midnight: every worst case, every replayed conversation, every version of next year that ends badly. Jesus adjourns the meeting with one sentence: \"Don't be anxious for tomorrow, for tomorrow will be anxious for itself.\" He's not saying tomorrow has no troubles. He's saying grace is issued daily, like manna — and worry is the attempt to spend tomorrow's grace tonight, which is why it always overdrafts. You were given strength for today. Tomorrow's version of you gets tomorrow's supply.",
            reflection: "Which tomorrow-problem keeps sneaking into today — and can you hand it back?",
            prayer: "Jesus, I adjourn the committee. I hand You tomorrow, next month, next year — and I take only today, with the grace You issued for it. Amen."
        ),
        Devotional(
            id: "when-she-got-engaged", title: "When She Got Engaged",
            verse: verse("Psalm 84:11"),
            body: "The ring photo loads and you feel two things at once: genuine happiness for her, and a drop in your own stomach you're ashamed of. Breathe. Both can be true, and God can handle the honest version. Here's the verse for the ache: \"No good thing will he withhold from those who walk blamelessly.\" Withhold. Meaning: if you don't have it yet, it is not because God looked at you and decided you were worth less. Her yes did not take your portion. There is no shortage in the house of a Father like this.",
            reflection: "Can you bless her out loud and grieve honestly with God — same day, same heart?",
            prayer: "Father, I celebrate her without shrinking me. Heal the part that keeps score. I trust that You withhold no good thing — including the ones still on the way. Amen."
        ),
        Devotional(
            id: "friendship-drift", title: "Friendship Drift",
            verse: verse("Proverbs 17:17"),
            body: "Nobody warns you that your twenties quietly reshuffle your friendships. The group chat slows. She moved, you got busy, and now the friendship runs on birthday stories and 'we should catch up!' \"A friend loves at all times\" — and at all times includes the drift. Some friendships are seasonal, and releasing them isn't failure. But the ones worth keeping are kept on purpose: the unprompted call, the flight booked, the awkward 'hey, I miss us.' Love, at this age, is mostly logistics.",
            reflection: "Which friendship is drifting that you're not actually willing to lose?",
            prayer: "God, thank You for the friends who've carried me. Show me which ones to fight for, give me grace to release the rest, and make me the friend I keep hoping to find. Amen."
        ),
        Devotional(
            id: "the-group-chat", title: "What the Group Chat Builds",
            verse: verse("Ephesians 4:29"),
            body: "It starts as venting. Three messages later it's a case file on someone who isn't there to object. \"Let no corrupt speech proceed out of your mouth, but only what is good for building others up.\" Paul's filter isn't 'is it true' — plenty of gossip is technically true. The filter is: does it build? Your words about people construct something — their reputation, your character, the trust level of the whole room. Be the friend whose presence makes it awkward to tear someone down. That's a ministry.",
            reflection: "Would the person you discussed this week feel loved if they read the thread?",
            prayer: "Lord, set a guard over my thumbs and my mouth. Make my words load-bearing — the kind that build people while they're not even in the room. Amen."
        ),
        Devotional(
            id: "homesick-at-church", title: "Homesick at Church",
            verse: verse("John 13:35"),
            body: "Maybe a church hurt you, or bored you, or simply never asked where you went. Now Sunday feels complicated — you miss God's people and don't trust them at the same time. That's a real wound; don't let anyone rush it. But hear Jesus: \"By this everyone will know that you are my disciples, if you have love for one another.\" Community isn't optional equipment for faith — it's the evidence. Don't let the room that failed you convince you the table isn't real. Try another chair.",
            reflection: "What would a first, small step back toward community look like — on your terms, at your pace?",
            prayer: "Jesus, You know exactly which room hurt me. Heal what happened there, and lead me to people who love like You said we would. I'm willing to try another chair. Amen."
        ),
        Devotional(
            id: "the-wilderness-era", title: "The Wilderness Era",
            verse: verse("Isaiah 43:19"),
            body: "Every life has an era nobody posts: the in-between, after the old thing ended and before the new thing has a name. Scripture calls it wilderness, and it has a strange résumé — it's where God did His most personal work. \"Behold, I will do a new thing. It springs out now. Don't you know it? I will even make a way in the wilderness.\" Springs out now — present tense, underground, already moving before you can see it. This era isn't a gap in your story. It's the soil of the next chapter.",
            reflection: "What might God be starting underground in this in-between season?",
            prayer: "God of new things, I trust You in the unglamorous middle. Open my eyes to what's already springing up, and make my wilderness a road. Amen."
        ),
        Devotional(
            id: "walking-through-water", title: "Through, Not Around",
            verse: verse("Isaiah 43:2"),
            body: "\"When you pass through the waters, I will be with you.\" Sit with the preposition. Not if — when. Not around — through. God doesn't promise a detour past the diagnosis, the breakup, the semester that broke you. He promises company in the middle of it and a limit on what it can do: \"they will not overflow you.\" You may come out soaked and different. You will not come out drowned. And you will not have crossed one inch of it alone.",
            reflection: "What water are you in right now — and where have you assumed you're swimming alone?",
            prayer: "Father, I stop asking only for the way around and start trusting You through. Keep Your hand on me in the current, and don't let it overflow me. Amen."
        ),
        Devotional(
            id: "god-of-the-detour", title: "God of the Detour",
            verse: verse("Proverbs 19:21"),
            body: "The plan was solid: the school, the person, the timeline. Then it dissolved — not because you failed, but because life turned without signaling. \"There are many plans in a man's heart, but Yahweh's counsel will prevail.\" Read it long enough and it stops sounding like a threat and starts sounding like a relief: the thing that prevails is not the strongest plan in the room, including your worst-case one. God's counsel outlasts your Plan A and your Plan-A grief. Some detours are the route.",
            reflection: "Looking back, has any 'ruined plan' turned out to be redirection?",
            prayer: "Lord, I hold my plans with open hands — even the beautiful ones. When the route changes, remind me that Your counsel, not chaos, is what prevails. Amen."
        ),
        Devotional(
            id: "peace-that-stays", title: "Peace That Doesn't Check Out",
            verse: verse("Isaiah 26:3"),
            body: "\"You will keep whoever's mind is steadfast in perfect peace, because he trusts in you.\" The Hebrew doubles the word: shalom shalom — peace, peace. Not the fragile kind that lasts until the next notification, but a kept peace, guarded like something valuable in a vault. The condition is a steadfast mind: attention that keeps returning to God like a compass needle finding north. You can't control the news, the group chat, or her opinion of you. You can control where your mind goes home to.",
            reflection: "Where does your mind go home to by default — and what would retraining that look like?",
            prayer: "God, keep me in peace, peace — the doubled kind. When my mind spins out, be the home it returns to. Amen."
        ),
        Devotional(
            id: "the-rest-ethic", title: "The Rest Ethic",
            verse: verse("Psalm 23:2-3"),
            body: "\"He makes me lie down in green pastures.\" Makes me — because apparently, left to ourselves, we won't. You have a work ethic; David describes a rest ethic, and it's just as spiritual. Still waters. Restored soul. This isn't a spa ad; it's a shepherd insisting that the sheep's output is not the point of the sheep. You are allowed to be unproductive in the presence of God and call it obedience. Some of the most faithful things you'll do this week will look, from the outside, like lying down.",
            reflection: "What actually restores your soul — and when did you last schedule it like it mattered?",
            prayer: "Shepherd, make me lie down if that's what it takes. Lead me to still water. Restore the soul I keep spending. Amen."
        ),
        Devotional(
            id: "spirit-of-power", title: "Not the Spirit of Fear",
            verse: verse("2 Timothy 1:7"),
            body: "Fear talks in your voice, which is why it's so convincing. Don't apply, you're not qualified. Don't say it, they'll leave. Don't try, you'll fail publicly. Paul hands Timothy a diagnostic: \"God didn't give us a spirit of fear, but of power, love, and self-control.\" Didn't give. So when fear presents itself as your personality, check the label — it's not from Him, and it doesn't get the final say. You are allowed to feel afraid and still move. That's what power with a steady mind looks like.",
            reflection: "What would you attempt this month if fear lost its veto?",
            prayer: "Father, I return the spirit of fear to sender. Fill me with power, love, and a sound mind — and give me one brave step to take today. Amen."
        ),
        Devotional(
            id: "already-loved", title: "Already Loved",
            verse: verse("Jeremiah 31:3"),
            body: "\"I have loved you with an everlasting love.\" Everlasting runs both directions — before you cleaned up, before you achieved anything, before you were the version of you that feels presentable. Most of us live like love is a performance review: earn it, keep earning it, never fully trust it. God's love has no probation period. You can't impress your way into it or disqualify yourself out of it. You start every morning already loved, which means today's efforts are a response, not an application.",
            reflection: "How would today change if you worked from love instead of for it?",
            prayer: "Father, unteach me the audition. Let me live today already loved — secure enough to risk, rest, and love people who can't pay it back. Amen."
        ),
        Devotional(
            id: "work-as-worship", title: "The Audience of One",
            verse: verse("Colossians 3:23"),
            body: "\"Whatever you do, work heartily, as for the Lord, and not for men.\" Paul wrote it to people whose work was invisible and uncredited — which makes it land on every unpaid internship, every shift nobody thanks you for, every project your boss renamed as theirs. Here's the reframe: the work was never ultimately for them. Excellence done quietly for God cannot be stolen, because the One it was for saw all of it. Your effort has a witness. Work like it.",
            reflection: "What task this week could you secretly re-address — same work, different recipient?",
            prayer: "Lord, I re-address my work to You — the seen parts and the invisible ones. Make my effort worship, and free me from needing the credit. Amen."
        ),
        Devotional(
            id: "the-unfinished-work", title: "Under Construction",
            verse: verse("Philippians 1:6"),
            body: "You are not behind; you are unfinished — and those are different conditions. \"He who began a good work in you will complete it.\" Notice who owns the project: He began, He will complete. Your growth is not a solo renovation you're failing to finish by 25. The patience God has with your process is embarrassing compared to the patience you have with it. Becoming is not a phase before your real life. It is your real life, and the Builder does not abandon sites.",
            reflection: "Where are you demanding a finished version of yourself that God is still patiently building?",
            prayer: "God, thank You for being unhurried with me. Keep building what You started, and give me grace for the scaffolding stage. Amen."
        ),
        Devotional(
            id: "nothing-can-separate", title: "The Unbreakable Clause",
            verse: verse("Romans 8:38-39"),
            body: "Paul ends his greatest chapter with a demolition list: death, life, angels, powers, things present, things to come — nothing \"will be able to separate us from the love of God.\" Read the list again and notice what's on it by implication: your worst relapse, your quietest doubt, the month you didn't pray, the thing you've never told anyone. Shame's entire strategy is convincing you that you're the exception clause. You're not. There is no fine print under this love. The contract holds.",
            reflection: "What have you been treating as the exception to 'nothing'?",
            prayer: "Father, I stop looking for the loophole that disqualifies me. Nothing means nothing. Hold me in the love that doesn't let go. Amen."
        ),
        Devotional(
            id: "do-it-in-love", title: "The Smallest Ministry",
            verse: verse("1 Corinthians 16:14"),
            body: "\"Let all that you do be done in love.\" Five words, no exceptions listed. Not just the mission trip — the group project with the freeloader. The tenth customer of a long shift. The roommate dish situation. We wait for a calling and miss that the instruction already arrived: all of it, in love. Love as a modifier turns ordinary Tuesdays into ministry. Nobody may notice. Heaven files it anyway. The width of your impact matters less than the temperature of it.",
            reflection: "What's one routine task today you could run at a warmer temperature?",
            prayer: "Jesus, love people through my smallest tasks today. Where I can't be impressive, let me be warm. Amen."
        ),
        Devotional(
            id: "winter-is-past", title: "Winter Is Past",
            verse: verse("Song of Solomon 2:11-12"),
            body: "\"For, behold, the winter is past. The rain is over and gone. The flowers appear on the earth.\" Some seasons end so gradually you almost miss the ending. One day you realize the song they ruined plays and you just... listen. The date on the calendar passes unnoticed. That's not betrayal of what you lost; that's spring doing what spring does. If you're still in the rain, hold on — winters in God's economy are seasons, not sentences. And if you feel the thaw starting: you're allowed to bloom again. It's time for singing.",
            reflection: "What's one small sign of spring in a place that used to be all winter?",
            prayer: "God of seasons, thank You that winter doesn't get forever. Where I'm thawing, give me courage to bloom — unapologetically, at Your pace. Amen."
        )
    ]

    static var devotionalOfToday: Devotional {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return devotionals[day % devotionals.count]
    }

    // MARK: Reading plans

    static let plans: [ReadingPlan] = [
        ReadingPlan(id: "anxious-gen", title: "Anxious Generation", subtitle: "7 days on worry, panic & peace", days: 7, gradient: [0xD9C6AC, 0xB49B7F], symbol: "wind", premium: false),
        ReadingPlan(id: "first-steps", title: "First Steps", subtitle: "New to faith? Start here", days: 5, gradient: [0xE8D5C0, 0xD9C6AC], symbol: "figure.walk", premium: false),
        ReadingPlan(id: "unshakeable", title: "Unshakeable", subtitle: "21 days on confidence & identity", days: 21, gradient: [0xC9A227, 0x8A6D1F], symbol: "crown", premium: false),
        ReadingPlan(id: "heart-check", title: "Heart Check", subtitle: "21 days on dating & desire", days: 21, gradient: [0xB08347, 0x7A5C43], symbol: "heart", premium: true),
        ReadingPlan(id: "purpose", title: "Called", subtitle: "14 days on career & purpose", days: 14, gradient: [0x8A9080, 0x5E6657], symbol: "location.north.line", premium: true),
        ReadingPlan(id: "psalms-30", title: "Psalms at Midnight", subtitle: "30 nights of sleep scripture", days: 30, gradient: [0x402F22, 0x2C1F16], symbol: "moon.stars", premium: true),
        ReadingPlan(id: "money-god", title: "Money & God", subtitle: "10 days on finances & trust", days: 10, gradient: [0x7A5C43, 0x402F22], symbol: "leaf", premium: true),
        ReadingPlan(id: "soft-strong", title: "Soft & Strong", subtitle: "10 days on rest & boundaries", days: 10, gradient: [0xD8A48F, 0xA96D57], symbol: "cloud.sun", premium: true),
        ReadingPlan(id: "not-behind", title: "Loved, Not Behind", subtitle: "7 days for waiting seasons", days: 7, gradient: [0x9C8AA5, 0x6B5B75], symbol: "hourglass", premium: true),
        ReadingPlan(id: "radiant", title: "Radiant", subtitle: "14 days on worth & beauty", days: 14, gradient: [0xE3B587, 0xB08347], symbol: "sparkles", premium: true)
    ]

    // MARK: Challenges (viral loops)

    static let challenges: [(title: String, subtitle: String, days: Int)] = [
        ("The 5AM Club", "Pray before you scroll — 7 days", 7),
        ("21 Days of Gratitude", "One thanks a day with friends", 21),
        ("The Quiet Day", "One screen-free day with God", 1),
        ("The Comparison Detox", "10 days off the measuring stick", 10),
        ("Verse Before Coffee", "Scripture first, caffeine second — 14 days", 14),
        ("Named Prayers", "Pray for one friend by name, daily", 7),
        ("Golden Hour", "15 unhurried minutes with God at sunset", 7),
        ("The Encourager", "Send one genuinely kind text a day", 7),
        ("Screens Down at 9", "Phone-free evenings for 10 nights", 10),
        ("Morning Pages", "Three honest lines to God each morning", 14),
        ("The Kindness Drop", "One anonymous act of kindness daily", 5),
        ("The Daily Return", "Show up here every day this month", 30)
    ]

    /// A different featured challenge each week.
    static var challengeOfWeek: (title: String, subtitle: String, days: Int) {
        let week = Calendar.current.ordinality(of: .weekOfYear, in: .year, for: Date()) ?? 1
        return challenges[week % challenges.count]
    }
}
