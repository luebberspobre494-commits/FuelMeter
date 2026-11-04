import Foundation

struct ConsumptionPoint: Identifiable {
    let id = UUID()
    let date: Date
    let litersPer100km: Double
}

struct MonthSpend: Identifiable {
    let id = UUID()
    let monthStart: Date
    let amount: Double
}

enum Stats {
    /// Liters per 100 km between consecutive full fill-ups.
    static func consumptionPoints(_ fillUps: [FillUp]) -> [ConsumptionPoint] {
        let sorted = fillUps.sorted { $0.date < $1.date }
        var points: [ConsumptionPoint] = []
        var previous: FillUp?

        for current in sorted {
            guard current.isFull else { continue }
            if let last = previous {
                let distance = current.odometer - last.odometer
                if distance > 0 && current.volume > 0 {
                    let value = current.volume / distance * 100.0
                    points.append(ConsumptionPoint(date: current.date, litersPer100km: value))
                }
            }
            previous = current
        }
        return points
    }

    static func averageConsumption(_ fillUps: [FillUp]) -> Double? {
        let points = consumptionPoints(fillUps)
        guard !points.isEmpty else { return nil }
        return points.map(\.litersPer100km).reduce(0, +) / Double(points.count)
    }

    static func totalSpend(_ fillUps: [FillUp], since date: Date? = nil) -> Double {
        fillUps
            .filter { fillUp in
                guard let date else { return true }
                return fillUp.date >= date
            }
            .map(\.total)
            .reduce(0, +)
    }

    static func distanceCovered(_ fillUps: [FillUp]) -> Double {
        let sorted = fillUps.sorted { $0.odometer < $1.odometer }
        guard let first = sorted.first, let last = sorted.last, sorted.count > 1 else { return 0 }
        return max(0, last.odometer - first.odometer)
    }

    static func costPerKilometer(_ fillUps: [FillUp]) -> Double? {
        let distance = distanceCovered(fillUps)
        guard distance > 0 else { return nil }
        return totalSpend(fillUps) / distance
    }

    static func monthlySpend(_ fillUps: [FillUp], months: Int = 6, calendar: Calendar = .current, now: Date = Date()) -> [MonthSpend] {
        guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }
        var result: [MonthSpend] = []
        for offset in stride(from: months - 1, through: 0, by: -1) {
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart),
                  let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }
            let amount = fillUps
                .filter { $0.date >= monthStart && $0.date < nextMonth }
                .map(\.total)
                .reduce(0, +)
            result.append(MonthSpend(monthStart: monthStart, amount: amount))
        }
        return result
    }

    static func monthSpend(_ fillUps: [FillUp], calendar: Calendar = .current, now: Date = Date()) -> Double {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return 0 }
        return totalSpend(fillUps, since: start)
    }
}
