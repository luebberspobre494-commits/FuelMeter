import SwiftUI
import SwiftData

struct RootView: View {
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @State private var selectedVehicleID: UUID?
    @State private var showAddVehicle = false

    private var currentVehicle: Vehicle? {
        if let selectedVehicleID, let match = vehicles.first(where: { $0.id == selectedVehicleID }) {
            return match
        }
        return vehicles.first
    }

    var body: some View {
        Group {
            if let vehicle = currentVehicle {
                MainTabView(vehicle: vehicle, vehicles: vehicles) { picked in
                    selectedVehicleID = picked.id
                }
            } else {
                EmptyGarageView { showAddVehicle = true }
            }
        }
        .sheet(isPresented: $showAddVehicle) {
            AddVehicleView()
        }
        .onAppear {
            if selectedVehicleID == nil {
                selectedVehicleID = vehicles.first?.id
            }
        }
    }
}

struct MainTabView: View {
    let vehicle: Vehicle
    let vehicles: [Vehicle]
    let onSelect: (Vehicle) -> Void

    var body: some View {
        TabView {
            DashboardView(vehicle: vehicle)
                .tabItem { Label("Overview", systemImage: "chart.line.uptrend.xyaxis") }

            FillUpsView(vehicle: vehicle)
                .tabItem { Label("Fill-Ups", systemImage: "fuelpump.fill") }

            MaintenanceView(vehicle: vehicle)
                .tabItem { Label("Service", systemImage: "wrench.and.screwdriver.fill") }

            SettingsView(vehicle: vehicle, vehicles: vehicles, onSelect: onSelect)
                .tabItem { Label("Garage", systemImage: "car.fill") }
        }
    }
}

struct EmptyGarageView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "car.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("No vehicle yet")
                .font(.title2.weight(.semibold))
            Text("Add a vehicle to start tracking fuel use and service.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: onAdd) {
                Text("Add Vehicle")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
    }
}
