import SwiftUI

struct DayView: View {
    @EnvironmentObject private var store: CalendarStore
    let date: CustomDate

    @Environment(\.dismiss) private var dismiss
    @State private var showEventEditor = false
    @State private var showCelebrationEditor = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(CustomCalendarEngine.monthTitle(date.month, settings: store.settings)) \(date.day)")
                            .font(.largeTitle.bold())
                        Text("\(store.settings.eraName) \(date.year)")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        if store.settings.showGregorianDate,
                           let gregorian = CustomCalendarEngine.gregorianDate(from: date, settings: store.settings) {
                            Text(CustomCalendarEngine.isoString(gregorian))
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                let celebrations = store.celebrations(month: date.month, day: date.day)
                if !celebrations.isEmpty {
                    Section("Celebrations") {
                        ForEach(celebrations) { celebration in
                            HStack {
                                Text(celebration.icon)
                                Text(celebration.name)
                            }
                        }
                        .onDelete { offsets in
                            store.celebrations.remove(atOffsets: offsets)
                        }
                    }
                }

                Section("Events") {
                    let events = store.events(year: date.year, month: date.month, day: date.day)
                    if events.isEmpty {
                        Text("No events")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(events) { event in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(event.title)
                                    .font(.headline)
                                if !event.time.isEmpty {
                                    Text(event.time)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if !event.notes.isEmpty {
                                    Text(event.notes)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if event.repeatsYearly {
                                    Text("Repeats yearly")
                                        .font(.caption)
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { events[$0].id }
                            store.events.removeAll { ids.contains($0.id) }
                        }
                    }
                }
            }
            .navigationTitle("Day")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add Event") { showEventEditor = true }
                        Button("Add Celebration") { showCelebrationEditor = true }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEventEditor) {
                EventEditor(date: date)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showCelebrationEditor) {
                CelebrationEditor(month: date.month, day: date.day)
                    .environmentObject(store)
            }
        }
    }
}

struct EventEditor: View {
    @EnvironmentObject private var store: CalendarStore
    @Environment(\.dismiss) private var dismiss
    let date: CustomDate

    @State private var title = ""
    @State private var time = ""
    @State private var notes = ""
    @State private var repeatsYearly = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Time (optional)", text: $time)
                TextField("Notes", text: $notes, axis: .vertical)
                Toggle("Repeat every year", isOn: $repeatsYearly)
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        store.events.append(
                            CalendarEvent(
                                year: date.year,
                                month: date.month,
                                day: date.day,
                                title: title,
                                time: time,
                                notes: notes,
                                repeatsYearly: repeatsYearly
                            )
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct CelebrationEditor: View {
    @EnvironmentObject private var store: CalendarStore
    @Environment(\.dismiss) private var dismiss
    let month: Int
    let day: Int

    @State private var name = ""
    @State private var icon = "🎉"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Icon", text: $icon)
            }
            .navigationTitle("Celebration")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        store.celebrations.append(
                            Celebration(month: month, day: day, name: name, icon: icon)
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
