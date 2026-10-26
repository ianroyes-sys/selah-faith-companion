import SwiftUI

// MARK: - Prayer Relay — one prayer passed to you; carry it, it moves on.

struct RelayCard: View {
    @ObservedObject var community: CommunityStore
    @State private var showRelay = false

    var body: some View {
        Button {
            Haptics.tap(); showRelay = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Palette.bronze, Color(hex: 0x7A5C43)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Palette.cream)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("The Prayer Relay")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text(community.relayCarried > 0
                         ? "You've carried \(community.relayCarried) — keep it moving"
                         : "A prayer is waiting to be passed to you")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.taupe)
            }
            .padding(16)
            .glassCard(corner: 24)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showRelay) { RelaySheet(community: community) }
    }
}

struct RelaySheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss
    @State private var carrying = false

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Palette.sand)
                            .frame(width: 36, height: 36)
                            .background { Circle().fill(.white.opacity(0.1)) }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Palette.bronze)
                Spacer().frame(height: 16)
                Text("The Prayer Relay")
                    .font(.display(28))
                    .foregroundStyle(Palette.cream)
                Spacer().frame(height: 8)
                Text("A real request from a real person,\npassed to you. Pray it, then carry it on.")
                    .font(.label(13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.sand)
                    .lineSpacing(3)

                Spacer().frame(height: 32)

                if let prayer = community.relayPrayer {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("“\(prayer.body)”")
                            .font(.scripture(19))
                            .lineSpacing(6)
                            .foregroundStyle(Palette.cream)
                        HStack {
                            Text("— \(prayer.authorName)")
                                .font(.label(13, weight: .medium))
                                .foregroundStyle(Palette.sand)
                            Spacer()
                            if prayer.carriedCount > 0 {
                                Text("carried by \(prayer.carriedCount)")
                                    .font(.label(11, weight: .semibold))
                                    .foregroundStyle(Palette.bronze)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.white.opacity(0.07))
                    }
                    .padding(.horizontal, 26)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
                    .id(prayer.id)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 30))
                            .foregroundStyle(Palette.bronze)
                        Text("You've carried every prayer\non the wall right now.")
                            .font(.label(14))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.sand)
                            .lineSpacing(3)
                    }
                    .padding(.vertical, 30)
                }

                Spacer()

                if community.relayPrayer != nil {
                    Button {
                        guard !carrying else { return }
                        carrying = true
                        Haptics.success()
                        Task {
                            await community.carryRelay()
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { carrying = false }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if carrying { ProgressView().tint(Palette.espresso).scaleEffect(0.85) }
                            Text("I prayed it — pass it on")
                                .font(.label(16, weight: .semibold))
                        }
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 28)
                }
                Spacer().frame(height: 44)
            }
        }
        .task { await community.loadRelay() }
    }
}

// MARK: - Testimony card ("He answered" feed)

struct TestimonyCard: View {
    let testimony: Testimony
    @ObservedObject var community: CommunityStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.bronze)
                Text("He answered")
                    .font(.label(10, weight: .semibold))
                    .kerning(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.mocha)
                Spacer()
                Text(testimony.createdAt.formatted(.relative(presentation: .named)))
                    .font(.label(11))
                    .foregroundStyle(Palette.taupe)
            }
            Text(testimony.body)
                .font(.scripture(16))
                .lineSpacing(5)
                .foregroundStyle(Palette.ink)
            HStack {
                Text("— \(testimony.authorName)")
                    .font(.label(12, weight: .medium))
                    .foregroundStyle(Palette.mocha)
                Spacer()
                Button {
                    guard testimony.amenByMe != true else { return }
                    Haptics.success()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        Task { await community.amen(testimony) }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: testimony.amenByMe == true ? "hands.and.sparkles.fill" : "hands.and.sparkles")
                        Text(testimony.amenCount > 0 ? "Amen · \(testimony.amenCount)" : "Amen")
                    }
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(testimony.amenByMe == true ? Palette.onInk : Palette.onLinen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background { Capsule().fill(testimony.amenByMe == true ? Palette.ink : Palette.linen) }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .glassCard(corner: 26)
        .contextMenu {
            if testimony.isMine == true {
                Button(role: .destructive) {
                    Task { await community.deleteTestimony(testimony) }
                } label: { Label("Delete", systemImage: "trash") }
            } else {
                Button {
                    Task { await community.report(kind: "testimony", id: testimony.id) }
                } label: { Label("Report", systemImage: "flag") }
                Button(role: .destructive) {
                    Task { await community.block(authorID: testimony.authorId) }
                } label: { Label("Block this person", systemImage: "hand.raised") }
            }
        }
    }
}

