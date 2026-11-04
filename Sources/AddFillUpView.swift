import SwiftUI
import SwiftData

struct AddFillUpView: View {
    let vehicle: Vehicle

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var odometer = ""
    @State private var volume = ""
    @State private var price = ""
    @State private var isFull = true
    @State private var note = ""

    private var total: Double {
        (Double(volume) ?? 0) * (Double(price) ?? 0)
    }

    private var canSave: Bool {
        guard let odo = Double(odometer), odo > 0,
              let vol = Double(volume), vol > 0,
              let priceValue = Double(price), priceValue > 0 else {
            return false
        }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fill-Up") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    HStack {
                        Text("Odometer")
                        Spacer()
                        TextField("km", text: $odometer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Volume")
                        Spacer()
                        TextField("L", text: $volume)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Price / L")
                        Spacer()
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Filled to full", isOn: $isFull)
                }

                Section("Total") {
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text(Fmt.money(total))
                            .font(.headline)
                            .monospacedDigit()
                    }
                }

                Section("Note") {
                    TextField("Optional", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Fill-Up")
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
        guard let odo = Double(odometer),
              let vol = Double(volume),
              let priceValue = Double(price) else { return }

        let fillUp = FillUp(
            vehicleID: vehicle.id,
            date: date,
            odometer: odo,
            volume: vol,
            pricePerLiter: priceValue,
            isFull: isFull,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(fillUp)
        dismiss()
    }
}
