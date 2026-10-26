import Foundation
import SwiftUI
import Security

// MARK: - App legal links (paywall + profile; App Review 3.1.2)

enum Legal {
    static let privacyURL = URL(string: "https://selah-legal-kohl.vercel.app")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let feedbackURL = URL(string: "mailto:support@example.com?subject=Selah%20Feedback")!
}

// MARK: - Device identity — Keychain-backed so it survives reinstall
// (and stays out of plaintext backups). Migrates pre-Keychain installs
// from UserDefaults so nobody loses their community identity.

enum DeviceIdentity {
    private static let service = "com.selah.companion"

    static func value(_ key: String, generate: () -> String) -> String {
        if let v = read(key) { return v }
        let v = UserDefaults.standard.string(forKey: key) ?? generate()
        save(key, v)
        return v
    }

    private static func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func save(_ key: String, _ value: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(base as CFDictionary)
        var add = base
        add[kSecValueData as String] = Data(value.utf8)
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(add as CFDictionary, nil)
    }
}

// MARK: - Selah Community — real backend (Supabase edge function).
// Identity is a device-generated id + secret; no account, no email, no login.
// All reads and writes go through one endpoint; the server filters blocked
// authors, hides reported content, and rejects objectionable wording.

enum CommunityAPI {
    /// Filled from Config/Secrets.xcconfig (SELAH_SUPABASE_HOST / SELAH_SUPABASE_ANON_KEY)
    /// through Support/Info.plist. Without them, community calls fail gracefully.
    static let endpoint: URL = {
        let host = (Bundle.main.object(forInfoDictionaryKey: "SelahSupabaseHost") as? String) ?? ""
        return URL(string: "https://\(host.isEmpty ? "your-project.supabase.co" : host)/functions/v1/community")!
    }()
    static let anonKey = (Bundle.main.object(forInfoDictionaryKey: "SelahSupabaseAnonKey") as? String) ?? ""

    enum APIError: LocalizedError {
        case server(String)
        case network
        var errorDescription: String? {
            switch self {
            case .server(let message): message
            case .network: "Couldn't reach the community right now."
            }
        }
    }

    private static var deviceID: String {
        DeviceIdentity.value("selah.deviceID") { UUID().uuidString }
    }

    private static var deviceSecret: String {
        DeviceIdentity.value("selah.deviceSecret") { (0..<2).map { _ in UUID().uuidString }.joined() }
    }

    static func call(_ action: String, _ payload: [String: Any] = [:]) async throws -> Data {
        var body = payload
        body["action"] = action
        body["device_id"] = deviceID
        body["secret"] = deviceSecret

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.network
        }
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = obj["error"] as? String {
                throw APIError.server(message)
            }
            throw APIError.network
        }
        return data
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { d in
            let raw = try d.singleValueContainer().decode(String.self)
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = f.date(from: raw) { return date }
            f.formatOptions = [.withInternetDateTime]
            return f.date(from: raw) ?? Date()
        }
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Models

struct CommunityPrayer: Identifiable, Decodable, Hashable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let body: String
    var prayedCount: Int
    var carriedCount: Int
    let createdAt: Date
    var prayedByMe: Bool?
    var isMine: Bool?
}

struct Testimony: Identifiable, Decodable, Hashable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let body: String
    var amenCount: Int
    let createdAt: Date
    var amenByMe: Bool?
    var isMine: Bool?
}

struct CircleInfo: Identifiable, Decodable, Hashable {
    let id: UUID
    let name: String
    let inviteCode: String
    var memberCount: Int
    let isPublic: Bool?
    let tagline: String?
    let symbol: String?
}

/// A pre-built public group anyone can join with one tap — no invite code needed.
struct PublicGroup: Identifiable, Decodable, Hashable {
    let id: UUID
    let name: String
    let inviteCode: String
    let tagline: String
    let symbol: String
    var memberCount: Int
    var joined: Bool
}

/// One message in The Commons — the anonymous global room.
struct CommonsMessage: Identifiable, Decodable, Hashable {
    let id: UUID
    let authorId: UUID
    let handle: String
    let body: String
    let createdAt: Date
    var isMine: Bool?
}

struct Blessing: Identifiable, Decodable, Hashable {
    let id: UUID
    let circleId: UUID
    let authorId: UUID?
    let authorName: String
    let body: String
    let createdAt: Date
    var isMine: Bool?
}

