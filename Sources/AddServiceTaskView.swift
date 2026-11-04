import SwiftUI
import SwiftData

struct AddServiceTaskView: View {
    let vehicle: Vehicle

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var hasDueDate = true
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var hasOdometer = false
    @State private var odometer = ""
    @State private var notes = ""

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("e.g. Oil change", text: $title)
                }

                Section("Reminder") {
                    Toggle("Date reminder", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                    Toggle("Odometer reminder", isOn: $hasOdometer)
                    if hasOdometer {
                        HStack {
                            Text("At")
                            Spacer()
                            TextField("km", text: $odometer)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Task")
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
        let task = ServiceTask(
            vehicleID: vehicle.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: hasDueDate ? dueDate : nil,
            dueOdometer: hasOdometer ? Double(odometer) : nil,
            notes: notes
        )
        context.insert(task)

        if hasDueDate {
            Notifications.schedule(for: task, dueDate: dueDate)
        }
        dismiss()
    }
}
