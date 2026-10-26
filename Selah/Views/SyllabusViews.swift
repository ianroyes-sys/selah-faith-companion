import SwiftUI

// MARK: - Syllabus views — "a devotional week written around your heart."

// MARK: Today card

struct SyllabusTodayCard: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var syllabus = SyllabusStore.shared
    @State private var showBuilder = false
    @State private var showPlan = false

    var body: some View {
        Group {
            if let plan = syllabus.current, !plan.complete {
                activeCard(plan)
            } else if let plan = syllabus.current, plan.complete {
                completeCard(plan)
            } else if store.todayMood != nil {
                builderInvite
            }
        }
        .sheet(isPresented: $showBuilder) { SyllabusBuilderSheet() }
        .sheet(isPresented: $showPlan) { SyllabusPlanSheet() }
    }

    private func activeCard(_ plan: Syllabus) -> some View {
        Button {
            Haptics.tap(); showPlan = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Palette.sand.opacity(0.4), lineWidth: 4)
                        .frame(width: 54, height: 54)
                    Circle()
                        .trim(from: 0, to: CGFloat(plan.doneCount) / CGFloat(max(plan.days.count, 1)))
                        .stroke(Palette.bronze, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 54, height: 54)
                    Text("\(plan.doneCount)/\(plan.days.count)")
                        .font(.label(12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your week: \(plan.title)".uppercased())
                        .font(.label(10, weight: .semibold))
                        .kerning(1.2)
                        .foregroundStyle(Palette.mocha)
                    if let day = plan.current {
                        Text("Day \(day.index) — \(day.title)")
                            .font(.display(18))
                            .foregroundStyle(Palette.ink)
                        Text(day.verse.reference)
                            .font(.label(12))
                            .foregroundStyle(Palette.taupe)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.mocha)
            }
            .padding(16)
            .glassCard(corner: 26)
        }
        .buttonStyle(.plain)
    }

    private func completeCard(_ plan: Syllabus) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Palette.bronze)
                Text("Week complete".uppercased())
                    .font(.label(10, weight: .semibold))
                    .kerning(1.2)
                    .foregroundStyle(Palette.mocha)
                Spacer()
            }
            Text("You finished “\(plan.title)” — all \(plan.days.count) days.")
                .font(.scripture(16))
                .foregroundStyle(Palette.ink)
            HStack(spacing: 10) {
                ShareLink(item: "I just finished “\(plan.title)” — \(plan.days.count) days of scripture built around how my week actually felt. Made with Selah: https://selah.app") {
                    Label("Share it", systemImage: "square.and.arrow.up")
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(Palette.onInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background { Capsule().fill(Palette.ink) }
                }
                Button {
                    Haptics.tap(); showBuilder = true
                } label: {
                    Text("Start a new week")
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(Palette.onLinen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background { Capsule().fill(Palette.linen) }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(corner: 26)
    }

    private var builderInvite: some View {
        Button {
            Haptics.tap(); showBuilder = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.bronze, Palette.mocha],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 19))
                        .foregroundStyle(Palette.cream)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your week, written for you")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text("A 7-day plan built around how your heart is today")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.bronze)
            }
            .padding(16)
            .glassCard(corner: 26)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Builder — mood in, week out.

struct SyllabusBuilderSheet: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var syllabus = SyllabusStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var mood: Mood = .hopeful
    @State private var focus: String?
    @State private var phase: Phase = .choosing
    @State private var appeared = false

    enum Phase { case choosing, composing, done }

    private var arc: SyllabusEngine.Arc? { SyllabusEngine.arcs[mood] }

    var body: some View {
        ZStack {
            DuskBackground()
            switch phase {
            case .choosing: choosing
            case .composing: composing
            case .done: SyllabusPlanContent(onClose: { dismiss() }).transition(.opacity)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .onAppear { if let m = store.todayMood { mood = m } }
    }

    private var choosing: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity).padding(.top, 14)
                Text("Let's write\nyour week")
                    .font(.display(34))
                    .foregroundStyle(Palette.cream)
                Text("Selah composes a 7-day devotional syllabus around where your heart actually is — verses, readings, and one small practice a day.")
                    .font(.label(14))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.sand)

                VStack(alignment: .leading, spacing: 10) {
                    Text("How's your heart?".uppercased())
                        .font(.label(10, weight: .semibold))
                        .kerning(1.4)
                        .foregroundStyle(Palette.bronze)
                    FlowMoodGrid(selected: $mood)
                }

                if let arc, !arc.focuses.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What's underneath it? (optional)".uppercased())
                            .font(.label(10, weight: .semibold))
                            .kerning(1.4)
                            .foregroundStyle(Palette.bronze)
                        HStack(spacing: 8) {
                            ForEach(arc.focuses, id: \.self) { f in
                                Button {
                                    Haptics.soft()
                                    withAnimation { focus = (focus == f) ? nil : f }
                                } label: {
                                    Text(f)
                                        .font(.label(12, weight: .medium))
                                        .foregroundStyle(focus == f ? Palette.espresso : Palette.sand)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 9)
                                        .background {
                                            Capsule().fill(focus == f ? Palette.cream : .white.opacity(0.08))
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Button {
                    compose()
                } label: {
                    Text("Write my week")
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 26)
        }
    }

    private var composing: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "wand.and.stars")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Palette.bronze)
                .symbolEffect(.pulse, isActive: true)
            Text("Composing your week…")
                .font(.display(24))
                .foregroundStyle(Palette.cream)
            VStack(spacing: 8) {
                composeLine("Reading how your week has felt", delay: 0)
                composeLine("Choosing seven passages", delay: 0.5)
                composeLine("Weaving in what you're praying about", delay: 1.0)
            }
            Spacer()
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private func composeLine(_ text: String, delay: Double) -> some View {
        Text(text)
            .font(.label(13))
            .foregroundStyle(Palette.sand)
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.4).delay(delay), value: appeared)
    }

    private func compose() {
        Haptics.success()
        withAnimation { phase = .composing }
        Task {
            syllabus.generate(mood: mood, focus: focus, store: store)
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { phase = .done }
        }
    }
}

