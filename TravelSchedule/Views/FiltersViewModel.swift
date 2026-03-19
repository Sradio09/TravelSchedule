import Foundation

@MainActor
final class FiltersViewModel: ObservableObject {
    @Published var morning = false
    @Published var day = false
    @Published var evening = false
    @Published var night = false
    @Published var allowTransfers = true

    var hasSelection: Bool {
        morning || day || evening || night || !allowTransfers
    }

    var currentFilter: DepartureFilter {
        DepartureFilter(
            morning: morning,
            day: day,
            evening: evening,
            night: night,
            allowTransfers: allowTransfers
        )
    }

    func apply(initialFilter: DepartureFilter?) {
        guard let initialFilter else { return }
        morning = initialFilter.morning
        day = initialFilter.day
        evening = initialFilter.evening
        night = initialFilter.night
        allowTransfers = initialFilter.allowTransfers
    }

    func toggleMorning() {
        morning.toggle()
    }

    func toggleDay() {
        day.toggle()
    }

    func toggleEvening() {
        evening.toggle()
    }

    func toggleNight() {
        night.toggle()
    }

    func setAllowTransfers(_ value: Bool) {
        allowTransfers = value
    }
}
