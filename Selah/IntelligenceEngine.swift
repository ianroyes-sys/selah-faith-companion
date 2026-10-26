import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Zero-overhead intelligence
// Primary: Apple Foundation Models — the on-device LLM shipped with iOS 26.
//   No API keys, no tokens, no server, works offline, fully private.
// Fallback: a curated scripture-matching engine for devices without
//   Apple Intelligence. The app never degrades to "broken" — only to "curated".

enum IntelligenceEngine {

    /// True when the on-device model is ready to generate.
    static var onDeviceModelAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        #endif
        return false
    }

    // MARK: Verse explanation

    static func explainVerse(_ verse: Verse) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            let instructions = """
            You explain Bible verses to Christians aged 18–28 in 3–4 sentences. \
            Plain modern language, one concrete application to daily life (school, work, \
            relationships, phones, money). Warm, never preachy.
            """
            let prompt = "Explain \(verse.reference): \"\(verse.text)\""
            if let text = try? await LanguageModelSession(instructions: instructions).respond(to: prompt).content,
               !text.isEmpty {
                return text
            }
        }
        #endif
        return TemplateEngine.explanation(for: verse)
    }

    // MARK: Crisis safety net — deterministic, runs before any engine.
    // A crisis disclosure always gets the 988 lifeline, whether or not the
    // on-device model is available.

    static func crisisReply(to text: String) -> String? {
        let t = text.lowercased()
        let signals = [
            "kill myself", "suicide", "suicidal", "end my life", "end it all",
            "want to die", "wanna die", "wish i was dead", "wish i were dead",
            "hurt myself", "hurting myself", "harm myself", "self harm", "self-harm",
            "no reason to live", "better off dead", "don't want to be alive",
            "dont want to be alive", "don't want to be here anymore", "dont want to be here anymore"
        ]
        guard signals.contains(where: t.contains) else { return nil }
        return "I'm really glad you trusted me with that — and I want you to hear this clearly: "
        + "your life matters, and what you're carrying right now deserves real human support, more than any app can give. "
        + "Please call or text 988 — the Suicide & Crisis Lifeline. It's free, confidential, and open 24/7. "
        + "If you can, tell one person you trust tonight too. "
        + "\"The LORD is close to the brokenhearted\" (Psalm 34:18) — and He so often shows up through people. "
        + "Will you reach out to someone right now?"
    }

    // MARK: Companion chat

    static func companionReply(history: [ChatMessage], userName: String, memory: String = "") async -> String {
        if let crisis = crisisReply(to: history.last?.text ?? "") { return crisis }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            let instructions = """
            You are Selah, a gentle Christian faith companion for young adults (18–28). \
            You listen first, respond with empathy in 2–4 sentences, and ground advice in \
            scripture (quote one short verse with its reference when it genuinely fits). \
            Never lecture. Never claim to be God, a pastor, or a therapist; for crisis or \
            self-harm topics, gently encourage talking to a trusted person or professional. \
            The user's name is \(userName.isEmpty ? "friend" : userName). \
            \(memory.isEmpty ? "" : "What you remember about their walk (use it naturally, don't recite it): \(memory)")
            """
            let transcript = history.suffix(8).map { m in
                (m.role == .user ? "User: " : "Selah: ") + m.text
            }.joined(separator: "\n")
            if let text = try? await LanguageModelSession(instructions: instructions).respond(to: transcript).content,
               !text.isEmpty {
                return text
            }
        }
        #endif
        return TemplateEngine.reply(to: history.last?.text ?? "", name: userName)
    }

    // MARK: Testimony — turns a season of local data into a written story.

    static func generateTestimony(name: String, entries: [JournalEntry], answered: [PersonalPrayer], streak: Int) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            let instructions = """
            You write short personal testimonies (120–180 words) for young Christians from \
            their own journal and answered prayers. First person, warm, specific, humble — \
            like something they'd actually post or share at church. No clichés, no preachiness.
            """
            let moods = entries.prefix(12).map { $0.mood.rawValue }.joined(separator: ", ")
            let answers = answered.prefix(4).map { "\"\($0.text.prefix(80))\" — \($0.answeredNote.prefix(60))" }.joined(separator: "; ")
            let prompt = """
            Name: \(name.isEmpty ? "a young believer" : name). Season's moods: \(moods.isEmpty ? "mixed" : moods). \
            Answered prayers: \(answers.isEmpty ? "still waiting on some" : answers). Streak: \(streak) days.
            Write their testimony.
            """
            if let text = try? await LanguageModelSession(instructions: instructions).respond(to: prompt).content,
               !text.isEmpty {
                return text
            }
        }
        #endif
        return TemplateEngine.testimony(name: name, answered: answered, streak: streak)
    }

    // MARK: Personalized office — a written liturgy over the user's actual day.

    static func officeScript(name: String, mood: Mood?, verse: Verse, openPrayer: PersonalPrayer?, calendarLine: String?, evening: Bool) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            let instructions = """
            You write a short \(evening ? "evening" : "morning") prayer liturgy (90–130 words) \
            meant to be read slowly and quietly. Address the reader by name. Weave in \
            the given verse, their current mood, what they're praying about, and their day. \
            Plain warm modern language. End with a gentle blessing. No stage directions.
            """
            var facts = ["Name: \(name.isEmpty ? "friend" : name)", "Verse: \"\(verse.text)\" (\(verse.reference))"]
            if let mood { facts.append("Mood: \(mood.rawValue)") }
            if let openPrayer { facts.append("Praying about: \(openPrayer.text.prefix(80))") }
            if let calendarLine { facts.append("On their calendar: \(calendarLine)") }
            if let text = try? await LanguageModelSession(instructions: instructions).respond(to: facts.joined(separator: ". ")).content,
               !text.isEmpty {
                return text
            }
        }
        #endif
        return TemplateEngine.office(name: name, mood: mood, verse: verse, openPrayer: openPrayer, calendarLine: calendarLine, evening: evening)
    }
}

