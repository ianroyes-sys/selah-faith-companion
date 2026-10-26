import SwiftUI

@main
struct SelahApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = UserStore()
    @AppStorage("selah.appearance") private var appearanceRaw = Appearance.dark.rawValue

    var body: some Scene {
        WindowGroup {
            Group {
                if store.onboarded {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .preferredColorScheme((Appearance(rawValue: appearanceRaw) ?? .system).colorScheme)
            .tint(Palette.bronze)
            .task {
                StoreManager.shared.start(store: store)
                await NotificationService.shared.refreshAuthorization()
                NotificationService.shared.rescheduleStreakGuard(streak: store.streak)
            }
        }
    }
}
