import SwiftUI
import SwiftData

struct SettingsView: View {
    let vehicle: Vehicle
    let vehicles: [Vehicle]
    let onSelect: (Vehicle) -> Void

    @Environment(\.modelContext) private var context
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section("Vehicles") {
                    ForEach(vehicles) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "car.fill")
                                    .foregroundStyle(item.id == vehicle.id ? Color.accentColor : Color.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    if !item.plate.isEmpty {
                                        Text(item.plate.uppercased())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if item.id == vehicle.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteVehicles)
                    Button {
                        showAdd = true
                    } label: {
                        Label("Add Vehicle", systemImage: "plus.circle.fill")
                    }
                }

                Section("Units") {
                    HStack {
                        Text("Distance")
                        Spacer()
                        Text("kilometers").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Volume")
                        Spacer()
                        Text("liters").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Consumption")
                        Spacer()
                        Text("L/100 km").foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("FuelMeter stores everything on this device. No account, no tracking.")
                }
            }
            .navigationTitle("Garage")
            .sheet(isPresented: $showAdd) {
                AddVehicleView()
            }
        }
    }

    private func deleteVehicles(at offsets: IndexSet) {
        for index in offsets {
            let target = vehicles[index]
            if vehicles.count > 1, target.id == vehicle.id {
                continue
            }
            context.delete(target)
        }
    }
}
