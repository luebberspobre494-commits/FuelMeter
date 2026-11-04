import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    let vehicle: Vehicle

    @Query(sort: \FillUp.date, order: .reverse) private var allFillUps: [FillUp]
    @Query private var allTasks: [ServiceTask]

    private var fillUps: [FillUp] {
        allFillUps.filter { $0.vehicleID == vehicle.id }
    }

    private var tasks: [ServiceTask] {
        allTasks.filter { $0.vehicleID == vehicle.id && !$0.isDone }
    }

    private var consumption: [ConsumptionPoint] {
        Stats.consumptionPoints(fillUps)
    }

    private var monthly: [MonthSpend] {
        Stats.monthlySpend(fillUps)
    }

    private var nextTask: ServiceTask? {
        tasks.sorted { lhs, rhs in
            let left = lhs.dueDate ?? .distantFuture
            let right = rhs.dueDate ?? .distantFuture
            return left < right
        }.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    HStack(spacing: 12) {
                        metricCard(
                            title: "This Month",
                            value: Fmt.money(Stats.monthSpend(fillUps)),
                            caption: "total spend",
                            symbol: "calendar"
                        )
                        metricCard(
                            title: "Avg Use",
                            value: consumption.isEmpty ? "—" : String(format: "%.1f", Stats.averageConsumption(fillUps) ?? 0),
                            caption: "L/100km",
                            symbol: "gauge.medium"
                        )
                    }

                    HStack(spacing: 12) {
                        metricCard(
                            title: "Per km",
                            value: Stats.costPerKilometer(fillUps).map { String(format: "%.2f", $0) } ?? "—",
                            caption: "cost per km",
                            symbol: "road.lanes"
                        )
                        metricCard(
                            title: "Fill-Ups",
                            value: "\(fillUps.count)",
                            caption: "records",
                            symbol: "fuelpump"
                        )
                    }

                    if !consumption.isEmpty {
                        chartCard(title: "Fuel Consumption") {
                            Chart(consumption) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("L/100km", point.litersPer100km)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(.tint)

                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("L/100km", point.litersPer100km)
                                )
                                .foregroundStyle(.tint)
                            }
                            .frame(height: 170)
                        }
                    }

                    chartCard(title: "Spend by Month") {
                        Chart(monthly) { item in
                            BarMark(
                                x: .value("Month", Fmt.month(item.monthStart)),
                                y: .value("Spend", item.amount)
                            )
                            .foregroundStyle(.tint)
                            .cornerRadius(6)
                        }
                        .frame(height: 170)
                    }

                    if let task = nextTask {
                        nextServiceCard(task)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vehicle.name)
                .font(.title2.weight(.bold))
            if !vehicle.plate.isEmpty {
                Text(vehicle.plate.uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Text("\(Fmt.distance(Stats.distanceCovered(fillUps))) tracked")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metricCard(title: String, value: String, caption: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func chartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            content()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func nextServiceCard(_ task: ServiceTask) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next service")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                if let due = task.dueDate {
                    Text("due \(Fmt.day(due))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
