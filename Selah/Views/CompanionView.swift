import SwiftUI

struct CompanionView: View {
    @EnvironmentObject var store: UserStore
    @State private var messages: [ChatMessage] = []
    @State private var draft = ""
    @State private var thinking = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(spacing: 0) {
                header
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            if messages.isEmpty { emptyState }
                            ForEach(messages) { m in
                                bubble(m)
                            }
                            if thinking { typingIndicator }
                            Color.clear.frame(height: 8).id("bottom")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
                inputBar
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Companion")
                .font(.display(24))
                .foregroundStyle(Palette.ink)
            Text(IntelligenceEngine.onDeviceModelAvailable
                 ? "On-device · Private · Always free to talk"
                 : "Scripture-guided · Private")
                .font(.label(11))
                .foregroundStyle(Palette.mocha)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "hands.and.sparkles")
                .font(.system(size: 34))
                .foregroundStyle(Palette.bronze)
            Text("What's on your heart?")
                .font(.display(22))
                .foregroundStyle(Palette.ink)
            Text("Vent, ask, wonder, doubt — Selah listens\nand answers with scripture, not judgment.")
                .font(.label(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.mocha)
                .lineSpacing(3)
            VStack(spacing: 8) {
                ForEach(["I'm anxious about my future", "I keep falling into the same sin", "Why does God feel silent?"], id: \.self) { s in
                    Button {
                        draft = s; send()
                    } label: {
                        Text(s)
                            .font(.label(13, weight: .medium))
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .glassCard(corner: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 60)
    }

    private func bubble(_ m: ChatMessage) -> some View {
        HStack {
            if m.role == .user { Spacer(minLength: 50) }
            Text(m.text)
                .font(.label(15))
                .lineSpacing(4)
                .foregroundStyle(m.role == .user ? Palette.onInk : Palette.onLinen)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(m.role == .user ? Palette.ink : Palette.linen)
                }
            if m.role == .companion { Spacer(minLength: 50) }
        }
    }

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Palette.onLinenSoft).frame(width: 7, height: 7)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background { RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.linen) }
            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Talk to Selah…", text: $draft, axis: .vertical)
                .font(.label(15))
                .lineLimit(1...4)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background {
                    Capsule().fill(Palette.field)
                        .overlay { Capsule().strokeBorder(Palette.sand.opacity(0.7), lineWidth: 1) }
                }
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.onInk)
                    .frame(width: 44, height: 44)
                    .background { Circle().fill(Palette.ink) }
            }
            .buttonStyle(.plain)
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || thinking)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 84)
        .padding(.top, 8)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !thinking else { return }
        guard store.canChat else { showPaywall = true; return }
        Haptics.tap()
        draft = ""
        messages.append(ChatMessage(role: .user, text: text))
        store.freeChatToday += 1
        thinking = true
        Task {
            let reply = await IntelligenceEngine.companionReply(history: messages, userName: store.name, memory: store.memoryContext())
            thinking = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                messages.append(ChatMessage(role: .companion, text: reply))
            }
        }
    }
}