// MARK: - Circles

struct CirclesSection: View {
    @ObservedObject var community: CommunityStore
    @EnvironmentObject var store: UserStore
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var showPaywall = false
    @State private var openCircle: CircleInfo?

    private var atFreeLimit: Bool { !store.isPremium && community.circles.count >= 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupsRail(community: community)

            HStack(spacing: 10) {
                actionChip("plus", "New circle") { atFreeLimit ? (showPaywall = true) : (showCreate = true) }
                actionChip("envelope.open", "Join with code") { atFreeLimit ? (showPaywall = true) : (showJoin = true) }
            }

            switch community.circleState {
            case .loading:
                loadingRows
            case .failed(let message):
                ErrorCard(message: message) { Task { await community.refreshCircles() } }
            default:
                if community.circles.isEmpty {
                    emptyState
                } else {
                    ForEach(community.circles) { circle in
                        Button {
                            Haptics.tap(); openCircle = circle
                        } label: {
                            CircleRow(circle: circle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreate) { CreateCircleSheet(community: community) }
        .sheet(isPresented: $showJoin) { JoinCircleSheet(community: community) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: $openCircle) { circle in CircleDetailSheet(circle: circle, community: community) }
        .task {
            await community.refreshCircles()
            await community.browseGroups()
        }
    }

    private func actionChip(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap(); action()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.label(13, weight: .semibold))
            }
            .foregroundStyle(Palette.onLinen)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background { Capsule().fill(Palette.linen) }
        }
        .buttonStyle(.plain)
    }

    private var loadingRows: some View {
        VStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Palette.linen.opacity(0.6))
                    .frame(height: 76)
            }
        }
        .redacted(reason: .placeholder)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 28))
                .foregroundStyle(Palette.taupe)
            Text("Faith is a group project")
                .font(.display(19))
                .foregroundStyle(Palette.ink)
            Text("Start a circle with your people — roommates,\nsmall group, your mom. Share prayers and\nmorning blessings only they can see.")
                .font(.label(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.mocha)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

struct CircleRow: View {
    let circle: CircleInfo

    private var subtitle: String {
        let members = "\(circle.memberCount) \(circle.memberCount == 1 ? "member" : "members")"
        if circle.isPublic == true, let tagline = circle.tagline, !tagline.isEmpty {
            return "\(members) · \(tagline)"
        }
        return "\(members) · code \(circle.inviteCode)"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Palette.blush).frame(width: 46, height: 46)
                if circle.isPublic == true, let symbol = circle.symbol, !symbol.isEmpty {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Palette.ink)
                } else {
                    Text(String(circle.name.prefix(1)).uppercased())
                        .font(.display(18))
                        .foregroundStyle(Palette.ink)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(circle.name)
                    .font(.label(15, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.label(12))
                    .foregroundStyle(Palette.mocha)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Palette.taupe)
        }
        .padding(16)
        .glassCard(corner: 24)
    }
}

