import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CalendarStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Calendar") {
                    TextField("Calendar name", text: $store.settings.calendarName)
                    TextField("Era name", text: $store.settings.eraName)
                    TextField("Epoch (YYYY-MM-DD)", text: $store.settings.epochISO)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Stepper("Months per year: \(store.settings.monthsPerYear)",
                            value: $store.settings.monthsPerYear, in: 1...36)

                    Stepper("Days per month: \(store.settings.daysPerMonth)",
                            value: $store.settings.daysPerMonth, in: 1...100)

                    Toggle("Show Gregorian date", isOn: $store.settings.showGregorianDate)
                }

                Section("Months") {
                    ForEach(store.settings.monthNames.indices, id: \.self) { index in
                        TextField("Month \(index + 1)", text: $store.settings.monthNames[index])
                    }
                }

                Section("Weekdays") {
                    ForEach(store.settings.weekdayNames.indices, id: \.self) { index in
                        TextField("Weekday \(index + 1)", text: $store.settings.weekdayNames[index])
                    }
                }

                Section("Your Celebrations") {
                    if store.celebrations.isEmpty {
                        Text("Add celebrations from any day.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.celebrations) { celebration in
                            HStack {
                                Text(celebration.icon)
                                VStack(alignment: .leading) {
                                    Text(celebration.name)
                                    Text("Month \(celebration.month), Day \(celebration.day)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            store.celebrations.remove(atOffsets: offsets)
                        }
                    }
                }

                Section("About this version") {
                    Text("13 × 28 is the default. No Year Day and no Leap Day. The epoch is fully editable.")
                    Text("All data is stored locally on this iPhone.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