/// Mood chips laid out in two rows for the dark builder surface.
struct FlowMoodGrid: View {
    @Binding var selected: Mood

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ForEach(Mood.allCases) { m in
                Button {
                    Haptics.soft()
                    withAnimation { selected = m }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: m.symbol)
                            .font(.system(size: 11, weight: .medium))
                        Text(m.title)
                            .font(.label(12, weight: selected == m ? .semibold : .medium))
                    }
                    .foregroundStyle(selected == m ? Palette.espresso : Palette.sand)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        Capsule().fill(selected == m ? Palette.cream : .white.opacity(0.08))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: Plan sheet

struct SyllabusPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            DuskBackground()
            SyllabusPlanContent(onClose: { dismiss() })
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}

struct SyllabusPlanContent: View {
    @ObservedObject private var syllabus = SyllabusStore.shared
    @State private var openDay: SyllabusDay?
    var onClose: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let plan = syllabus.current {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your syllabus".uppercased())
                            .font(.label(10, weight: .semibold))
                            .kerning(1.4)
                            .foregroundStyle(Palette.bronze)
                        Text(plan.title)
                            .font(.display(36))
                            .foregroundStyle(Palette.cream)
                        Text(plan.subtitle)
                            .font(.label(13))
                            .lineSpacing(3)
                            .foregroundStyle(Palette.sand)
                    }

                    ProgressView(value: Double(plan.doneCount), total: Double(plan.days.count))
                        .tint(Palette.bronze)
                        .scaleEffect(y: 1.6)

                    VStack(spacing: 10) {
                        ForEach(plan.days) { day in
                            SyllabusDayRow(day: day, isCurrent: plan.current?.index == day.index)
                                .onTapGesture {
                                    guard day.done || plan.current?.index == day.index else { return }
                                    Haptics.tap()
                                    openDay = day
                                }
                        }
                    }

