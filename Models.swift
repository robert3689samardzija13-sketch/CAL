import Foundation

struct CalendarEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var year: Int
    var month: Int
    var day: Int
    var title: String
    var time: String = ""
    var notes: String = ""
    var repeatsYearly: Bool = false
}

struct Celebration: Identifiable, Codable, Hashable {
    var id = UUID()
    var month: Int
    var day: Int
    var name: String
    var icon: String = "🎉"
    var repeatsYearly: Bool = true
}

struct CalendarSettings: Codable {
    var calendarName = "Custom Calendar"
    var epochISO = "0001-01-07"
    var monthsPerYear = 13
    var daysPerMonth = 28
    var eraName = "Anno Domini"

    var monthNames: [String] = [
        "Month 1", "Month 2", "Month 3", "Month 4", "Month 5",
        "Month 6", "Month 7", "Month 8", "Month 9", "Month 10",
        "Month 11", "Month 12", "Month 13"
    ]

    var weekdayNames: [String] = [
        "Sunday", "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday"
    ]

    var showGregorianDate = true
}

final class CalendarStore: ObservableObject {
    @Published var settings: CalendarSettings {
        didSet { save() }
    }
    @Published var events: [CalendarEvent] {
        didSet { save() }
    }
    @Published var celebrations: [Celebration] {
        didSet { save() }
    }

    private let settingsKey = "custom-calendar.settings"
    private let eventsKey = "custom-calendar.events"
    private let celebrationsKey = "custom-calendar.celebrations"

    init() {
        settings = Self.load(CalendarSettings.self, key: settingsKey) ?? CalendarSettings()
        events = Self.load([CalendarEvent].self, key: eventsKey) ?? []
        celebrations = Self.load([Celebration].self, key: celebrationsKey) ?? []
    }

    func save() {
        Self.store(settings, key: settingsKey)
        Self.store(events, key: eventsKey)
        Self.store(celebrations, key: celebrationsKey)
    }

    func events(year: Int, month: Int, day: Int) -> [CalendarEvent] {
        events.filter {
            if $0.repeatsYearly {
                return $0.month == month && $0.day == day
            }
            return $0.year == year && $0.month == month && $0.day == day
        }
    }

    func celebrations(month: Int, day: Int) -> [Celebration] {
        celebrations.filter { $0.month == month && $0.day == day }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func store<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