struct CircleMember: Identifiable, Decodable, Hashable {
    let id: UUID
    let name: String
    let checkedInToday: Bool
    let isMe: Bool
}

enum LoadState: Equatable {
    case idle, loading, loaded
    case failed(String)
}

// MARK: - Store

@MainActor
final class CommunityStore: ObservableObject {
    static let shared = CommunityStore()

    @Published var wall: [CommunityPrayer] = []
    @Published var wallState: LoadState = .idle
    @Published var testimonies: [Testimony] = []
    @Published var testimonyState: LoadState = .idle
    @Published var circles: [CircleInfo] = []
    @Published var circleState: LoadState = .idle
    @Published var groups: [PublicGroup] = []
    @Published var groupsState: LoadState = .idle
    @Published var commons: [CommonsMessage] = []
    @Published var commonsState: LoadState = .idle
    @Published var myHandle: String = ""
    @Published var circlePrayers: [UUID: [CommunityPrayer]] = [:]
    @Published var circleBlessings: [UUID: [Blessing]] = [:]
    @Published var prayingNow: Int = 0
    @Published var latestBlessing: Blessing?
    @Published var relayPrayer: CommunityPrayer?
    @Published var relayCarried: Int = 0
    @Published var circleMembers: [UUID: [CircleMember]] = [:]
    @Published var checkInStreak: Int = UserDefaults.standard.integer(forKey: "selah.checkinStreak")
    @Published var checkedInToday: Bool = UserDefaults.standard.string(forKey: "selah.checkinDay") == CommunityStore.dayKey
    @Published var newLove: Int = 0

    @AppStorage("selah.guidelinesAccepted") var guidelinesAccepted = false
    @AppStorage("selah.communityPrayed") var communityPrayed = 0

    private var registered = false

    func register(name: String) async {
        guard !registered else { return }
        if let _ = try? await CommunityAPI.call("register", ["display_name": name]) {
            registered = true
        }
    }

    static var dayKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    // MARK: Daily heart check-in

    func checkIn(mood: Mood) async {
        checkedInToday = true
        UserDefaults.standard.set(Self.dayKey, forKey: "selah.checkinDay")
        struct R: Decodable { let streak: Int }
        if let data = try? await CommunityAPI.call("check_in", ["mood": mood.rawValue]),
           let r = try? CommunityAPI.decode(R.self, from: data) {
            checkInStreak = r.streak
        } else if checkInStreak == 0 {
            checkInStreak = 1
        }
        UserDefaults.standard.set(checkInStreak, forKey: "selah.checkinStreak")
    }

    // MARK: "While you were away" — love received on my content since last visit.

    func refreshActivity() async {
        struct R: Decodable { let prayedTotal: Int; let amenTotal: Int }
        guard let data = try? await CommunityAPI.call("my_activity"),
              let r = try? CommunityAPI.decode(R.self, from: data) else { return }
        let total = r.prayedTotal + r.amenTotal
        let last = UserDefaults.standard.object(forKey: "selah.lastLoveTotal") as? Int
        if let last, total > last {
            newLove = total - last
        }
        UserDefaults.standard.set(total, forKey: "selah.lastLoveTotal")
    }

    // MARK: Wall

    func refreshWall() async {
        if wall.isEmpty { wallState = .loading }
        do {
            struct R: Decodable { let prayers: [CommunityPrayer] }
            let data = try await CommunityAPI.call("wall")
            wall = try CommunityAPI.decode(R.self, from: data).prayers
            wallState = .loaded
        } catch {
            wallState = .failed(error.localizedDescription)
        }
    }

    func postPrayer(_ body: String, authorName: String, circleID: UUID? = nil) async throws {
        var payload: [String: Any] = ["body": body, "author_name": authorName]
        if let circleID { payload["circle_id"] = circleID.uuidString }
        struct R: Decodable { let prayer: CommunityPrayer }
        let data = try await CommunityAPI.call("post_prayer", payload)
        let prayer = try CommunityAPI.decode(R.self, from: data).prayer
        if let circleID {
            circlePrayers[circleID, default: []].insert(prayer, at: 0)
        } else {
            wall.insert(prayer, at: 0)
        }
    }

