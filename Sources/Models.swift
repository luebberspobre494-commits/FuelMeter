import Foundation
import SwiftData

@Model
final class Vehicle {
    var id: UUID
    var name: String
    var plate: String
    var createdAt: Date

    init(name: String, plate: String = "") {
        self.id = UUID()
        self.name = name
        self.plate = plate
        self.createdAt = Date()
    }
}

@Model
final class FillUp {
    var id: UUID
    var vehicleID: UUID
    var date: Date
    var odometer: Double
    var volume: Double
    var pricePerLiter: Double
    var isFull: Bool
    var note: String

    var total: Double {
        volume * pricePerLiter
    }

    init(vehicleID: UUID, date: Date = Date(), odometer: Double, volume: Double, pricePerLiter: Double, isFull: Bool = true, note: String = "") {
        self.id = UUID()
        self.vehicleID = vehicleID
        self.date = date
        self.odometer = odometer
        self.volume = volume
        self.pricePerLiter = pricePerLiter
        self.isFull = isFull
        self.note = note
    }
}

@Model
final class ServiceTask {
    var id: UUID
    var vehicleID: UUID
    var title: String
    var dueDate: Date?
    var dueOdometer: Double?
    var isDone: Bool
    var notes: String

    init(vehicleID: UUID, title: String, dueDate: Date? = nil, dueOdometer: Double? = nil, notes: String = "") {
        self.id = UUID()
        self.vehicleID = vehicleID
        self.title = title
        self.dueDate = dueDate
        self.dueOdometer = dueOdometer
        self.isDone = false
        self.notes = notes
    }
}
