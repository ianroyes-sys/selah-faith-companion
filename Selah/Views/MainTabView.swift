import SwiftUI

enum Tab: String, CaseIterable {
    case today, chat, pray, grow, you

    var icon: String {
        switch self {
        case .today: "sun.max"
        case .chat: "bubble.left.and.text.bubble.right"
        case .pray: "hands.and.sparkles"
        case .grow: "book"
        case .you: "person"
        }
    }
    var title: String {
        switch self {
        case .today: "Today"
        case .chat: "Companion"
        case .pray: "Pray"
        case .grow: "Grow"
        case .you: "You"
        }
    }
}

struct MainTabView: View {
    @State private var tab: Tab = {
        #if DEBUG
        if let t = Tab(rawValue: UserDefaults.standard.string(forKey: "selah.debugTab") ?? "") { return t }
        #endif
        return .today
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .today: TodayView()
                case .chat: CompanionView()
                case .pray: PrayView()
                case .grow: GrowView()
                case .you: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // Floating pill navigation, echoing the reference designs.
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { t in
                Button {
                    Haptics.soft()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { tab = t }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: t.icon)
                            .font(.system(size: 18, weight: .medium))
                            .symbolVariant(tab == t ? .fill : .none)
                        Text(t.title)
                            .font(.label(10, weight: tab == t ? .semibold : .regular))
                    }
                    .foregroundStyle(tab == t ? Palette.cream : Palette.cream.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .background {
            Capsule()
                .fill(Palette.tabBar.opacity(0.92))
                .background(.ultraThinMaterial, in: Capsule())
                .overlay { Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1) }
                .shadow(color: Palette.espresso.opacity(0.35), radius: 20, y: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}
