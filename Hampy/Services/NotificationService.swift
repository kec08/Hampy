import UserNotifications

enum NotificationService {

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// 1시간마다 먹이 지급 알림
    static func scheduleFeedRefillNotification() {
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == "feed_refill" }
            guard !exists else { return }

            let content = UNMutableNotificationContent()
            content.title = "🐹 간식이 지급되었습니다!"
            content.body = "햄피와 놀아볼까요?"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
            let request = UNNotificationRequest(identifier: "feed_refill", content: content, trigger: trigger)

            center.add(request)
        }
    }
}