    func pray(for prayer: CommunityPrayer, inCircle circleID: UUID? = nil) async {
        markPrayed(prayer.id, circleID: circleID)
        communityPrayed += 1
        _ = try? await CommunityAPI.call("pray", ["prayer_id": prayer.id.uuidString])
    }

    private func markPrayed(_ id: UUID, circleID: UUID?) {
        func update(_ list: inout [CommunityPrayer]) {
            guard let i = list.firstIndex(where: { $0.id == id }) else { return }
            guard list[i].prayedByMe != true else { return }
            list[i].prayedByMe = true
            list[i].prayedCount += 1
        }
        if let circleID { update(&circlePrayers[circleID, default: []]) } else { update(&wall) }
    }

    func deletePrayer(_ prayer: CommunityPrayer) async {
        wall.removeAll { $0.id == prayer.id }
        _ = try? await CommunityAPI.call("delete_prayer", ["prayer_id": prayer.id.uuidString])
    }

    // MARK: Testimonies

    func refreshTestimonies() async {
        if testimonies.isEmpty { testimonyState = .loading }
        do {
            struct R: Decodable { let testimonies: [Testimony] }
            let data = try await CommunityAPI.call("testimonies")
            testimonies = try CommunityAPI.decode(R.self, from: data).testimonies
            testimonyState = .loaded
        } catch {
            testimonyState = .failed(error.localizedDescription)
        }
    }

    func postTestimony(_ body: String, authorName: String) async throws {
        struct R: Decodable { let testimony: Testimony }
        let data = try await CommunityAPI.call("post_testimony", ["body": body, "author_name": authorName])
        let t = try CommunityAPI.decode(R.self, from: data).testimony
        testimonies.insert(t, at: 0)
    }

    func amen(_ testimony: Testimony) async {
        if let i = testimonies.firstIndex(where: { $0.id == testimony.id }), testimonies[i].amenByMe != true {
            testimonies[i].amenByMe = true
            testimonies[i].amenCount += 1
        }
        _ = try? await CommunityAPI.call("amen", ["testimony_id": testimony.id.uuidString])
    }

    func deleteTestimony(_ testimony: Testimony) async {
        testimonies.removeAll { $0.id == testimony.id }
        _ = try? await CommunityAPI.call("delete_testimony", ["testimony_id": testimony.id.uuidString])
    }

    // MARK: Circles

    func refreshCircles() async {
        if circles.isEmpty { circleState = .loading }
        do {
            struct R: Decodable { let circles: [CircleInfo] }
            let data = try await CommunityAPI.call("my_circles")
            circles = try CommunityAPI.decode(R.self, from: data).circles
            circleState = .loaded
        } catch {
            circleState = .failed(error.localizedDescription)
        }
    }

    func createCircle(named name: String) async throws -> CircleInfo {
        struct R: Decodable { let circle: CircleInfo }
        let data = try await CommunityAPI.call("create_circle", ["name": name])
        let circle = try CommunityAPI.decode(R.self, from: data).circle
        circles.insert(circle, at: 0)
        return circle
    }

    func joinCircle(code: String) async throws -> CircleInfo {
        struct R: Decodable { let circle: CircleInfo }
        let data = try await CommunityAPI.call("join_circle", ["code": code])
        let circle = try CommunityAPI.decode(R.self, from: data).circle
        if !circles.contains(where: { $0.id == circle.id }) { circles.insert(circle, at: 0) }
        return circle
    }

    func leaveCircle(_ circle: CircleInfo) async {
        circles.removeAll { $0.id == circle.id }
        if let i = groups.firstIndex(where: { $0.id == circle.id }) {
            groups[i].joined = false
            groups[i].memberCount = max(0, groups[i].memberCount - 1)
        }
        _ = try? await CommunityAPI.call("leave_circle", ["circle_id": circle.id.uuidString])
    }

    // MARK: Pre-built groups — public circles, one tap to belong.

    func browseGroups() async {
        if groups.isEmpty { groupsState = .loading }
        do {
            struct R: Decodable { let groups: [PublicGroup] }
            let data = try await CommunityAPI.call("browse_groups")
            groups = try CommunityAPI.decode(R.self, from: data).groups
            groupsState = .loaded
        } catch {
            groupsState = .failed(error.localizedDescription)
        }
    }