// MARK: - Curated fallback engine

enum TemplateEngine {

    static func explanation(for verse: Verse) -> String {
        "This verse speaks directly into \(verse.topics.first ?? "daily life"). "
        + "Written words, but a living promise: God isn't distant from the thing you're facing right now. "
        + "Try carrying \(verse.reference) into one specific moment today — before the exam, the conversation, "
        + "or the scroll — and let it set the tone instead of your worry."
    }

    static func reply(to message: String, name: String) -> String {
        let lower = message.lowercased()
        let friendly = name.isEmpty ? "" : "\(name), "
        let matched = ContentLibrary.verses(matching: lower).first ?? ContentLibrary.verseOfToday

        if ["anxious", "anxiety", "worried", "stress", "panic", "scared", "afraid"].contains(where: lower.contains) {
            return "\(friendly.capitalized)that sounds heavy, and it makes sense you feel it. You don't have to solve it tonight. Scripture says: \"\(matched.text)\" (\(matched.reference)). Want to tell me what's underneath the worry?"
        }
        if ["lonely", "alone", "no friends", "isolated", "left out"].contains(where: lower.contains) {
            return "I'm glad you said it instead of carrying it silently. Loneliness lies about being permanent. \"\(matched.text)\" (\(matched.reference)). What's one person or place you could take a small step toward this week?"
        }
        if ["tempted", "temptation", "struggling with", "addicted", "habit"].contains(where: lower.contains) {
            return "Thank you for being honest — that took courage. There's no shame here. \"\(matched.text)\" (\(matched.reference)). What usually happens right before the pull gets strong?"
        }
        if ["tired", "exhausted", "burned out", "burnt out", "drained"].contains(where: lower.contains) {
            return "Rest isn't quitting. Jesus said, \"Come to me, all you who labor and are heavily burdened, and I will give you rest\" (Matthew 11:28). What would fifteen unhurried minutes look like for you today?"
        }
        if ["thank", "grateful", "blessed", "good news", "answered"].contains(where: lower.contains) {
            return "That's worth pausing over — say it out loud, write it down. \"Give thanks to the LORD, for he is good\" (Psalm 136:1). What made this one feel special?"
        }
        return "I hear you\(friendly.isEmpty ? "" : ", \(name)"). Here's what came to mind as you were talking: \"\(matched.text)\" (\(matched.reference)). Tell me more — what part of this weighs on you most?"
    }

    static func testimony(name: String, answered: [PersonalPrayer], streak: Int) -> String {
        let opener = name.isEmpty ? "This season, God has been quietly at work in me." :
            "This season, God has been quietly at work in me, \(name)."
        var middle = "I brought Him the things I usually carry alone — the worry, the waiting, the questions I didn't say out loud anywhere else."
        if let a = answered.first {
            middle += " And He moved. I prayed about \"\(a.text.prefix(70))\" — and I watched Him answer."
        }
        let close = streak > 6
            ? " Showing up \(streak) days in a row taught me that faithfulness isn't a feeling; it's a rhythm. I'm not who I was at the start of this season — and I'm grateful."
            : " I'm learning that faith grows in small daily returns, not big dramatic moments. I'm not who I was at the start of this season — and I'm grateful."
        return opener + " " + middle + close
    }

    static func office(name: String, mood: Mood?, verse: Verse, openPrayer: PersonalPrayer?, calendarLine: String?, evening: Bool) -> String {
        let n = name.isEmpty ? "friend" : name
        var lines: [String] = []
        lines.append(evening
            ? "\(n). The day is done, and you don't have to carry it into the night."
            : "Good morning, \(n). Before the noise begins, take one slow breath.")
        if let mood {
            lines.append("You said your heart feels \(mood.rawValue) today. God is not put off by that. He meets you exactly there.")
        }
        lines.append("Hear this word over your day: \(verse.text) — \(verse.reference).")
        if let openPrayer {
            lines.append("You've been praying about \(openPrayer.text.prefix(80)). He has not forgotten. Neither should you stop asking.")
        }
        if let calendarLine, !evening {
            lines.append("Today holds \(calendarLine). Walk into it unhurried — you don't go alone.")
        }
        lines.append(evening
            ? "Now rest. In peace you will lie down and sleep, for the Lord alone makes you dwell in safety. Goodnight, \(n)."
            : "May the Lord bless you and keep you, and make His face shine on you today. Go gently, \(n).")
        return lines.joined(separator: " ... ")
    }
}
