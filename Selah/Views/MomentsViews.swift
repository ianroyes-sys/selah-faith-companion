import SwiftUI

// MARK: - Personalized office — a liturgy written about YOUR day, read quietly.
// Free: one Morning Reset per day. Selah+: unlimited + Evening Wind-Down.

struct AudioOfficeSheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var life: LifeContext
    @State private var script: String?
    @State private var generating = false
    @State private var showPaywall = false
    @AppStorage("selah.officeDay") private var officeDay = ""
    @AppStorage("selah.officeCount") private var officeCount = 0

    private var evening: Bool { Calendar.current.component(.hour, from: Date()) >= 17 }

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(spacing: 0) {
                Capsule().fill(Palette.mocha).frame(width: 40, height: 5).padding(.top, 14)
                Spacer()
                Image(systemName: evening ? "moon.stars" : "sunrise")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Palette.bronze)
                Spacer().frame(height: 18)
                Text(evening ? "Evening Wind-Down" : "Morning Reset")
                    .font(.display(30))
                    .foregroundStyle(Palette.cream)
                Spacer().frame(height: 8)
                Text("A prayer written over your actual day —\nyour name, your heart, your calendar.")
                    .font(.label(13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.sand)
                    .lineSpacing(3)

                Spacer().frame(height: 30)

                if let script {
                    ScrollView(showsIndicators: false) {
                        Text(script.replacingOccurrences(of: " ... ", with: "\n\n"))
                            .font(.scripture(17))
                            .lineSpacing(6)
                            .foregroundStyle(Palette.cream.opacity(0.95))
                            .padding(22)
                    }
                    .frame(maxHeight: 320)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(.white.opacity(0.07))
                    }
                    .padding(.horizontal, 26)
                }

                Spacer()

                Button {
                    script == nil ? begin() : dismiss()
                } label: {
                    HStack(spacing: 10) {
                        if generating {
                            ProgressView().tint(Palette.espresso).scaleEffect(0.85)
                        }
                        Text(generating ? "Preparing…" : (script == nil ? "Begin" : "Amen"))
                            .font(.label(16, weight: .semibold))
                    }
                    .foregroundStyle(Palette.espresso)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background { Capsule().fill(Palette.cream) }
                }
                .buttonStyle(.plain)
                .disabled(generating)
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func begin() {
        // Free tier: one office per day; evening office is Selah+.
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        if officeDay != today { officeDay = today; officeCount = 0 }
        if !store.isPremium && (officeCount >= 1 || evening) {
            showPaywall = true
            return
        }

        Haptics.tap()
        generating = true
        officeCount += 1
        life.refresh()
        Task {
            let s = await IntelligenceEngine.officeScript(
                name: store.name,
                mood: store.todayMood,
                verse: ContentLibrary.verseOfToday,
                openPrayer: store.openPrayers.first,
                calendarLine: life.todaySummary,
                evening: evening
            )
            generating = false
            withAnimation { script = s }
        }
    }
}

// MARK: - Send a Blessing — a 20-second spoken prayer for a friend, via iMessage.

struct BlessingSheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = BlessingRecorder()

    var body: some View {
        ZStack {
            SelahBackground()
            VStack(spacing: 0) {
                Capsule().fill(Palette.sand).frame(width: 40, height: 5).padding(.top, 14)
                Spacer()
                Text("Send a blessing")
                    .font(.display(28))
                    .foregroundStyle(Palette.ink)
                Spacer().frame(height: 8)
                Text("Record a short prayer for someone.\nThey don't need the app to hear it.")
                    .font(.label(13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.mocha)
                    .lineSpacing(3)

                Spacer().frame(height: 44)

                ZStack {
                    Circle()
                        .stroke(Palette.sand.opacity(0.6), lineWidth: 3)
                        .frame(width: 150, height: 150)
                    Circle()
                        .trim(from: 0, to: recorder.seconds / BlessingRecorder.maxSeconds)
                        .stroke(Palette.bronze, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    Button {
                        Haptics.tap()
                        recorder.recording ? recorder.stop() : recorder.start()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(recorder.recording ? Color(hex: 0x9C4A38) : Palette.ink)
                                .frame(width: 110, height: 110)
                            Image(systemName: recorder.recording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Palette.onInk)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer().frame(height: 16)
                Text(recorder.recording
                     ? String(format: "%.0f seconds", recorder.seconds)
                     : recorder.fileURL != nil ? "Blessing recorded" : "Tap to record")
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Palette.mocha)

                Spacer()

                if let url = recorder.fileURL {
                    VStack(spacing: 10) {
                        ShareLink(
                            item: url,
                            message: Text("I prayed this over you just now (recorded in Selah — https://selah.app)")
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Send it")
                            }
                            .font(.label(16, weight: .semibold))
                            .foregroundStyle(Palette.onInk)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.ink) }
                        }
                        .simultaneousGesture(TapGesture().onEnded { Haptics.success() })
                        Button("Re-record") { recorder.discard() }
                            .font(.label(13, weight: .medium))
                            .foregroundStyle(Palette.mocha)
                    }
                    .padding(.horizontal, 28)
                }
                Spacer().frame(height: 40)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .onDisappear { if recorder.recording { recorder.stop() } }
    }
}

// MARK: - Your Story — AI-written testimony from your own walk. Selah+.

struct StorySheet: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var story: String?
    @State private var generating = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            DuskBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    Text("Your story,\nso far")
                        .font(.display(32))
                        .foregroundStyle(Palette.cream)
                    Text("Selah reads back through your journal and answered prayers and writes the testimony of this season — in your voice, ready to share.")
                        .font(.label(14))
                        .lineSpacing(4)
                        .foregroundStyle(Palette.sand)

                    HStack(spacing: 12) {
                        storyStat("\(store.journal.count)", "entries")
                        storyStat("\(store.answeredPrayers.count)", "answered")
                        storyStat("\(store.bestStreak)", "best streak")
                    }

                    if let story {
                        Text(story)
                            .font(.scripture(18))
                            .lineSpacing(7)
                            .foregroundStyle(Palette.cream)
                            .padding(22)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(.white.opacity(0.07))
                            }
                        ShareLink(item: story + "\n\n— written with Selah") {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share your testimony")
                            }
                            .font(.label(15, weight: .semibold))
                            .foregroundStyle(Palette.espresso)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.cream) }
                        }
                    } else {
                        Button {
                            generate()
                        } label: {
                            HStack(spacing: 8) {
                                if generating { ProgressView().tint(Palette.espresso).scaleEffect(0.85) }
                                Text(generating ? "Writing your story…" : "Write my testimony")
                                    .font(.label(16, weight: .semibold))
                            }
                            .foregroundStyle(Palette.espresso)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.cream) }
                        }
                        .buttonStyle(.plain)
                        .disabled(generating)
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 26)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func storyStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.display(22))
                .foregroundStyle(Palette.cream)
            Text(label)
                .font(.label(11))
                .foregroundStyle(Palette.taupe)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }

    private func generate() {
        guard store.isPremium else { showPaywall = true; return }
        Haptics.tap()
        generating = true
        Task {
            let s = await IntelligenceEngine.generateTestimony(
                name: store.name,
                entries: store.journal,
                answered: store.answeredPrayers,
                streak: store.bestStreak
            )
            generating = false
            withAnimation { story = s }
        }
    }
}
