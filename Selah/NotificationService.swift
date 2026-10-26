import Foundation
import UserNotifications
import UIKit

// MARK: - Notifications — local reminders + APNs registration.
// Local: daily reminder, streak guard, per-prayer reminders (Selah+).
// Remote: device token goes to the community backend; the server pushes
// "someone prayed for you", circle blessings, and relay updates.

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    @Published var authorized = false

    private let center = UNUserNotificationCenter.current()

    func refreshAuthorization() async {
        let settings = await center.notificationSettings()
        authorized = settings.authorizationStatus == .authorized
        if authorized { UIApplication.shared.registerForRemoteNotifications() }
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        authorized = granted
        if granted { UIApplication.shared.registerForRemoteNotifications() }
        return granted
    }

    // MARK: Daily reminder ("Your Morning Reset is ready")

    func scheduleDailyReminder(hour: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["selah.daily"])
        guard hour >= 0 else { return }
        let content = UNMutableNotificationContent()
        if hour < 12 {
            content.title = "Your Morning Reset is ready"
            content.body = "A verse and a prayer written over your actual day. One quiet minute."
        } else {
            content.title = "Evening Wind-Down"
            content.body = "Put the day down before you put your head down."
        }
        content.sound = .default
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: "selah.daily", content: content, trigger: trigger))
    }

    // MARK: Streak guard — fires tomorrow evening unless the app is opened
    // (each open cancels and reschedules for the following day).

    func rescheduleStreakGuard(streak: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["selah.streak"])
        guard streak >= 2 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Your \(streak)-day streak ends tonight"
        content.body = "One quiet minute keeps it alive. Come home."
        content.sound = .default
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        comps.hour = 20
        comps.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: "selah.streak", content: content, trigger: trigger))
    }

    // MARK: Per-prayer reminders (Selah+) — daily nudge for a vault prayer.

    private func prayerID(_ prayer: PersonalPrayer) -> String { "selah.prayer.\(prayer.id.uuidString)" }

    func schedulePrayerReminder(_ prayer: PersonalPrayer) {
        let content = UNMutableNotificationContent()
        content.title = "Still asking"
        content.body = "You're praying about: \(prayer.text.prefix(90))"
        content.sound = .default
        var comps = DateComponents()
        comps.hour = 9
        comps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: prayerID(prayer), content: content, trigger: trigger))
    }

    func cancelPrayerReminder(_ prayer: PersonalPrayer) {
        center.removePendingNotificationRequests(withIdentifiers: [prayerID(prayer)])
    }
}

// MARK: - APNs token capture

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task { _ = try? await CommunityAPI.call("register_push", ["token": token]) }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Simulator or missing capability — remote pushes simply stay off.
    }
}