    @discardableResult
    func joinGroup(_ group: PublicGroup) async throws -> CircleInfo {
        struct R: Decodable { let circle: CircleInfo }
        let data = try await CommunityAPI.call("join_group", ["circle_id": group.id.uuidString])
        let circle = try CommunityAPI.decode(R.self, from: data).circle
        if let i = groups.firstIndex(where: { $0.id == group.id }) {
            groups[i].joined = true
            groups[i].memberCount = circle.memberCount
        }
        if !circles.contains(where: { $0.id == circle.id }) { circles.insert(circle, at: 0) }
        return circle
    }

    // MARK: The Commons — anonymous global chat.

    func refreshCommons() async {
        if commons.isEmpty { commonsState = .loading }
        do {
            struct R: Decodable { let messages: [CommonsMessage]; let myHandle: String }
            let data = try await CommunityAPI.call("chat_recent")
            let r = try CommunityAPI.decode(R.self, from: data)
            commons = r.messages
            myHandle = r.myHandle
            commonsState = .loaded
        } catch {
            commonsState = .failed(error.localizedDescription)
        }
    }

    func sendToCommons(_ body: String) async throws {
        struct R: Decodable { let message: CommonsMessage; let myHandle: String }
        let data = try await CommunityAPI.call("chat_send", ["body": body])
        let r = try CommunityAPI.decode(R.self, from: data)
        myHandle = r.myHandle
        if !commons.contains(where: { $0.id == r.message.id }) { commons.append(r.message) }
    }

    func blockInCommons(authorID: UUID) async {
        commons.removeAll { $0.authorId == authorID }
        await block(authorID: authorID)
    }

    func deleteCommonsMessage(_ message: CommonsMessage) async {
        commons.removeAll { $0.id == message.id }
        _ = try? await CommunityAPI.call("delete_chat", ["message_id": message.id.uuidString])
    }

    func loadCircleFeed(_ circle: CircleInfo) async {
        do {
            struct R: Decodable {
                let prayers: [CommunityPrayer]
                let blessings: [Blessing]
                let members: [CircleMember]?
            }
            let data = try await CommunityAPI.call("circle_feed", ["circle_id": circle.id.uuidString])
            let feed = try CommunityAPI.decode(R.self, from: data)
            circlePrayers[circle.id] = feed.prayers
            circleBlessings[circle.id] = feed.blessings
            circleMembers[circle.id] = feed.members ?? []
        } catch { }
    }

    func sendBlessing(_ body: String, to circle: CircleInfo, authorName: String) async throws {
        struct R: Decodable { let blessing: Blessing }
        let data = try await CommunityAPI.call("post_blessing", [
            "circle_id": circle.id.uuidString, "body": body, "author_name": authorName
        ])
        let blessing = try CommunityAPI.decode(R.self, from: data).blessing
        circleBlessings[circle.id, default: []].insert(blessing, at: 0)
    }

    func refreshLatestBlessing() async {
        struct R: Decodable { let blessing: Blessing? }
        guard let data = try? await CommunityAPI.call("latest_blessing"),
              let r = try? CommunityAPI.decode(R.self, from: data) else { return }
        latestBlessing = r.blessing
    }

    // MARK: Relay

    func loadRelay() async {
        struct R: Decodable { let prayer: CommunityPrayer? }
        guard let data = try? await CommunityAPI.call("relay_next"),
              let r = try? CommunityAPI.decode(R.self, from: data) else { return }
        relayPrayer = r.prayer
    }

    func carryRelay() async {
        guard let prayer = relayPrayer else { return }
        relayCarried += 1
        communityPrayed += 1
        _ = try? await CommunityAPI.call("carry", ["prayer_id": prayer.id.uuidString])
        await loadRelay()
    }

    // MARK: Presence

    func heartbeat() async {
        struct R: Decodable { let prayingNow: Int }
        guard let data = try? await CommunityAPI.call("heartbeat"),
              let r = try? CommunityAPI.decode(R.self, from: data) else { return }
        prayingNow = r.prayingNow
    }

    // MARK: Safety

    func report(kind: String, id: UUID, reason: String = "") async {
        _ = try? await CommunityAPI.call("report", [
            "target_kind": kind, "target_id": id.uuidString, "reason": reason
        ])
    }

    func block(authorID: UUID) async {
        wall.removeAll { $0.authorId == authorID }
        testimonies.removeAll { $0.authorId == authorID }
        _ = try? await CommunityAPI.call("block", ["profile_id": authorID.uuidString])
    }
}
