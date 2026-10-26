import Foundation
import SwiftUI

// MARK: - Selah Sound — Christian music matched to your vibe and your mood.
// Zero-cost: a curated on-device catalog; songs open in Apple Music or Spotify
// via universal search links. No API keys, no streaming SDK, nothing to pay for.

enum Vibe: String, Codable, CaseIterable, Identifiable {
    case gospel, worship, ccm, country, afrobeats, house, rnb, hiphop

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gospel: "Gospel"
        case .worship: "Worship"
        case .ccm: "CCM"
        case .country: "Christian Country"
        case .afrobeats: "Christian Afrobeats"
        case .house: "Christian House"
        case .rnb: "Christian R&B"
        case .hiphop: "Christian Hip-Hop"
        }
    }

    var tagline: String {
        switch self {
        case .gospel: "Choir-raised and soul-deep"
        case .worship: "Hands up, eyes closed"
        case .ccm: "The radio anthems"
        case .country: "Faith with a front porch"
        case .afrobeats: "Praise you can't stand still to"
        case .house: "Dance floor devotion"
        case .rnb: "Slow, honest, close"
        case .hiphop: "Bars and belief"
        }
    }

    var symbol: String {
        switch self {
        case .gospel: "music.mic"
        case .worship: "hands.and.sparkles"
        case .ccm: "radio"
        case .country: "guitars"
        case .afrobeats: "sun.dust"
        case .house: "waveform.path"
        case .rnb: "moon.haze"
        case .hiphop: "beats.headphones"
        }
    }

    var gradient: [UInt32] {
        switch self {
        case .gospel: [0x7A3B2E, 0x4A2018]
        case .worship: [0xB08347, 0x7A5C43]
        case .ccm: [0x8A9080, 0x5E6657]
        case .country: [0xA96D57, 0x6B4130]
        case .afrobeats: [0xC9A227, 0x8A6D1F]
        case .house: [0x5B6B8C, 0x323D57]
        case .rnb: [0x9C8AA5, 0x5D4F66]
        case .hiphop: [0x494949, 0x1F1F1F]
        }
    }
}

struct Song: Identifiable, Hashable {
    let title: String
    let artist: String
    let vibes: [Vibe]
    let moods: [Mood]

    var id: String { "\(title)|\(artist)" }

    private var query: String {
        "\(title) \(artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
    }
    var appleMusicURL: URL { URL(string: "https://music.apple.com/search?term=\(query)")! }
    var spotifyURL: URL { URL(string: "https://open.spotify.com/search/\(query)")! }
}

enum MusicLibrary {

