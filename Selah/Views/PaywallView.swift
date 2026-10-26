import SwiftUI
import StoreKit

// MARK: - Selah+ paywall — StoreKit 2.
// Products: selah.plus.monthly ($9.99) / selah.plus.yearly ($59.99), 14-day trial.
// Falls back to static pricing display until App Store Connect products load.

struct PaywallView: View {
    @EnvironmentObject var store: UserStore
    @ObservedObject private var storeKit = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var plan: Plan = .yearly
    @State private var errorMessage: String?

    enum Plan { case monthly, yearly }

    private let perks: [(String, String)] = [
        ("bubble.left.and.text.bubble.right.fill", "Unlimited companion — and it remembers your walk"),
        ("gift.fill", "Faith Wrapped — your month with God, ready to share"),
        ("shield.checkered", "Streak Shield — one missed day a week can't break you"),
        ("person.3.fill", "Unlimited circles for all your people"),
        ("bell.badge.fill", "Daily reminders for the prayers you're carrying"),
        ("sun.horizon.fill", "Morning Reset & Evening Wind-Down, every day"),
        ("book.fill", "Every reading plan + unlimited memory deck"),
        ("book.pages.fill", "Your testimony, written from your own season")
    ]

    var body: some View {
        ZStack {
            DuskBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5).padding(.top, 14)
                    Spacer().frame(height: 30)
                    Text("SELAH+")
                        .font(.display(15))
                        .kerning(5)
                        .foregroundStyle(Palette.bronze)
                    Spacer().frame(height: 14)
                    Text("Go deeper,\nevery single day")
                        .font(.display(36))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.cream)
                    Spacer().frame(height: 30)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(perks, id: \.1) { perk in
                            HStack(spacing: 14) {
                                Image(systemName: perk.0)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Palette.bronze)
                                    .frame(width: 26)
                                Text(perk.1)
                                    .font(.label(14, weight: .medium))
                                    .foregroundStyle(Palette.cream.opacity(0.92))
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.white.opacity(0.06))
                            .overlay {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                            }
                    }

                    Spacer().frame(height: 22)

                    HStack(spacing: 12) {
                        planCard(.yearly,
                                 price: storeKit.yearly?.displayPrice ?? "$59.99",
                                 period: "per year", badge: "Save 50%")
                        planCard(.monthly,
                                 price: storeKit.monthly?.displayPrice ?? "$9.99",
                                 period: "per month", badge: nil)
                    }

                    Spacer().frame(height: 22)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.label(12))
                            .foregroundStyle(Color(hex: 0xD98873))
                            .padding(.bottom, 10)
                    }

                    Button {
                        purchase()
                    } label: {
                        HStack(spacing: 8) {
                            if storeKit.purchasing { ProgressView().tint(Palette.espresso).scaleEffect(0.85) }
                            Text("Start 14-day free trial")
                                .font(.label(16, weight: .semibold))
                        }
                        .foregroundStyle(Palette.espresso)
                        .padding(.vertical, 17)
                        .frame(maxWidth: .infinity)
                        .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .disabled(storeKit.purchasing)

                    Spacer().frame(height: 14)
                    Text("Cancel anytime · Auto-renews after trial")
                        .font(.label(11))
                        .foregroundStyle(Palette.taupe)
                    HStack(spacing: 20) {
                        Button("Restore purchases") {
                            Haptics.tap()
                            Task {
                                await storeKit.restore(store: store)
                                if store.isPremium { dismiss() }
                            }
                        }
                        Button("Not now") { dismiss() }
                    }
                    .font(.label(13, weight: .medium))
                    .foregroundStyle(Palette.sand.opacity(0.7))
                    .padding(.top, 18)
                    HStack(spacing: 20) {
                        Link("Terms of Use", destination: Legal.termsURL)
                        Link("Privacy Policy", destination: Legal.privacyURL)
                    }
                    .font(.label(11))
                    .foregroundStyle(Palette.taupe.opacity(0.9))
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 26)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .task { await storeKit.loadProducts() }
    }

    private func purchase() {
        Haptics.tap()
        errorMessage = nil
        let product = plan == .yearly ? storeKit.yearly : storeKit.monthly

        guard let product else {
            #if DEBUG
            // No sandbox products configured — dev unlock so flows stay testable.
            store.isPremium = true
            Haptics.success()
            dismiss()
            #else
            errorMessage = "Subscriptions aren't available right now. Try again in a moment."
            #endif
            return
        }

        Task {
            do {
                if try await storeKit.purchase(product, store: store) {
                    Haptics.success()
                    dismiss()
                }
            } catch {
                errorMessage = "The purchase couldn't be completed."
            }
        }
    }

    private func planCard(_ p: Plan, price: String, period: String, badge: String?) -> some View {
        Button {
            Haptics.soft(); plan = p
        } label: {
            VStack(spacing: 6) {
                if let badge {
                    Text(badge)
                        .font(.label(10, weight: .bold))
                        .foregroundStyle(Palette.espresso)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background { Capsule().fill(Palette.bronze) }
                } else {
                    Spacer().frame(height: 22)
                }
                Text(price)
                    .font(.display(26))
                    .foregroundStyle(Palette.cream)
                Text(period)
                    .font(.label(12))
                    .foregroundStyle(Palette.sand)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(plan == p ? 0.12 : 0.05))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(plan == p ? Palette.bronze : .white.opacity(0.1),
                                          lineWidth: plan == p ? 1.5 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
