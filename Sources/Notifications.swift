import Foundation
import UserNotifications

enum Notifications {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(for task: ServiceTask, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Service due"
        content.body = task.title
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        requestAuthorization()
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(for task: ServiceTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
