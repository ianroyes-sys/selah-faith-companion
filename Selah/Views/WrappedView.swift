import SwiftUI

// MARK: - Faith Wrapped — your month with God, as a story-ready share card.
// Selah+ feature: full stats + mood insights + shareable image.

struct WrappedSheet: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var community = CommunityStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false
    @State private var rendered: UIImage?

    private var monthName: String {
        Date().formatted(.dateTime.month(.wide))
    }

    private var monthEntries: [JournalEntry] {
        let cal = Calendar.current
        return store.journal.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    private var monthAnswered: Int {
        let cal = Calendar.current
        return store.answeredPrayers.filter {
            guard let d = $0.answeredAt else { return false }
            return cal.isDate(d, equalTo: Date(), toGranularity: .month)
        }.count
    }

    private var moodCounts: [(mood: Mood, count: Int)] {
        var counts: [Mood: Int] = [:]
        for entry in monthEntries { counts[entry.mood, default: 0] += 1 }
        if let today = store.todayMood { counts[today, default: 0] += 0 }
        return counts.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }

    private var topMood: Mood? { moodCounts.first?.mood }

    var body: some View {
        ZStack {
            DuskBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    Text("FAITH WRAPPED")
                        .font(.display(13))
                        .kerning(4)
                        .foregroundStyle(Palette.bronze)
                    Text("Your \(monthName),\nwith God")
                        .font(.display(34))
                        .foregroundStyle(Palette.cream)

                    if store.isPremium {
                        statsGrid
                        if !moodCounts.isEmpty { moodInsights }
                        if let pattern = store.moodPattern {
                            HStack(spacing: 10) {
                                Image(systemName: "sparkle")
                                    .foregroundStyle(Palette.bronze)
                                Text("Selah noticed: you often feel \(pattern.mood.rawValue) on \(pattern.weekday)s. Worth praying into.")
                                    .font(.label(13))
                                    .lineSpacing(3)
                                    .foregroundStyle(Palette.sand)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(.white.opacity(0.06))
                            }
                        }
                        if let rendered {
                            ShareLink(
                                item: Image(uiImage: rendered),
                                preview: SharePreview("My \(monthName) with God", image: Image(uiImage: rendered))
                            ) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share your Wrapped")
                                }
                                .font(.label(16, weight: .semibold))
                                .foregroundStyle(Palette.espresso)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background { Capsule().fill(Palette.cream) }
                            }
                            .simultaneousGesture(TapGesture().onEnded { Haptics.success() })
                        }
                    } else {
                        lockedTeaser
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 26)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .onAppear { if store.isPremium { render() } }
        .onChange(of: store.isPremium) { _, premium in if premium { render() } }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
            wrappedStat("\(store.streak)", "day streak", "flame.fill")
            wrappedStat("\(community.checkInStreak)", "heart check-ins", "heart.fill")
            wrappedStat("\(community.communityPrayed)", "prayers carried", "hands.and.sparkles.fill")
            wrappedStat("\(monthAnswered)", "answered this month", "checkmark.seal.fill")
            wrappedStat("\(monthEntries.count)", "journal entries", "book.fill")
            wrappedStat("\(store.versesRead)", "verses unpacked", "text.book.closed.fill")
        }
    }

    private func wrappedStat(_ value: String, _ label: String, _ icon: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Palette.bronze)
            Text(value)
                .font(.display(26))
                .foregroundStyle(Palette.cream)
            Text(label)
                .font(.label(11))
                .foregroundStyle(Palette.taupe)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }

    private var moodInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your heart this month".uppercased())
                .font(.label(11, weight: .semibold))
                .kerning(1.4)
                .foregroundStyle(Palette.taupe)
            let maxCount = moodCounts.first?.count ?? 1
            ForEach(moodCounts.prefix(4), id: \.mood) { item in
                HStack(spacing: 10) {
                    Image(systemName: item.mood.symbol)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.bronze)
                        .frame(width: 20)
                    Text(item.mood.title)
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Palette.cream)
                        .frame(width: 96, alignment: .leading)
                    GeometryReader { geo in
                        Capsule()
                            .fill(Palette.bronze.opacity(0.85))
                            .frame(width: max(10, geo.size.width * CGFloat(item.count) / CGFloat(maxCount)), height: 8)
                            .frame(maxHeight: .infinity)
                    }
                    Text("\(item.count)")
                        .font(.label(12, weight: .semibold))
                        .foregroundStyle(Palette.sand)
                }
                .frame(height: 20)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }

    private var lockedTeaser: some View {
        VStack(spacing: 16) {
            statsGrid
                .blur(radius: 9)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 26))
                            .foregroundStyle(Palette.bronze)
                        Text("Your month is ready")
                            .font(.display(22))
                            .foregroundStyle(Palette.cream)
                        Text("Streaks, answered prayers, mood insights,\nand a share card made from your real walk.")
                            .font(.label(13))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.sand)
                            .lineSpacing(3)
                        Button {
                            Haptics.tap(); showPaywall = true
                        } label: {
                            Text("Unwrap with Selah+")
                                .font(.label(15, weight: .semibold))
                                .foregroundStyle(Palette.espresso)
                                .padding(.horizontal, 26)
                                .padding(.vertical, 13)
                                .background { Capsule().fill(Palette.cream) }
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
    }

    @MainActor
    private func render() {
        let card = WrappedCard(
            month: monthName,
            streak: store.streak,
            carried: community.communityPrayed,
            answered: monthAnswered,
            topMood: topMood
        )
        let renderer = ImageRenderer(content: card.frame(width: 540, height: 960))
        renderer.scale = 2
        rendered = renderer.uiImage
    }
}

// MARK: The story-format share card (fixed colors — renders to an image).

struct WrappedCard: View {
    let month: String
    let streak: Int
    let carried: Int
    let answered: Int
    let topMood: Mood?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x402F22), Color(hex: 0x2C1F16)],
                           startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(Color(hex: 0xB08347).opacity(0.25))
                .frame(width: 380)
                .blur(radius: 90)
                .offset(y: -300)
            VStack(spacing: 0) {
                Spacer()
                Text("MY \(month.uppercased()) WITH GOD")
                    .font(.system(size: 15, weight: .semibold))
                    .kerning(3)
                    .foregroundStyle(Color(hex: 0xB08347))
                Spacer().frame(height: 36)
                VStack(spacing: 28) {
                    bigStat("\(streak)", "day streak")
                    bigStat("\(carried)", "prayers carried for others")
                    bigStat("\(answered)", "prayers answered")
                    if let topMood {
                        VStack(spacing: 6) {
                            Image(systemName: topMood.symbol)
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(Color(hex: 0xD9C6AC))
                            Text("mostly \(topMood.rawValue), held anyway")
                                .font(.system(size: 16, design: .serif))
                                .italic()
                                .foregroundStyle(Color(hex: 0xF7F2EA).opacity(0.9))
                        }
                    }
                }
                Spacer()
                Text("SELAH")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .kerning(5)
                    .foregroundStyle(Color(hex: 0xF7F2EA).opacity(0.5))
                    .padding(.bottom, 40)
            }
        }
    }

    private func bigStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 64, weight: .medium, design: .serif))
                .foregroundStyle(Color(hex: 0xF7F2EA))
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: 0xD9C6AC))
        }
    }
}
