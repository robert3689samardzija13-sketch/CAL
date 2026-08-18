import Foundation

struct CustomDate: Hashable, Codable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    static func < (lhs: CustomDate, rhs: CustomDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

enum CustomCalendarError: Error {
    case invalidEpoch
    case invalidDate
}

struct CustomCalendarEngine {
    static func gregorianCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }

    static func parseISODate(_ text: String) -> Date? {
        let parts = text.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.calendar = gregorianCalendar()
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return gregorianCalendar().date(from: components)
    }

    static func isoString(_ date: Date) -> String {
        let c = gregorianCalendar().dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func customDate(from gregorianDate: Date, settings: CalendarSettings) -> CustomDate? {
        guard let epoch = parseISODate(settings.epochISO) else { return nil }
        let cal = gregorianCalendar()
        let days = cal.dateComponents([.day], from: epoch, to: gregorianDate).day ?? 0
        guard settings.monthsPerYear > 0, settings.daysPerMonth > 0 else { return nil }

        let yearLength = settings.monthsPerYear * settings.daysPerMonth
        let zeroBasedYear = days >= 0 ? days / yearLength : Int((Double(days) / Double(yearLength)).rounded(.down))
        let dayOfYear = days - zeroBasedYear * yearLength

        let year = zeroBasedYear + 1
        let month = dayOfYear / settings.daysPerMonth + 1
        let day = dayOfYear % settings.daysPerMonth + 1
        return CustomDate(year: year, month: month, day: day)
    }

    static func gregorianDate(from customDate: CustomDate, settings: CalendarSettings) -> Date? {
        guard let epoch = parseISODate(settings.epochISO),
              settings.monthsPerYear > 0,
              settings.daysPerMonth > 0 else { return nil }

        let yearLength = settings.monthsPerYear * settings.daysPerMonth
        let offset = (customDate.year - 1) * yearLength
            + (customDate.month - 1) * settings.daysPerMonth
            + (customDate.day - 1)

        return gregorianCalendar().date(byAdding: .day, value: offset, to: epoch)
    }

    static func weekdayIndex(for customDate: CustomDate, settings: CalendarSettings) -> Int {
        guard let date = gregorianDate(from: customDate, settings: settings) else { return 0 }
        // Calendar weekday is 1...7, Sunday = 1.
        return gregorianCalendar().component(.weekday, from: date) - 1
    }

    static func monthTitle(_ month: Int, settings: CalendarSettings) -> String {
        guard month >= 1, month <= settings.monthNames.count else {
            return "Month \(month)"
        }
        return settings.monthNames[month - 1]
    }
}
