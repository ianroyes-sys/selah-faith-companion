import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: UserStore
    @State private var showPaywall = false
    @State private var showStory = false
    @State private var showWrapped = false
    @State private var showPrivacy = false
    @AppStorage("selah.reminderHour") private var reminderHour = -1
    @AppStorage("selah.appearance") private var appearanceRaw = Appearance.dark.rawValue
    @AppStorage("selah.communityPrayed") private var communityPrayed = 0

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    statsRow
                    if !store.isPremium { premiumBanner }
                    faithWrappedCard
                    wrappedCard
                    inviteCard
                    settingsList
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showStory) { StorySheet() }
        .sheet(isPresented: $showWrapped) { WrappedSheet() }
        .sheet(isPresented: $showPrivacy) { PrivacyPromiseSheet() }
    }

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Palette.sand, Palette.taupe],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 84, height: 84)
                Text(String(store.name.prefix(1)).uppercased())
                    .font(.display(34))
                    .foregroundStyle(Palette.cream)
            }
            Text(store.name.isEmpty ? "Friend" : store.name)
                .font(.display(26))
                .foregroundStyle(Palette.ink)
            if store.isPremium {
                Text("SELAH+")
                    .font(.label(10, weight: .bold))
                    .kerning(2)
                    .foregroundStyle(Palette.cream)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(Palette.bronze) }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            stat(value: "\(store.streak)", label: "Day streak", icon: "flame.fill")
            stat(value: "\(communityPrayed)", label: "Prayers", icon: "hands.and.sparkles.fill")
            stat(value: "\(store.versesRead)", label: "Verses", icon: "book.fill")
        }
    }

    private func stat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Palette.bronze)
            Text(value)
                .font(.display(24))
                .foregroundStyle(Palette.ink)
            Text(label)
                .font(.label(11))
                .foregroundStyle(Palette.mocha)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassCard(corner: 24)
    }

    private var premiumBanner: some View {
        Button {
            Haptics.tap(); showPaywall = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundStyle(Palette.bronze)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upgrade to Selah+")
                        .font(.label(16, weight: .semibold))
                        .foregroundStyle(Palette.cream)
                    Text("Faith Wrapped, Streak Shield, unlimited circles & more")
                        .font(.label(12))
                        .foregroundStyle(Palette.sand)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.sand)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.deepBrown, Palette.nightBrown],
                                         startPoint: .leading, endPoint: .trailing))
            }
        }
        .buttonStyle(.plain)
    }

    private var faithWrappedCard: some View {
        Button {
            Haptics.tap(); showWrapped = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "gift")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.bronze)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Faith Wrapped")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text("Your month with God — stats, moods, and a share card")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.taupe)
            }
            .padding(18)
            .glassCard(corner: 24)
        }
        .buttonStyle(.plain)
    }

    private var wrappedCard: some View {
        Button {
            Haptics.tap(); showStory = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "book.pages")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.bronze)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your story, so far")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text("Selah writes your testimony from this season — ready to share")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.taupe)
            }
            .padding(18)
            .solidCard(corner: 24, fill: Palette.blush.opacity(0.55))
        }
        .buttonStyle(.plain)
    }

    private var inviteCard: some View {
        ShareLink(item: "I've been using Selah — a quiet, beautiful faith companion app. Join me: https://selah.app") {
            HStack(spacing: 14) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.bronze)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Invite a friend")
                        .font(.label(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text("Faith grows better together")
                        .font(.label(12))
                        .foregroundStyle(Palette.mocha)
                }
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Palette.mocha)
            }
            .padding(18)
            .glassCard(corner: 24)
        }
    }

    private var settingsList: some View {
        VStack(spacing: 2) {
            Button {
                Haptics.soft()
                cycleReminder()
            } label: {
                row(icon: "bell", label: "Daily reminder",
                    detail: reminderHour < 0 ? "Off" : (reminderHour < 12 ? "\(reminderHour):00 AM" : "\(reminderHour - 12):00 PM"))
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 52)
            Button {
                Haptics.soft()
                let all = Appearance.allCases
                let current = Appearance(rawValue: appearanceRaw) ?? .system
                let next = all[(all.firstIndex(of: current)! + 1) % all.count]
                appearanceRaw = next.rawValue
            } label: {
                row(icon: "circle.lefthalf.filled", label: "Appearance",
                    detail: (Appearance(rawValue: appearanceRaw) ?? .system).title)
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 52)
            Button {
                Haptics.soft(); showPrivacy = true
            } label: {
                row(icon: "lock.shield", label: "Privacy & Safety", detail: "Never sold")
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 52)
            Link(destination: Legal.termsURL) {
                row(icon: "doc.text", label: "Terms of Use", detail: "")
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 52)
            Link(destination: Legal.feedbackURL) {
                row(icon: "envelope", label: "Feedback", detail: "")
            }
            .buttonStyle(.plain)
            #if DEBUG
            Divider().padding(.leading, 52)
            Button {
                store.isPremium.toggle(); Haptics.success()
            } label: {
                row(icon: "wand.and.stars", label: "Toggle Selah+ (dev)", detail: store.isPremium ? "On" : "Off")
            }
            .buttonStyle(.plain)
            #endif
        }
        .padding(.vertical, 8)
        .glassCard(corner: 26)
    }

    private func cycleReminder() {
        switch reminderHour {
        case ..<0: reminderHour = 8
        case 8: reminderHour = 21
        default: reminderHour = -1
        }
        let hour = reminderHour
        Task {
            if hour >= 0 {
                let ok = await NotificationService.shared.requestAuthorization()
                if ok { NotificationService.shared.scheduleDailyReminder(hour: hour) }
            } else {
                NotificationService.shared.scheduleDailyReminder(hour: -1)
            }
        }
    }

    private func row(icon: String, label: String, detail: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Palette.mocha)
                .frame(width: 24)
            Text(label)
                .font(.label(15))
                .foregroundStyle(Palette.ink)
            Spacer()
            Text(detail)
                .font(.label(13))
                .foregroundStyle(Palette.taupe)
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Palette.taupe)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
    }
}
