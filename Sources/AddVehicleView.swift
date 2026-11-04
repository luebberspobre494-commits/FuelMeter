import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var plate = ""

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle") {
                    TextField("Name, e.g. Corolla", text: $name)
                    TextField("Plate (optional)", text: $plate)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("New Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let vehicle = Vehicle(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            plate: plate.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(vehicle)
        dismiss()
    }
}