    static let songs: [Song] = [
        // Gospel
        Song(title: "Break Every Chain", artist: "Tasha Cobbs Leonard", vibes: [.gospel], moods: [.anxious, .tempted, .overwhelmed]),
        Song(title: "Goodness of God", artist: "CeCe Winans", vibes: [.gospel, .worship], moods: [.grateful, .hopeful]),
        Song(title: "Take Me to the King", artist: "Tamela Mann", vibes: [.gospel], moods: [.overwhelmed, .lonely, .tired]),
        Song(title: "Melodies from Heaven", artist: "Kirk Franklin", vibes: [.gospel], moods: [.joyful, .grateful]),
        Song(title: "No Weapon", artist: "Fred Hammond", vibes: [.gospel], moods: [.anxious, .hopeful]),
        Song(title: "Jireh", artist: "Elevation Worship & Maverick City", vibes: [.gospel, .worship], moods: [.anxious, .grateful, .lonely]),
        Song(title: "Won't He Do It", artist: "Koryn Hawthorne", vibes: [.gospel, .rnb], moods: [.hopeful, .joyful]),
        Song(title: "Never Lost", artist: "CeCe Winans", vibes: [.gospel], moods: [.hopeful, .anxious]),

        // CCM
        Song(title: "You Say", artist: "Lauren Daigle", vibes: [.ccm], moods: [.lonely, .anxious]),
        Song(title: "Gratitude", artist: "Brandon Lake", vibes: [.ccm, .worship], moods: [.grateful, .joyful]),
        Song(title: "This Is Amazing Grace", artist: "Phil Wickham", vibes: [.ccm, .worship], moods: [.joyful, .grateful]),
        Song(title: "Rescue", artist: "Lauren Daigle", vibes: [.ccm], moods: [.lonely, .overwhelmed]),
        Song(title: "Who You Say I Am", artist: "Hillsong Worship", vibes: [.ccm, .worship], moods: [.hopeful, .lonely]),
        Song(title: "Trust in God", artist: "Elevation Worship", vibes: [.ccm, .worship], moods: [.anxious, .hopeful]),
        Song(title: "Firm Foundation (He Won't)", artist: "Cody Carnes", vibes: [.ccm, .worship], moods: [.anxious, .hopeful]),
        Song(title: "Thank God I Do", artist: "Lauren Daigle", vibes: [.ccm], moods: [.grateful, .lonely]),

        // Christian Country
        Song(title: "My Jesus", artist: "Anne Wilson", vibes: [.country], moods: [.hopeful, .lonely]),
        Song(title: "Chain Breaker", artist: "Zach Williams", vibes: [.country], moods: [.tempted, .hopeful]),
        Song(title: "Something in the Water", artist: "Carrie Underwood", vibes: [.country], moods: [.joyful, .grateful]),
        Song(title: "Long Black Train", artist: "Josh Turner", vibes: [.country], moods: [.tempted]),
        Song(title: "Fear Is a Liar", artist: "Zach Williams", vibes: [.country], moods: [.anxious]),
        Song(title: "Sunday Sermons", artist: "Anne Wilson", vibes: [.country], moods: [.grateful, .tired]),
        Song(title: "Rescue Story", artist: "Zach Williams", vibes: [.country], moods: [.lonely, .grateful]),
        Song(title: "The River", artist: "Jordan Feliz", vibes: [.country, .ccm], moods: [.joyful, .hopeful]),

        // Christian Afrobeats
        Song(title: "Jireh (My Provider)", artist: "Limoblaze & Lecrae", vibes: [.afrobeats], moods: [.grateful, .anxious]),
        Song(title: "Too Faithful", artist: "Moses Bliss", vibes: [.afrobeats], moods: [.hopeful, .grateful]),
        Song(title: "Way Maker", artist: "Sinach", vibes: [.afrobeats, .worship], moods: [.hopeful, .overwhelmed]),
        Song(title: "Congratulations", artist: "Ada Ehi", vibes: [.afrobeats], moods: [.joyful, .hopeful]),
        Song(title: "This Year (Blessings)", artist: "Victor Thompson & Ehis 'D' Greatest", vibes: [.afrobeats], moods: [.hopeful, .joyful]),
        Song(title: "Working on Me", artist: "CalledOut Music", vibes: [.afrobeats, .rnb], moods: [.tempted, .hopeful]),
        Song(title: "Excess Love", artist: "Mercy Chinwo", vibes: [.afrobeats], moods: [.grateful, .joyful]),
        Song(title: "Miracle No Dey Tire Jesus", artist: "Moses Bliss ft. Festizie", vibes: [.afrobeats], moods: [.joyful, .grateful]),

        // Christian House / Electronic
        Song(title: "P E A C E", artist: "Hillsong Young & Free", vibes: [.house], moods: [.anxious, .overwhelmed]),
        Song(title: "Best Friends", artist: "Hillsong Young & Free", vibes: [.house], moods: [.lonely, .joyful]),
        Song(title: "Real Love", artist: "Hillsong Young & Free", vibes: [.house], moods: [.hopeful, .joyful]),
        Song(title: "Alive", artist: "Hillsong Young & Free", vibes: [.house], moods: [.joyful]),
        Song(title: "GOOD DAY", artist: "Forrest Frank", vibes: [.house, .rnb], moods: [.joyful, .tired]),
        Song(title: "UP!", artist: "Forrest Frank & Connor Price", vibes: [.house, .hiphop], moods: [.hopeful, .joyful]),
        Song(title: "Fireproof", artist: "Capital Kings", vibes: [.house], moods: [.anxious, .hopeful]),
        Song(title: "No Longer Slaves (Remix)", artist: "Bethel Music", vibes: [.house, .worship], moods: [.anxious, .tempted]),

        // Christian R&B / Soul
        Song(title: "Fall in Love with You", artist: "Montell Fish", vibes: [.rnb], moods: [.lonely, .tired]),
        Song(title: "Talk 2 Me", artist: "Montell Fish", vibes: [.rnb], moods: [.lonely]),
        Song(title: "When I Pray", artist: "DOE", vibes: [.rnb, .gospel], moods: [.anxious, .hopeful]),
        Song(title: "Brighter", artist: "DOE", vibes: [.rnb], moods: [.tired, .hopeful]),
        Song(title: "So Good", artist: "Jor'dan Armstrong", vibes: [.rnb], moods: [.joyful, .grateful]),
        Song(title: "Blessed Up", artist: "Jor'dan Armstrong", vibes: [.rnb, .hiphop], moods: [.grateful]),
        Song(title: "Sunday Morning", artist: "Lecrae ft. Kirk Franklin", vibes: [.rnb, .hiphop], moods: [.joyful, .grateful]),

        // Christian Hip-Hop
        Song(title: "I'll Find You", artist: "Lecrae ft. Tori Kelly", vibes: [.hiphop], moods: [.overwhelmed, .hopeful]),
        Song(title: "Blessings", artist: "Lecrae ft. Ty Dolla $ign", vibes: [.hiphop], moods: [.grateful]),
        Song(title: "Church Clap", artist: "KB ft. Lecrae", vibes: [.hiphop], moods: [.joyful]),
        Song(title: "Miracle", artist: "Hulvey", vibes: [.hiphop], moods: [.lonely, .hopeful]),
        Song(title: "Reasons", artist: "Hulvey", vibes: [.hiphop], moods: [.anxious]),
        Song(title: "You Can't Stop Me", artist: "Andy Mineo", vibes: [.hiphop], moods: [.hopeful, .tired]),
        Song(title: "Nervous", artist: "Hulvey", vibes: [.hiphop], moods: [.anxious, .tempted]),

        // Worship
        Song(title: "Oceans (Where Feet May Fail)", artist: "Hillsong UNITED", vibes: [.worship], moods: [.anxious, .hopeful]),
        Song(title: "What a Beautiful Name", artist: "Hillsong Worship", vibes: [.worship], moods: [.joyful, .grateful]),
        Song(title: "The Blessing", artist: "Kari Jobe & Cody Carnes", vibes: [.worship], moods: [.hopeful, .grateful]),
        Song(title: "Do It Again", artist: "Elevation Worship", vibes: [.worship], moods: [.overwhelmed, .hopeful]),
        Song(title: "Build My Life", artist: "Pat Barrett", vibes: [.worship], moods: [.hopeful]),
        Song(title: "Same God", artist: "Elevation Worship", vibes: [.worship], moods: [.anxious, .hopeful]),
        Song(title: "Honey in the Rock", artist: "Brooke Ligertwood", vibes: [.worship], moods: [.grateful, .joyful]),
        Song(title: "Abide", artist: "Aaron Williams & Dwell Songs", vibes: [.worship], moods: [.tired, .lonely]),
    ]

