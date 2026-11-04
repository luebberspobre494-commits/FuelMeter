import SwiftUI
import SwiftData

@main
struct FuelMeterApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Vehicle.self, FillUp.self, ServiceTask.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