struct CreateCircleSheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var created: CircleInfo?
    @State private var working = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(alignment: .leading, spacing: 18) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)

                if let created {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("“\(created.name)”\nis ready")
                            .font(.display(30))
                            .foregroundStyle(Palette.ink)
                        Text("Anyone with this code can join. Send it to your people.")
                            .font(.label(14))
                            .foregroundStyle(Palette.mocha)
                        HStack {
                            Spacer()
                            Text(created.inviteCode)
                                .font(.system(size: 34, weight: .semibold, design: .monospaced))
                                .kerning(6)
                                .foregroundStyle(Palette.bronze)
                            Spacer()
                        }
                        .padding(.vertical, 24)
                        .glassCard(corner: 24)
                        ShareLink(item: "Join my circle “\(created.name)” on Selah — code \(created.inviteCode). Download: https://selah.app") {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Invite your people")
                            }
                            .font(.label(16, weight: .semibold))
                            .foregroundStyle(Palette.onInk)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.ink) }
                        }
                        Button("Done") { dismiss() }
                            .font(.label(14, weight: .medium))
                            .foregroundStyle(Palette.mocha)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Text("Name your circle")
                        .font(.display(30))
                        .foregroundStyle(Palette.ink)
                    Text("Small on purpose — your roommates, your small group, your family.")
                        .font(.label(14))
                        .foregroundStyle(Palette.mocha)
                    TextField("The Girls, College Group, Fam…", text: $name)
                        .font(.scripture(20))
                        .padding(18)
                        .glassCard(corner: 22)
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.label(12))
                            .foregroundStyle(Color(hex: 0x9C4A38))
                    }
                    Button {
                        create()
                    } label: {
                        HStack(spacing: 8) {
                            if working { ProgressView().tint(Palette.onInk).scaleEffect(0.85) }
                            Text("Create circle")
                        }
                    }
                    .buttonStyle(BronzeButtonStyle())
                    .disabled(name.trimmingCharacters(in: .whitespaces).count < 2 || working)
                    .opacity(name.trimmingCharacters(in: .whitespaces).count < 2 ? 0.5 : 1)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(36)
    }

    private func create() {
        Haptics.tap()
        working = true
        errorMessage = nil
        Task {
            do {
                let circle = try await community.createCircle(named: name.trimmingCharacters(in: .whitespaces))
                Haptics.success()
                withAnimation { created = circle }
            } catch {
                errorMessage = error.localizedDescription
            }
            working = false
        }
    }
}

struct JoinCircleSheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var working = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(alignment: .leading, spacing: 18) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)
                Text("Join a circle")
                    .font(.display(30))
                    .foregroundStyle(Palette.ink)
                Text("Enter the 6-letter code a friend sent you.")
                    .font(.label(14))
                    .foregroundStyle(Palette.mocha)
                TextField("ABC123", text: $code)
                    .font(.system(size: 26, weight: .semibold, design: .monospaced))
                    .kerning(4)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                    .padding(18)
                    .glassCard(corner: 22)
                if let errorMessage {
                    Text(errorMessage)
                        .font(.label(12))
                        .foregroundStyle(Color(hex: 0x9C4A38))
                }
                Button {
                    join()
                } label: {
                    HStack(spacing: 8) {
                        if working { ProgressView().tint(Palette.onInk).scaleEffect(0.85) }
                        Text("Join")
                    }
                }
                .buttonStyle(BronzeButtonStyle())
                .disabled(code.trimmingCharacters(in: .whitespaces).count < 4 || working)
                .opacity(code.trimmingCharacters(in: .whitespaces).count < 4 ? 0.5 : 1)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(36)
    }

    private func join() {
        Haptics.tap()
        working = true
        errorMessage = nil
        Task {
            do {
                _ = try await community.joinCircle(code: code.trimmingCharacters(in: .whitespaces))
                Haptics.success()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            working = false
        }
    }
}

// MARK: Circle detail — shared prayers + blessings.

struct CircleDetailSheet: View {
    let circle: CircleInfo
    @ObservedObject var community: CommunityStore
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var composeMode: ComposeMode = .prayer
    @State private var sending = false
    @State private var errorMessage: String?

