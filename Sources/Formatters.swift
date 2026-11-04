import Foundation

enum Fmt {
    static func money(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    static func liters(_ value: Double) -> String {
        String(format: "%.2f L", value)
    }

    static func consumption(_ value: Double?) -> String {
        guard let value, value.isFinite else { return "—" }
        return String(format: "%.1f L/100km", value)
    }

    static func distance(_ value: Double) -> String {
        String(format: "%.0f km", value)
    }

    static func odometer(_ value: Double) -> String {
        String(format: "%.0f km", value)
    }

    static func day(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    static func month(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
