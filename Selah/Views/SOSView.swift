import SwiftUI

// MARK: - Temptation SOS — a 60-second intervention.
// Breath pacing + scripture + one-tap text to your anchor. Always free.

struct SOSView: View {
    @EnvironmentObject var store: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var breatheIn = false
    @State private var secondsLeft = 60
    @State private var timer: Timer?

    private let verse = ContentLibrary.verses.first { $0.reference == "1 Corinthians 10:13" }
        ?? ContentLibrary.verseOfToday

    var body: some View {
        ZStack {
            DuskBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        close()
                    } label: {
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

                Text("You're not alone in this moment.")
                    .font(.display(24))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.cream)
                    .padding(.horizontal, 40)

                Spacer().frame(height: 40)

                // Breathing circle — 4s in, 4s out.
                ZStack {
                    Circle()
                        .fill(Palette.bronze.opacity(0.15))
                        .frame(width: 220, height: 220)
                    Circle()
                        .fill(Palette.bronze.opacity(0.25))
                        .frame(width: 160, height: 160)
                        .scaleEffect(breatheIn ? 1.35 : 0.85)
                    Circle()
                        .fill(LinearGradient(colors: [Palette.bronze, Palette.mocha],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 110, height: 110)
                        .scaleEffect(breatheIn ? 1.3 : 0.8)
                    Text(breatheIn ? "Breathe in" : "Breathe out")
                        .font(.label(14, weight: .semibold))
                        .foregroundStyle(Palette.cream)
                }
                .animation(.easeInOut(duration: 4), value: breatheIn)

                Spacer().frame(height: 40)

                VStack(spacing: 10) {
                    Text("“\(verse.text)”")
                        .font(.scripture(16))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .foregroundStyle(Palette.sand)
                        .padding(.horizontal, 36)
                    Text(verse.reference.uppercased())
                        .font(.label(11, weight: .semibold))
                        .kerning(1.5)
                        .foregroundStyle(Palette.bronze)
                }

                Spacer()

                VStack(spacing: 12) {
                    ShareLink(item: "Hey — pray for me right now? I'm in a moment. (Sent from Selah)") {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                            Text("Text my anchor")
                        }
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                    }
                    Button {
                        Haptics.success()
                        close()
                    } label: {
                        Text(secondsLeft > 0 ? "I'm steady now (\(secondsLeft)s)" : "I'm steady now")
                            .font(.label(14, weight: .medium))
                            .foregroundStyle(Palette.sand)
                            .padding(.vertical, 13)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(.white.opacity(0.1)) }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .onAppear { start() }
        .onDisappear { stopTimer() }
    }

    private func start() {
        breatheIn = true
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            Task { @MainActor in
                breatheIn.toggle()
                secondsLeft = max(0, secondsLeft - 4)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func close() {
        stopTimer()
        dismiss()
    }
}