    enum ComposeMode: String, CaseIterable { case prayer = "Prayer", blessing = "Blessing" }

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(spacing: 0) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5).padding(.top, 14)
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(circle.name)
                            .font(.display(26))
                            .foregroundStyle(Palette.ink)
                        Text("\(circle.memberCount) \(circle.memberCount == 1 ? "member" : "members") · code \(circle.inviteCode)")
                            .font(.label(12))
                            .foregroundStyle(Palette.mocha)
                    }
                    Spacer()
                    ShareLink(item: "Join my circle “\(circle.name)” on Selah — code \(circle.inviteCode). Download: https://selah.app") {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Palette.onLinen)
                            .frame(width: 40, height: 40)
                            .background { Circle().fill(Palette.linen) }
                    }
                    Menu {
                        Button(role: .destructive) {
                            Task { await community.leaveCircle(circle) }
                            dismiss()
                        } label: { Label("Leave circle", systemImage: "rectangle.portrait.and.arrow.right") }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Palette.onLinen)
                            .frame(width: 40, height: 40)
                            .background { Circle().fill(Palette.linen) }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        let blessings = community.circleBlessings[circle.id] ?? []
                        let prayers = community.circlePrayers[circle.id] ?? []
                        let members = community.circleMembers[circle.id] ?? []

                        if !members.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Today's check-ins".uppercased())
                                        .font(.label(10, weight: .semibold))
                                        .kerning(1.2)
                                        .foregroundStyle(Palette.mocha)
                                    Spacer()
                                    Text("\(members.filter(\.checkedInToday).count) of \(members.count)")
                                        .font(.label(11, weight: .semibold))
                                        .foregroundStyle(Palette.bronze)
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(members) { member in
                                            VStack(spacing: 5) {
                                                ZStack(alignment: .bottomTrailing) {
                                                    Circle()
                                                        .fill(member.checkedInToday ? Palette.bronze.opacity(0.25) : Palette.linen.opacity(0.6))
                                                        .frame(width: 44, height: 44)
                                                    Text(String(member.name.prefix(1)).uppercased())
                                                        .font(.display(16))
                                                        .foregroundStyle(member.checkedInToday ? Palette.bronze : Palette.onLinenSoft)
                                                        .frame(width: 44, height: 44)
                                                    if member.checkedInToday {
                                                        Circle().fill(Palette.sage).frame(width: 11, height: 11)
                                                            .overlay { Circle().strokeBorder(Palette.canvas, lineWidth: 2) }
                                                    }
                                                }
                                                Text(member.isMe ? "You" : String(member.name.split(separator: " ").first ?? "—"))
                                                    .font(.label(10, weight: .medium))
                                                    .foregroundStyle(Palette.mocha)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .glassCard(corner: 24)
                        }

                        if !blessings.isEmpty {
                            ForEach(blessings.prefix(3)) { blessing in
                                BlessingRow(blessing: blessing)
                            }
                        }
                        if prayers.isEmpty && blessings.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Palette.taupe)
                                Text("Nothing here yet — be the first.\nLay down a prayer or send a blessing.")
                                    .font(.label(13))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Palette.mocha)
                                    .lineSpacing(3)
                            }
                            .padding(.vertical, 44)
                        }
                        ForEach(prayers) { prayer in
                            CommunityWallCard(prayer: prayer, community: community, circleID: circle.id)
                        }
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                }

                // Composer
                VStack(spacing: 10) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.label(11))
                            .foregroundStyle(Color(hex: 0x9C4A38))
                    }
                    HStack(spacing: 8) {
                        ForEach(ComposeMode.allCases, id: \.self) { mode in
                            Button { composeMode = mode } label: {
                                PillChip(text: mode.rawValue, selected: composeMode == mode)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        TextField(composeMode == .prayer
                                  ? "What can they stand with you for?"
                                  : "Speak something kind over them…",
                                  text: $draft, axis: .vertical)
                            .font(.label(15))
                            .lineLimit(1...3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Palette.field)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .strokeBorder(Palette.sand.opacity(0.7), lineWidth: 1)
                                    }
                            }
                        Button {
                            send()
                        } label: {
                            if sending {
                                ProgressView().tint(Palette.onInk)
                                    .frame(width: 44, height: 44)
                                    .background { Circle().fill(Palette.ink) }
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Palette.onInk)
                                    .frame(width: 44, height: 44)
                                    .background { Circle().fill(Palette.ink) }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || sending)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
                .padding(.top, 6)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .task { await community.loadCircleFeed(circle) }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Haptics.tap()
        sending = true
        errorMessage = nil
        Task {
            do {
                if composeMode == .prayer {
                    try await community.postPrayer(text, authorName: store.name.isEmpty ? "Anonymous" : store.name, circleID: circle.id)
                } else {
                    try await community.sendBlessing(text, to: circle, authorName: store.name.isEmpty ? "Anonymous" : store.name)
                }
                Haptics.success()
                draft = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            sending = false
        }
    }
}

struct BlessingRow: View {
    let blessing: Blessing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sun.and.horizon")
                .font(.system(size: 15))
                .foregroundStyle(Palette.bronze)
            VStack(alignment: .leading, spacing: 4) {
                Text(blessing.body)
                    .font(.scripture(15))
                    .lineSpacing(3)
                    .foregroundStyle(Palette.ink)
                Text("\(blessing.authorName) · \(blessing.createdAt.formatted(.relative(presentation: .named)))")
                    .font(.label(11))
                    .foregroundStyle(Palette.taupe)
            }
            Spacer()
        }
        .padding(16)
        .solidCard(corner: 22, fill: Palette.blush.opacity(0.5))
        .contextMenu {
            if blessing.isMine != true {
                Button {
                    Task { await CommunityStore.shared.report(kind: "blessing", id: blessing.id) }
                } label: { Label("Report", systemImage: "flag") }
                if let author = blessing.authorId {
                    Button(role: .destructive) {
                        Task { await CommunityStore.shared.block(authorID: author) }
                    } label: { Label("Block this person", systemImage: "hand.raised") }
                }
            }
        }
    }
}

