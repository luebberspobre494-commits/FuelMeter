import SwiftUI
import SwiftData

struct MaintenanceView: View {
    let vehicle: Vehicle

    @Query(sort: \ServiceTask.title) private var allTasks: [ServiceTask]
    @Environment(\.modelContext) private var context
    @State private var showAdd = false

    private var tasks: [ServiceTask] {
        allTasks.filter { $0.vehicleID == vehicle.id }
            .sorted { lhs, rhs in
                if lhs.isDone != rhs.isDone { return !lhs.isDone }
                let left = lhs.dueDate ?? .distantFuture
                let right = rhs.dueDate ?? .distantFuture
                return left < right
            }
    }

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No service tasks",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Add oil changes, inspections or insurance renewals.")
                    )
                } else {
                    List {
                        ForEach(tasks) { task in
                            row(task)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Service")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddServiceTaskView(vehicle: vehicle)
            }
        }
    }

    private func row(_ task: ServiceTask) -> some View {
        HStack(spacing: 12) {
            Button {
                toggle(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(task.isDone, color: .secondary)
                    .foregroundStyle(task.isDone ? Color.secondary : Color.primary)
                if let due = task.dueDate {
                    Text("due \(Fmt.day(due))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let odo = task.dueOdometer {
                    Text("at \(Fmt.odometer(odo))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private func toggle(_ task: ServiceTask) {
        task.isDone.toggle()
        if task.isDone {
            Notifications.cancel(for: task)
        } else if let due = task.dueDate {
            Notifications.schedule(for: task, dueDate: due)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            Notifications.cancel(for: task)
            context.delete(task)
        }
    }
}
