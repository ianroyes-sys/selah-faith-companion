import SwiftUI

// MARK: - The Commons — one global room, no names, no followers, no judgment.
// Everyone gets a poetic handle that rotates at midnight ("Golden Wren"),
// so people can be fully honest without being found.

enum CommonsPrompts {
    static let prompts: [String] = [
        "What's something you believe about God that you'd be nervous to say out loud at church?",
        "What are you carrying this week that nobody knows about?",
        "Where did you see God show up in the last 24 hours?",
        "What's a prayer you've almost given up on?",
        "What does rest actually look like for you right now?",
        "What's one doubt you're sitting with — no judgment here?",
        "Who's someone you're struggling to forgive?",
        "What's the kindest thing anyone has done for you this month?",
        "If you could ask God one question tonight, what would it be?",
        "What's a habit you're trying to break — or build?",
        "What scripture has been following you around lately?",
        "What made you smile today?",
        "What's something you're waiting on that feels overdue?",
        "Where do you feel most at peace?",
    ]

    static var today: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[day % prompts.count]
    }
}

// MARK: - Entry card (lives on the Pray tab)

struct CommonsCard: View {
    @ObservedObject var community: CommunityStore
    @State private var open = false

    var body: some View {
        Button {
            Haptics.tap(); open = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Palette.bronze, Palette.espresso],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 46, height: 46)
                        Image(systemName: "theatermasks")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Palette.cream)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("The Commons")
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.cream)
                        Text("The anonymous room — say the real thing")
                            .font(.label(12))
                            .foregroundStyle(Palette.sand)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Palette.sand)
                }
                HStack(spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.bronze)
                    Text(CommonsPrompts.today)
                        .font(.scripture(13))
                        .italic()
                        .foregroundStyle(Palette.sand)
                        .lineLimit(2)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $open) { CommonsSheet(community: community) }
    }
}

// MARK: - The room

struct CommonsSheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var sending = false
    @State private var errorMessage: String?
    @State private var showGuidelines = false

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(spacing: 0) {
                header
                identityBanner
                messages
                composer
            }
        }
        .task {
            await community.refreshCommons()
            // Gentle polling while the room is open — feels live, costs nothing.
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                guard !Task.isCancelled else { break }
                await community.refreshCommons()
            }
        }
        .sheet(isPresented: $showGuidelines) {
            GuidelinesSheet(community: community) { send() }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("The Commons")
                    .font(.display(24))
                    .foregroundStyle(Palette.cream)
                Text("No names. No history. Just honesty.")
                    .font(.label(11))
                    .foregroundStyle(Palette.sand)
            }
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
    }

    @ViewBuilder private var identityBanner: some View {
        if !community.myHandle.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.bronze)
                Text("Tonight you are **\(community.myHandle)** — a new name every day")
                    .font(.label(12))
                    .foregroundStyle(Palette.sand)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule().fill(.white.opacity(0.07))
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
        }
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    promptCard
                    switch community.commonsState {
                    case .idle, .loading:
                        if community.commons.isEmpty {
                            ProgressView().tint(Palette.sand).padding(.top, 60)
                        }
                    case .failed(let message):
                        Text(message)
                            .font(.label(13))
                            .foregroundStyle(Palette.sand)
                            .padding(.top, 60)
                    case .loaded:
                        if community.commons.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "moon.stars")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Palette.bronze)
                                Text("The room is quiet.\nSay the thing you can't say anywhere else.")
                                    .font(.label(13))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Palette.sand)
                                    .lineSpacing(3)
                            }
                            .padding(.top, 60)
                        }
                    }
                    ForEach(community.commons) { message in
                        CommonsBubble(message: message, community: community)
                            .id(message.id)
                    }
                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
            }
            .onChange(of: community.commons.count) {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onAppear {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tonight's question".uppercased())
                .font(.label(9, weight: .semibold))
                .kerning(1.2)
                .foregroundStyle(Palette.bronze)
            Text(CommonsPrompts.today)
                .font(.scripture(15))
                .italic()
                .lineSpacing(4)
                .foregroundStyle(Palette.cream)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Palette.bronze.opacity(0.25), lineWidth: 1)
                }
        }
        .padding(.bottom, 6)
    }

    private var composer: some View {
        VStack(spacing: 8) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.label(11))
                    .foregroundStyle(Color(hex: 0xD98E7A))
            }
            HStack(spacing: 10) {
                TextField("Speak freely…", text: $draft, axis: .vertical)
                    .font(.label(15))
                    .lineLimit(1...4)
                    .foregroundStyle(Palette.cream)
                    .tint(Palette.bronze)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .overlay {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                            }
                    }
                Button {
                    if community.guidelinesAccepted { send() } else { showGuidelines = true }
                } label: {
                    if sending {
                        ProgressView().tint(Palette.espresso)
                            .frame(width: 44, height: 44)
                            .background { Circle().fill(Palette.cream) }
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Palette.espresso)
                            .frame(width: 44, height: 44)
                            .background { Circle().fill(Palette.cream) }
                    }
                }
                .buttonStyle(.plain)
                .disabled(draft.trimmingCharacters(in: .whitespaces).count < 2 || sending)
                .opacity(draft.trimmingCharacters(in: .whitespaces).count < 2 ? 0.5 : 1)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= 2, !sending else { return }
        Haptics.tap()
        sending = true
        errorMessage = nil
        Task {
            do {
                try await community.sendToCommons(text)
                Haptics.success()
                draft = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            sending = false
        }
    }
}

// MARK: - Message bubble

struct CommonsBubble: View {
    let message: CommonsMessage
    @ObservedObject var community: CommunityStore

    private var mine: Bool { message.isMine == true }

    var body: some View {
        HStack {
            if mine { Spacer(minLength: 48) }
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(mine ? "You · \(message.handle)" : message.handle)
                        .font(.label(10, weight: .semibold))
                        .foregroundStyle(mine ? Palette.espresso.opacity(0.65) : Palette.bronze)
                    Text(message.createdAt.formatted(.relative(presentation: .named)))
                        .font(.label(9))
                        .foregroundStyle(mine ? Palette.espresso.opacity(0.4) : Palette.sand.opacity(0.55))
                }
                Text(message.body)
                    .font(.label(14))
                    .lineSpacing(3)
                    .foregroundStyle(mine ? Palette.espresso : Palette.cream)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(mine ? Palette.cream : Color.white.opacity(0.08))
            }
            .contextMenu {
                if mine {
                    Button(role: .destructive) {
                        Task { await community.deleteCommonsMessage(message) }
                    } label: { Label("Delete", systemImage: "trash") }
                } else {
                    Button {
                        Task { await community.report(kind: "chat", id: message.id) }
                    } label: { Label("Report", systemImage: "flag") }
                    Button(role: .destructive) {
                        Task { await community.blockInCommons(authorID: message.authorId) }
                    } label: { Label("Block this person", systemImage: "hand.raised") }
                }
            }
            if !mine { Spacer(minLength: 48) }
        }
    }
}