                    HStack {
                        ShareLink(item: "My devotional week: “\(plan.title)” — \(plan.subtitle). Built in Selah: https://selah.app") {
                            Label("Share my week", systemImage: "square.and.arrow.up")
                                .font(.label(13, weight: .semibold))
                                .foregroundStyle(Palette.espresso)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background { Capsule().fill(Palette.cream) }
                        }
                        Spacer()
                        Button {
                            Haptics.tap()
                            syllabus.clear()
                            onClose()
                        } label: {
                            Text("Start over")
                                .font(.label(13, weight: .medium))
                                .foregroundStyle(Palette.sand)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 26)
            }
        }
        .sheet(item: $openDay) { day in SyllabusDaySheet(day: day) }
    }
}

struct SyllabusDayRow: View {
    let day: SyllabusDay
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(day.done ? Palette.bronze : .white.opacity(isCurrent ? 0.16 : 0.07))
                    .frame(width: 36, height: 36)
                if day.done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.cream)
                } else {
                    Text("\(day.index)")
                        .font(.label(13, weight: .semibold))
                        .foregroundStyle(isCurrent ? Palette.cream : Palette.sand)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(day.title)
                    .font(.label(14, weight: .semibold))
                    .foregroundStyle(Palette.cream.opacity(day.done || isCurrent ? 1 : 0.55))
                Text(day.verse.reference)
                    .font(.label(11))
                    .foregroundStyle(Palette.sand.opacity(day.done || isCurrent ? 0.9 : 0.5))
            }
            Spacer()
            if isCurrent {
                Text("Today")
                    .font(.label(10, weight: .semibold))
                    .foregroundStyle(Palette.espresso)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(Palette.bronze) }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(isCurrent ? 0.09 : 0.04))
        }
    }
}

// MARK: Day reader

struct SyllabusDaySheet: View {
    let day: SyllabusDay
    @ObservedObject private var syllabus = SyllabusStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    Text("Day \(day.index)".uppercased())
                        .font(.label(11, weight: .semibold))
                        .kerning(1.4)
                        .foregroundStyle(Palette.mocha)
                    Text(day.title)
                        .font(.display(32))
                        .foregroundStyle(Palette.ink)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("“\(day.verse.text)”")
                            .font(.scripture(18))
                            .lineSpacing(5)
                            .foregroundStyle(Palette.cream)
                        Text(day.verse.reference)
                            .font(.label(12, weight: .semibold))
                            .kerning(1)
                            .textCase(.uppercase)
                            .foregroundStyle(Palette.bronze)
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Palette.deepBrown)
                    }

                    if let devo = day.devotional {
                        Text(devo.body)
                            .font(.label(16))
                            .lineSpacing(7)
                            .foregroundStyle(Palette.ink.opacity(0.9))
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reflect".uppercased())
                                .font(.label(11, weight: .semibold))
                                .kerning(1.4)
                                .foregroundStyle(Palette.mocha)
                            Text(devo.reflection)
                                .font(.scripture(17))
                                .italic()
                                .lineSpacing(5)
                                .foregroundStyle(Palette.ink)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(corner: 24)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's practice".uppercased())
                            .font(.label(11, weight: .semibold))
                            .kerning(1.4)
                            .foregroundStyle(Palette.mocha)
                        Text(day.practice)
                            .font(.label(15))
                            .lineSpacing(6)
                            .foregroundStyle(Palette.ink.opacity(0.9))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .solidCard(corner: 24, fill: Palette.blush.opacity(0.6))

                    if !day.done {
                        Button {
                            Haptics.success()
                            LoopTracker.markWord()
                            syllabus.markDone(day)
                            dismiss()
                        } label: {
                            Text("Done — day \(day.index) sealed")
                        }
                        .buttonStyle(BronzeButtonStyle())
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}
