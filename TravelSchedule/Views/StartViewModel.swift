import Foundation

@MainActor
final class StartViewModel: ObservableObject {

    enum SelectionType: Identifiable, Sendable {
        case from
        case to

        var id: Int {
            switch self {
            case .from: return 0
            case .to: return 1
            }
        }

        var screenTitle: String {
            "Выбор города"
        }
    }

    @Published var fromStation: StationChoice?
    @Published var toStation: StationChoice?
    @Published var showStoryViewer = false
    @Published var selectedStoryIndex = 0
    @Published var storyRefreshToken = UUID()
    @Published var activeSelection: SelectionType?
    @Published var showSchedule = false

    let stories = Story.mock

    var canSearch: Bool {
        fromStation != nil && toStation != nil
    }

    var fromTitle: String {
        fromStation?.title ?? "Откуда"
    }

    var toTitle: String {
        toStation?.title ?? "Куда"
    }

    func selectStory(at index: Int) {
        selectedStoryIndex = index
        showStoryViewer = true
    }

    func handleStoryDismiss() {
        storyRefreshToken = UUID()
    }

    func setStation(_ station: StationChoice, for selection: SelectionType) {
        switch selection {
        case .from:
            fromStation = station
        case .to:
            toStation = station
        }
        activeSelection = nil
    }

    func openSelection(_ selection: SelectionType) {
        activeSelection = selection
    }

    func openSchedule() {
        guard canSearch else { return }
        showSchedule = true
    }

    func swapStations() {
        (fromStation, toStation) = (toStation, fromStation)
    }
}
