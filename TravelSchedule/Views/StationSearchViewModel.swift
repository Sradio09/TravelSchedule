import Foundation

@MainActor
final class StationSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var viewState: StationSearchViewState = .loading

    private let city: StationChoice
    private let stationsRepository: StationsRepository

    init(city: StationChoice, stationsRepository: StationsRepository = .shared) {
        self.city = city
        self.stationsRepository = stationsRepository
    }

    var filteredStations: [StationChoice] {
        guard case let .success(stations) = viewState else { return [] }
        guard !searchText.isEmpty else { return stations }

        return stations.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadStations() async {
        viewState = .loading

        do {
            let allStations = try await stationsRepository.loadStations()
            let cityStations = allStations
                .filter { $0.settlementTitle == city.title }
                .sorted { lhs, rhs in
                    lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }

            viewState = .success(cityStations)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                viewState = .error(.noInternet)
            } else {
                viewState = .error(.server)
            }
        } catch {
            viewState = .error(.server)
        }
    }
}