// MARK: - Community wall card (server-backed)

struct CommunityWallCard: View {
    let prayer: CommunityPrayer
    @ObservedObject var community: CommunityStore
    var circleID: UUID? = nil

    private var prayed: Bool { prayer.prayedByMe == true }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(prayer.authorName)
                    .font(.label(12, weight: .semibold))
                    .foregroundStyle(Palette.mocha)
                if prayer.isMine == true {
                    Text("You")
                        .font(.label(10, weight: .semibold))
                        .foregroundStyle(Palette.cream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background { Capsule().fill(Palette.bronze) }
                }
                Spacer()
                Text(prayer.createdAt.formatted(.relative(presentation: .named)))
                    .font(.label(11))
                    .foregroundStyle(Palette.taupe)
            }
            Text(prayer.body)
                .font(.label(15))
                .lineSpacing(4)
                .foregroundStyle(Palette.ink)
            HStack {
                Button {
                    guard !prayed else { return }
                    Haptics.success()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        Task { await community.pray(for: prayer, inCircle: circleID) }
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: prayed ? "hands.and.sparkles.fill" : "hands.and.sparkles")
                        Text(prayed ? "Prayed" : "I prayed")
                    }
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(prayed ? Palette.onInk : Palette.onLinen)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background { Capsule().fill(prayed ? Palette.ink : Palette.linen) }
                }
                .buttonStyle(.plain)
                Spacer()
                if prayer.prayedCount > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.bronze)
                        Text("\(prayer.prayedCount) prayed")
                            .font(.label(12, weight: .medium))
                            .foregroundStyle(Palette.mocha)
                    }
                }
            }
        }
        .padding(20)
        .glassCard(corner: 26)
        .contextMenu {
            if prayer.isMine == true {
                Button(role: .destructive) {
                    Task { await community.deletePrayer(prayer) }
                } label: { Label("Delete", systemImage: "trash") }
            } else {
                Button {
                    Task { await community.report(kind: "prayer", id: prayer.id) }
                } label: { Label("Report", systemImage: "flag") }
                Button(role: .destructive) {
                    Task { await community.block(authorID: prayer.authorId) }
                } label: { Label("Block this person", systemImage: "hand.raised") }
            }
        }
    }
}

// MARK: - Shared bits

struct ErrorCard: View {
    let message: String
    var retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 24))
                .foregroundStyle(Palette.taupe)
            Text(message)
                .font(.label(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.mocha)
            Button {
                Haptics.tap(); retry()
            } label: {
                Text("Try again")
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(Palette.onInk)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background { Capsule().fill(Palette.ink) }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .glassCard(corner: 26)
    }
}

// MARK: - Community guidelines (shown before the first post)

struct GuidelinesSheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss
    var onAccept: () -> Void

    private let rules: [(String, String)] = [
        ("heart", "Be gentle. People bring their rawest moments here."),
        ("eye.slash", "Share your story, not other people's."),
        ("hand.raised", "No hate, harassment, or explicit content — ever."),
        ("flag", "See something off? Report it. Three reports hide a post.")
    ]

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(alignment: .leading, spacing: 22) {
                Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)
                Text("Keep it kind")
                    .font(.display(32))
                    .foregroundStyle(Palette.cream)
                Text("The wall works because it's safe. Before your first post, a few ground rules:")
                    .font(.label(14))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.sand)
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(rules, id: \.1) { rule in
                        HStack(spacing: 14) {
                            Image(systemName: rule.0)
                                .font(.system(size: 15))
                                .foregroundStyle(Palette.bronze)
                                .frame(width: 26)
                            Text(rule.1)
                                .font(.label(14, weight: .medium))
                                .foregroundStyle(Palette.cream.opacity(0.92))
                        }
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.white.opacity(0.06))
                }
                Spacer()
                Button {
                    Haptics.success()
                    community.guidelinesAccepted = true
                    dismiss()
                    onAccept()
                } label: {
                    Text("I'm in")
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 26)
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}
