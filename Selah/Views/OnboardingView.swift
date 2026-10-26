import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: UserStore
    @State private var page = 0
    @State private var name = ""
    @State private var mood: Mood?

    var body: some View {
        ZStack {
            if page <= 1 { DuskBackground() } else { SelahBackground() }

            VStack(spacing: 0) {
                switch page {
                case 0: welcome
                case 1: promisePage
                case 2: namePage
                default: moodPage
                }
            }
            .padding(.horizontal, 28)
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: page)
        }
    }

    // MARK: Page 1 — editorial hero
    private var welcome: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Selah")
                .font(.display(20))
                .kerning(6)
                .textCase(.uppercase)
                .foregroundStyle(Palette.sand)
            Spacer().frame(height: 28)
            Text("Faith,\nat your pace")
                .font(.display(46))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.cream)
            Spacer().frame(height: 20)
            Text("A quiet space to pray, reflect, and grow —\nbuilt for your generation.")
                .font(.label(15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.sand.opacity(0.9))
                .lineSpacing(4)
            Spacer()
            Button {
                Haptics.tap(); page = 1
            } label: {
                Text("Begin")
                    .font(.label(16, weight: .semibold))
                    .foregroundStyle(Palette.espresso)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background { Capsule().fill(Palette.cream) }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
            Text("Private · On-device · No account needed")
                .font(.label(12))
                .foregroundStyle(Palette.taupe)
                .padding(.bottom, 36)
        }
    }

    // MARK: Page 2 — the privacy promise, before they write a single word
    private var promisePage: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Palette.bronze.opacity(0.14))
                    .frame(width: 88, height: 88)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Palette.bronze)
            }
            Spacer().frame(height: 26)
            Text("This space is sacred.\nWe keep it that way.")
                .font(.display(32))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.cream)
            Spacer().frame(height: 28)
            VStack(alignment: .leading, spacing: 16) {
                promiseRow("iphone", "Your journal, prayers, and conversations stay on this phone — never uploaded.")
                promiseRow("cpu", "The AI thinks on your device. No server ever reads what you share.")
                promiseRow("person.fill.questionmark", "No account, no email — in community you're anonymous, even to us.")
                promiseRow("hand.raised.fill", "Your data is never sold, never shared, never used for ads. Ever.")
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(.white.opacity(0.09), lineWidth: 1)
                    }
            }
            Spacer()
            Button {
                Haptics.tap(); page = 2
            } label: {
                Text("That's how it should be")
                    .font(.label(16, weight: .semibold))
                    .foregroundStyle(Palette.espresso)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background { Capsule().fill(Palette.cream) }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 48)
        }
    }

    private func promiseRow(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Palette.bronze)
                .frame(width: 24)
                .padding(.top, 1)
            Text(text)
                .font(.label(13.5, weight: .medium))
                .lineSpacing(3)
                .foregroundStyle(Palette.cream.opacity(0.92))
        }
    }

    // MARK: Page 3 — name
    private var namePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 90)
            Text("What should\nwe call you?")
                .font(.display(38))
                .foregroundStyle(Palette.ink)
            Spacer().frame(height: 12)
            Text("First name is perfect. It stays on your phone.")
                .font(.label(14))
                .foregroundStyle(Palette.mocha)
            Spacer().frame(height: 36)
            TextField("Your name", text: $name)
                .font(.scripture(24))
                .padding(20)
                .glassCard(corner: 22)
                .autocorrectionDisabled()
            Spacer()
            Button {
                Haptics.tap()
                store.name = name.trimmingCharacters(in: .whitespaces)
                page = 3
            } label: {
                Text("Continue")
            }
            .buttonStyle(BronzeButtonStyle())
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            .padding(.bottom, 48)
        }
    }

    // MARK: Page 3 — first mood check-in
    private var moodPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 90)
            Text("How's your\nheart today?")
                .font(.display(38))
                .foregroundStyle(Palette.ink)
            Spacer().frame(height: 12)
            Text("Selah meets you where you actually are.")
                .font(.label(14))
                .foregroundStyle(Palette.mocha)
            Spacer().frame(height: 30)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Mood.allCases) { m in
                    Button {
                        Haptics.soft(); mood = m
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: m.symbol)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(mood == m ? Palette.onInk : Palette.onLinenSoft)
                                .frame(width: 24)
                            Text(m.title)
                                .font(.label(15, weight: .medium))
                                .foregroundStyle(mood == m ? Palette.onInk : Palette.onLinen)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(mood == m ? Palette.ink : Palette.linen)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Button {
                Haptics.success()
                store.todayMood = mood
                store.onboarded = true
            } label: {
                Text("Enter Selah")
            }
            .buttonStyle(BronzeButtonStyle())
            .disabled(mood == nil)
            .opacity(mood == nil ? 0.4 : 1)
            .padding(.bottom, 48)
        }
    }
}