    // MARK: Selection

    /// The user's chosen vibes, stored as a comma-joined raw string.
    static func savedVibes() -> [Vibe] {
        let raw = UserDefaults.standard.string(forKey: "selah.vibes") ?? ""
        return raw.split(separator: ",").compactMap { Vibe(rawValue: String($0)) }
    }

    static func saveVibes(_ vibes: [Vibe]) {
        UserDefaults.standard.set(vibes.map(\.rawValue).joined(separator: ","), forKey: "selah.vibes")
    }

    /// Today's soundtrack: songs from your vibes that match today's mood,
    /// deterministically shuffled by date so the mix changes each morning.
    static func soundtrack(vibes: [Vibe], mood: Mood?, count: Int = 5) -> [Song] {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let chosen = vibes.isEmpty ? Array(Vibe.allCases) : vibes

        var pool = songs.filter { song in song.vibes.contains { chosen.contains($0) } }
        if let mood {
            let moodPool = pool.filter { $0.moods.contains(mood) }
            if moodPool.count >= 3 { pool = moodPool }
        }

        // Deterministic daily rotation without Random: sort by a day-salted key.
        let salted = pool.sorted {
            hashKey($0.id, salt: day) < hashKey($1.id, salt: day)
        }
        return Array(salted.prefix(count))
    }

    static func songs(for vibe: Vibe) -> [Song] {
        songs.filter { $0.vibes.contains(vibe) }
    }

    static var songOfToday: Song {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return songs[day % songs.count]
    }

    private static func hashKey(_ s: String, salt: Int) -> Int {
        var h = salt
        for c in s.unicodeScalars { h = (h &* 31 &+ Int(c.value)) & 0x7FFFFFFF }
        return h
    }
}
