import UserNotifications

enum NotificationService {

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// 아침 8시, 점심 12:30, 저녁 7시 먹이 지급 알림
    static func scheduleFeedNotifications() {
        let center = UNUserNotificationCenter.current()

        // 기존 알림 모두 제거 후 재등록
        center.removePendingNotificationRequests(withIdentifiers: [
            "feed_breakfast", "feed_lunch", "feed_dinner"
        ])

        let meals: [(id: String, hour: Int, minute: Int, title: String)] = [
            ("feed_breakfast", 8,  0,  "🐹 아침밥이 도착했어요!"),
            ("feed_lunch",     12, 30, "🐹 점심밥이 도착했어요!"),
            ("feed_dinner",    19, 0,  "🐹 저녁밥이 도착했어요!"),
        ]

        for meal in meals {
            let content = UNMutableNotificationContent()
            content.title = meal.title
            content.body = "햄피와 놀아볼까요?"
            content.sound = .default

            var dateComp = DateComponents()
            dateComp.hour = meal.hour
            dateComp.minute = meal.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: true)
            let request = UNNotificationRequest(identifier: meal.id, content: content, trigger: trigger)

            center.add(request)
        }
    }
}
