import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: CalendarStore
    @State private var visibleYear: Int = 1
    @State private var visibleMonth: Int = 1
    @State private var selectedDate: CustomDate?
    @State private var showDay = false
    @State private var showSettings = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                weekdayHeader
                calendarGrid
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Today") { goToToday() }
                        .font(.subheadline.weight(.semibold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showDay) {
                if let selectedDate {
                    DayView(date: selectedDate)
                        .environmentObject(store)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
            }
            .onAppear(perform: goToToday)
            .onChange(of: store.settings.epochISO) { _, _ in goToToday() }
            .onChange(of: store.settings.monthsPerYear) { _, _ in goToToday() }
            .onChange(of: store.settings.daysPerMonth) { _, _ in goToToday() }
        }
    }

    private var header: some View {
        HStack {
            Button {
                moveMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(CustomCalendarEngine.monthTitle(visibleMonth, settings: store.settings))
                    .font(.title2.weight(.semibold))
                Text("\(store.settings.eraName) \(visibleYear)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                moveMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(shortWeekday(store.settings.weekdayNames[index]))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
            }
        }
        .padding(.horizontal, 8)
    }

    private var calendarGrid: some View {
        let days = Array(1...max(store.settings.daysPerMonth, 1))
        let first = CustomCalendarEngine.weekdayIndex(
            for: CustomDate(year: visibleYear, month: visibleMonth, day: 1),
            settings: store.settings
        )

        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<first, id: \.self) { _ in
                Color.clear.frame(height: 58)
            }

            ForEach(days, id: \.self) { day in
                let date = CustomDate(year: visibleYear, month: visibleMonth, day: day)
                DayCell(
                    date: date,
                    isToday: isToday(date),
                    isSelected: selectedDate == date,
                    events: store.events(year: date.year, month: date.month, day: date.day),
                    celebrations: store.celebrations(month: date.month, day: date.day)
                ) {
                    selectedDate = date
                    showDay = true
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private func shortWeekday(_ name: String) -> String {
        String(name.prefix(3))
    }

    private func isToday(_ date: CustomDate) -> Bool {
        guard let today = CustomCalendarEngine.customDate(from: Date(), settings: store.settings) else {
            return false
        }
        return today == date
    }

    private func goToToday() {
        guard let today = CustomCalendarEngine.customDate(from: Date(), settings: store.settings) else { return }
        visibleYear = today.year
        visibleMonth = today.month
    }

    private func moveMonth(_ delta: Int) {
        let count = max(store.settings.monthsPerYear, 1)
        var month = visibleMonth + delta
        var year = visibleYear

        while month > count {
            month -= count
            year += 1
        }
        while month < 1 {
            month += count
            year -= 1
        }

        visibleMonth = month
        visibleYear = max(year, 1)
    }
}

struct DayCell: View {
    let date: CustomDate
    let isToday: Bool
    let isSelected: Bool
    let events: [CalendarEvent]
    let celebrations: [Celebration]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("\(date.day)")
                        .font(.system(size: 16, weight: isToday ? .bold : .regular))
                        .frame(width: 28, height: 28)
                        .background(isToday ? Color.accentColor : .clear)
                        .foregroundStyle(isToday ? .white : .primary)
                        .clipShape(Circle())

                    Spacer()
                }

                if let celebration = celebrations.first {
                    Text("\(celebration.icon) \(celebration.name)")
                        .font(.system(size: 8))
                        .lineLimit(1)
                } else if !events.isEmpty {
                    Text(events.first?.title ?? "")
                        .font(.system(size: 8))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(5)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .topLeading)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
