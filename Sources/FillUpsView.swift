import SwiftUI
import SwiftData

struct FillUpsView: View {
    let vehicle: Vehicle

    @Query(sort: \FillUp.date, order: .reverse) private var allFillUps: [FillUp]
    @Environment(\.modelContext) private var context
    @State private var showAdd = false

    private var fillUps: [FillUp] {
        allFillUps.filter { $0.vehicleID == vehicle.id }
    }

    var body: some View {
        NavigationStack {
            Group {
                if fillUps.isEmpty {
                    ContentUnavailableView(
                        "No fill-ups yet",
                        systemImage: "fuelpump",
                        description: Text("Tap + to log your first fill-up.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(fillUps) { fillUp in
                                row(fillUp)
                            }
                            .onDelete(perform: delete)
                        } footer: {
                            Text("Swipe left to delete a record.")
                        }
                    }
                }
            }
            .navigationTitle("Fill-Ups")
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
                AddFillUpView(vehicle: vehicle)
            }
        }
    }

    private func row(_ fillUp: FillUp) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(Fmt.day(fillUp.date))
                        .font(.subheadline.weight(.semibold))
                    if fillUp.isFull {
                        Text("FULL")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                Text("\(Fmt.odometer(fillUp.odometer)) · \(Fmt.liters(fillUp.volume)) · \(String(format: "%.2f", fillUp.pricePerLiter))/L")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !fillUp.note.isEmpty {
                    Text(fillUp.note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(Fmt.money(fillUp.total))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(fillUps[index])
        }
    }
}
