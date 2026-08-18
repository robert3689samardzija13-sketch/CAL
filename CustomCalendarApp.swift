import SwiftUI

@main
struct CustomCalendarApp: App {
    @StateObject private var store = CalendarStore()

    var body: some Scene {
        WindowGroup {
            CalendarView()
                .environmentObject(store)
        }
    }
}
