import XCTest
@testable import FuelMeter

final class FuelMeterTests: XCTestCase {
    private let carID = UUID()

    private func fillUp(daysAgo: Double, odometer: Double, volume: Double, price: Double = 1.8, full: Bool = true) -> FillUp {
        FillUp(
            vehicleID: carID,
            date: Date().addingTimeInterval(-daysAgo * 86_400),
            odometer: odometer,
            volume: volume,
            pricePerLiter: price,
            isFull: full
        )
    }

    func testConsumptionBetweenFullFillUps() {
        let first = fillUp(daysAgo: 20, odometer: 1_000, volume: 40)
        let second = fillUp(daysAgo: 10, odometer: 1_500, volume: 25)
        let points = Stats.consumptionPoints([first, second])

        XCTAssertEqual(points.count, 1)
        XCTAssertEqual(points[0].litersPer100km, 5.0, accuracy: 0.001)
    }

    func testPartialFillUpsAreIgnoredForConsumption() {
        let first = fillUp(daysAgo: 20, odometer: 1_000, volume: 40)
        let partial = fillUp(daysAgo: 15, odometer: 1_200, volume: 10, full: false)
        let second = fillUp(daysAgo: 10, odometer: 1_500, volume: 25)

        let points = Stats.consumptionPoints([first, partial, second])
        XCTAssertEqual(points.count, 1)
        XCTAssertEqual(points[0].litersPer100km, 5.0, accuracy: 0.001)
    }

    func testDistanceCoveredUsesOdometerExtremes() {
        let a = fillUp(daysAgo: 30, odometer: 800, volume: 30)
        let b = fillUp(daysAgo: 20, odometer: 1_200, volume: 30)
        let c = fillUp(daysAgo: 10, odometer: 1_000, volume: 30)

        XCTAssertEqual(Stats.distanceCovered([a, b, c]), 400, accuracy: 0.001)
    }

    func testCostPerKilometer() {
        let a = fillUp(daysAgo: 10, odometer: 0, volume: 50, price: 2.0)
        let b = fillUp(daysAgo: 1, odometer: 500, volume: 50, price: 2.0)

        let value = Stats.costPerKilometer([a, b])
        XCTAssertNotNil(value)
        XCTAssertEqual(value ?? 0, 0.4, accuracy: 0.001)
    }

    func testMonthlySpendGroupsByMonth() {
        let now = Date()
        let thisMonth = FillUp(vehicleID: carID, date: now, odometer: 100, volume: 10, pricePerLiter: 2.0)
        let points = Stats.monthlySpend([thisMonth], months: 6, now: now)

        XCTAssertEqual(points.count, 6)
        XCTAssertEqual(points.last?.amount ?? 0, 20.0, accuracy: 0.001)
    }
}
