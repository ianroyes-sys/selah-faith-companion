import SwiftUI

struct GrowView: View {
    @EnvironmentObject var store: UserStore
    @State private var showPaywall = false
    @State private var selectedPlan: ReadingPlan?

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Grow")
                            .font(.display(30))
                            .foregroundStyle(Palette.ink)
                        Text("Plans built for the season you're actually in")
                            .font(.label(13))
                            .foregroundStyle(Palette.mocha)
                    }
                    .padding(.top, 12)

                    SyllabusTodayCard()
                    SoundtrackCard()
                    plansGrid
                    MemorizeSection()
                    challengesSection
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 22)
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: $selectedPlan) { plan in PlanSheet(plan: plan) }
    }

    private var plansGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 16) {
            ForEach(ContentLibrary.plans) { plan in
                Button {
                    Haptics.tap()
                    if plan.premium && !store.isPremium {
                        showPaywall = true
                    } else {
                        selectedPlan = plan
                    }
                } label: {
                    PlanCard(plan: plan, locked: plan.premium && !store.isPremium)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Challenges with friends")
                .font(.display(20))
                .foregroundStyle(Palette.ink)
            ForEach(ContentLibrary.challenges, id: \.title) { c in
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Palette.linen).frame(width: 46, height: 46)
                        Image(systemName: "person.2")
                            .font(.system(size: 17))
                            .foregroundStyle(Palette.onLinenSoft)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(c.title)
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Text(c.subtitle)
                            .font(.label(12))
                            .foregroundStyle(Palette.mocha)
                    }
                    Spacer()
                    ShareLink(item: "Join me on \(c.title) in Selah — \(c.subtitle). Download: https://selah.app") {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Palette.bronze)
                    }
                }
                .padding(16)
                .glassCard(corner: 24)
            }
        }
    }
}

// MARK: - Arch plan card

struct PlanCard: View {
    let plan: ReadingPlan
    var locked: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ArchShape()
                    .fill(LinearGradient(
                        colors: plan.gradient.map { Color(hex: $0) },
                        startPoint: .top, endPoint: .bottom))
                    .frame(height: 190)
                    .overlay {
                        Image(systemName: plan.symbol)
                            .font(.system(size: 34, weight: .light))
                            .foregroundStyle(Palette.cream.opacity(0.9))
                    }
                    .shadow(color: Palette.espresso.opacity(0.12), radius: 14, y: 8)
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(8)
                        .background { Circle().fill(Palette.cream.opacity(0.9)) }
                        .padding(10)
                }
            }
            VStack(spacing: 4) {
                Text(plan.title)
                    .font(.display(16))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                Text("\(plan.days) days")
                    .font(.label(11, weight: .medium))
                    .foregroundStyle(Palette.taupe)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Plan detail

struct PlanSheet: View {
    let plan: ReadingPlan
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selah.planProgress") private var progressRaw: String = "{}"

    private var progress: Int {
        (try? JSONDecoder().decode([String: Int].self, from: Data(progressRaw.utf8)))?[plan.id] ?? 0
    }

    private func setProgress(_ value: Int) {
        var dict = (try? JSONDecoder().decode([String: Int].self, from: Data(progressRaw.utf8))) ?? [:]
        dict[plan.id] = value
        if let d = try? JSONEncoder().encode(dict), let s = String(data: d, encoding: .utf8) {
            progressRaw = s
        }
    }

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    HStack(spacing: 16) {
                        ArchShape()
                            .fill(LinearGradient(colors: plan.gradient.map { Color(hex: $0) },
                                                 startPoint: .top, endPoint: .bottom))
                            .frame(width: 84, height: 118)
                            .overlay {
                                Image(systemName: plan.symbol)
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundStyle(Palette.cream)
                            }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(plan.title)
                                .font(.display(26))
                                .foregroundStyle(Palette.ink)
                            Text(plan.subtitle)
                                .font(.label(13))
                                .foregroundStyle(Palette.mocha)
                            Text("Day \(min(progress + 1, plan.days)) of \(plan.days)")
                                .font(.label(12, weight: .semibold))
                                .foregroundStyle(Palette.bronze)
                        }
                    }

                    ProgressView(value: Double(progress), total: Double(plan.days))
                        .tint(Palette.bronze)
                        .scaleEffect(y: 1.6)

                    VStack(spacing: 10) {
                        ForEach(0..<plan.days, id: \.self) { day in
                            let verse = ContentLibrary.verses[(day * 7 + plan.id.count) % ContentLibrary.verses.count]
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(day < progress ? Palette.bronze : Palette.linen)
                                        .frame(width: 34, height: 34)
                                    if day < progress {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Palette.cream)
                                    } else {
                                        Text("\(day + 1)")
                                            .font(.label(13, weight: .semibold))
                                            .foregroundStyle(Palette.onLinenSoft)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(verse.reference)
                                        .font(.label(14, weight: .semibold))
                                        .foregroundStyle(Palette.ink)
                                    Text(verse.text)
                                        .font(.label(12))
                                        .foregroundStyle(Palette.mocha)
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .glassCard(corner: 20)
                            .opacity(day > progress ? 0.55 : 1)
                        }
                    }

                    Button {
                        Haptics.success()
                        setProgress(min(progress + 1, plan.days))
                    } label: {
                        Text(progress >= plan.days ? "Plan complete" : "Mark day \(progress + 1) done")
                    }
                    .buttonStyle(BronzeButtonStyle())
                    .disabled(progress >= plan.days)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}
