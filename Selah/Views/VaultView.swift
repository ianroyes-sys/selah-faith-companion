import SwiftUI

// MARK: - Answered Prayer Vault ("Ebenezer Stones")
// Personal prayers tracked over time; answered ones become evidence.

struct VaultSection: View {
    @EnvironmentObject var store: UserStore
    @State private var newPrayer = ""
    @State private var answering: PersonalPrayer?
    @State private var showPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            composer
            if let followUp = store.followUpCandidate {
                FollowUpCard(prayer: followUp) { answering = followUp }
            }
            if !store.answeredPrayers.isEmpty {
                Text("Stones of remembrance".uppercased())
                    .font(.label(11, weight: .semibold))
                    .kerning(1.4)
                    .foregroundStyle(Palette.mocha)
                ForEach(store.answeredPrayers) { p in
                    AnsweredStone(prayer: p)
                }
            }
            if !store.openPrayers.isEmpty {
                Text("Still praying".uppercased())
                    .font(.label(11, weight: .semibold))
                    .kerning(1.4)
                    .foregroundStyle(Palette.mocha)
                ForEach(store.openPrayers) { p in
                    OpenPrayerCard(prayer: p, onAnswered: { answering = p }, onReminder: {
                        if store.isPremium {
                            Haptics.soft()
                            store.toggleReminder(for: p)
                            if store.remindedPrayers.contains(p.id.uuidString) {
                                Task { await NotificationService.shared.requestAuthorization() }
                            }
                        } else {
                            showPaywall = true
                        }
                    })
                }
            }
            if store.vault.isEmpty { emptyState }
        }
        .sheet(item: $answering) { p in AnsweredSheet(prayer: p) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("What are you asking God for?", text: $newPrayer, axis: .vertical)
                .font(.label(15))
                .lineLimit(1...3)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Palette.field)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(Palette.sand.opacity(0.7), lineWidth: 1)
                        }
                }
            Button {
                let t = newPrayer.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty else { return }
                Haptics.success()
                withAnimation { store.addVaultPrayer(t) }
                newPrayer = ""
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.cream)
                    .frame(width: 44, height: 44)
                    .background { Circle().fill(Palette.bronze) }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 28))
                .foregroundStyle(Palette.taupe)
            Text("Your vault is waiting")
                .font(.display(19))
                .foregroundStyle(Palette.ink)
            Text("Drop a prayer in. Selah will follow up,\nand when God answers, it becomes a stone\nyou can stand on next time.")
                .font(.label(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.mocha)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: Follow-up — Selah remembers and asks.

struct FollowUpCard: View {
    let prayer: PersonalPrayer
    var onAnswered: () -> Void
    @EnvironmentObject var store: UserStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .foregroundStyle(Palette.bronze)
                Text("Selah remembers")
                    .font(.label(11, weight: .semibold))
                    .kerning(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.sand)
            }
            Text("\(prayer.createdAt.formatted(.relative(presentation: .named)).capitalized) you prayed about “\(prayer.text)”. Any movement?")
                .font(.scripture(17))
                .lineSpacing(4)
                .foregroundStyle(Palette.cream)
            HStack(spacing: 10) {
                Button {
                    Haptics.success(); onAnswered()
                } label: {
                    Text("God answered")
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                Button {
                    Haptics.soft()
                } label: {
                    Text("Still waiting")
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Palette.sand)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background { Capsule().fill(.white.opacity(0.12)) }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

struct AnsweredStone: View {
    let prayer: PersonalPrayer

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Palette.bronze.opacity(0.18)).frame(width: 40, height: 40)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Palette.bronze)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(prayer.text)
                    .font(.label(14, weight: .medium))
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(3)
                if !prayer.answeredNote.isEmpty {
                    Text("“\(prayer.answeredNote)”")
                        .font(.scripture(14))
                        .italic()
                        .foregroundStyle(Palette.mocha)
                }
                if let d = prayer.answeredAt {
                    Text("Answered \(d.formatted(date: .abbreviated, time: .omitted))")
                        .font(.label(11))
                        .foregroundStyle(Palette.taupe)
                }
            }
            Spacer()
        }
        .padding(16)
        .solidCard(corner: 24, fill: Palette.blush.opacity(0.5))
    }
}

struct OpenPrayerCard: View {
    let prayer: PersonalPrayer
    var onAnswered: () -> Void
    var onReminder: () -> Void = {}
    @EnvironmentObject var store: UserStore

    private var reminded: Bool { store.remindedPrayers.contains(prayer.id.uuidString) }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "hourglass")
                .font(.system(size: 15))
                .foregroundStyle(Palette.taupe)
            VStack(alignment: .leading, spacing: 3) {
                Text(prayer.text)
                    .font(.label(14))
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(3)
                Text("Since \(prayer.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.label(11))
                    .foregroundStyle(Palette.taupe)
            }
            Spacer()
            Button {
                onReminder()
            } label: {
                Image(systemName: reminded ? "bell.fill" : "bell")
                    .font(.system(size: 14))
                    .foregroundStyle(reminded ? Palette.bronze : Palette.onLinenSoft)
                    .frame(width: 36, height: 36)
                    .background { Circle().fill(reminded ? Palette.bronze.opacity(0.18) : Palette.linen) }
            }
            .buttonStyle(.plain)
            Button {
                onAnswered()
            } label: {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 16))
                    .foregroundStyle(Palette.onLinenSoft)
                    .frame(width: 36, height: 36)
                    .background { Circle().fill(Palette.linen) }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .glassCard(corner: 24)
    }
}

// MARK: Mark answered

struct AnsweredSheet: View {
    let prayer: PersonalPrayer
    @EnvironmentObject var store: UserStore
    @ObservedObject private var community = CommunityStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var placed = false
    @State private var anonymous = true
    @State private var sharing = false
    @State private var errorMessage: String?

    private var testimonyText: String {
        let base = "I prayed about “\(prayer.text)” — and God answered."
        let n = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return n.isEmpty ? base : base + " " + n
    }

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(alignment: .leading, spacing: 20) {
                Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)

                if placed {
                    // Step 2 — offer to share to the "He answered" feed.
                    Text("Tell somebody?")
                        .font(.display(32))
                        .foregroundStyle(Palette.cream)
                    Text("Answered prayers build other people's faith. Share this one to the Answered feed — a feed made of nothing but God coming through.")
                        .font(.label(14))
                        .lineSpacing(4)
                        .foregroundStyle(Palette.sand)
                    Text(testimonyText)
                        .font(.scripture(16))
                        .lineSpacing(5)
                        .foregroundStyle(Palette.cream)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.white.opacity(0.07))
                        }
                    Button {
                        Haptics.soft()
                        withAnimation { anonymous.toggle() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: anonymous ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(anonymous ? Palette.bronze : Palette.taupe)
                            Text(anonymous || store.name.isEmpty
                                 ? "Share anonymously"
                                 : "Share as \(store.name)")
                                .font(.label(13, weight: .medium))
                                .foregroundStyle(Palette.sand)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.label(12))
                            .foregroundStyle(Color(hex: 0xD98873))
                    }
                    Spacer()
                    Button {
                        share()
                    } label: {
                        HStack(spacing: 8) {
                            if sharing { ProgressView().tint(Palette.espresso).scaleEffect(0.85) }
                            Text("Share the answer")
                                .font(.label(16, weight: .semibold))
                        }
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .disabled(sharing)
                    Button("Keep it just between us") { dismiss() }
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Palette.sand.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 30)
                } else {
                    // Step 1 — place the stone.
                    Text("He answered.")
                        .font(.display(32))
                        .foregroundStyle(Palette.cream)
                    Text("“\(prayer.text)”")
                        .font(.scripture(17))
                        .lineSpacing(4)
                        .foregroundStyle(Palette.sand)
                    TextField("", text: $note, prompt: Text("How did it happen?").foregroundStyle(Palette.taupe), axis: .vertical)
                        .font(.label(15))
                        .foregroundStyle(Palette.cream)
                        .lineLimit(3...6)
                        .padding(18)
                        .background {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white.opacity(0.08))
                        }
                    Text("This becomes a stone in your vault — evidence for the next hard season.")
                        .font(.label(12))
                        .foregroundStyle(Palette.taupe)
                    Spacer()
                    Button {
                        Haptics.success()
                        store.markAnswered(prayer, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { placed = true }
                    } label: {
                        Text("Place the stone")
                            .font(.label(16, weight: .semibold))
                            .foregroundStyle(Palette.espresso)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 30)
                }
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }

    private func share() {
        Haptics.tap()
        sharing = true
        errorMessage = nil
        Task {
            do {
                let author = anonymous || store.name.isEmpty ? "Anonymous" : store.name
                try await community.postTestimony(testimonyText, authorName: author)
                Haptics.success()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            sharing = false
        }
    }
}
