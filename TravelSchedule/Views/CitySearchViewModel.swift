import Foundation

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var viewState: CitySearchViewState = .loading

    private let stationsRepository: StationsRepository

    private let popularCitiesOrder: [String] = [
        "Москва",
        "Санкт-Петербург",
        "Казань",
        "Нижний Новгород",
        "Сочи",
        "Екатеринбург",
        "Краснодар",
        "Ростов-на-Дону",
        "Новосибирск",
        "Самара"
    ]

    init(stationsRepository: StationsRepository = .shared) {
        self.stationsRepository = stationsRepository
    }

    var filteredCities: [StationChoice] {
        guard case let .success(cities) = viewState else { return [] }
        guard !searchText.isEmpty else { return cities }

        return cities.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadCities() async {
        viewState = .loading

        do {
            let allStations = try await stationsRepository.loadStations()
            let preparedCities = prepareCities(from: allStations)
            viewState = .success(sortCitiesByPriority(preparedCities))
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

    private func prepareCities(from stations: [StationChoice]) -> [StationChoice] {
        let stationsWithSettlement = stations.filter {
            guard let settlementTitle = $0.settlementTitle else { return false }
            return !settlementTitle.isEmpty
        }

        let groupedByCity = Dictionary(grouping: stationsWithSettlement) {
            $0.settlementTitle ?? ""
        }

        return groupedByCity.compactMap { cityTitle, stations in
            guard let firstStation = stations.first else { return nil }

            return StationChoice(
                title: cityTitle,
                yandexCode: firstStation.yandexCode,
                settlementTitle: cityTitle
            )
        }
    }

    private func sortCitiesByPriority(_ cities: [StationChoice]) -> [StationChoice] {
        let priorities = Dictionary(
            uniqueKeysWithValues: popularCitiesOrder.enumerated().map { ($1, $0) }
        )

        return cities.sorted { lhs, rhs in
            let leftPriority = priorities[lhs.title]
            let rightPriority = priorities[rhs.title]

            switch (leftPriority, rightPriority) {
            case let (left?, right?):
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
        }
    }
}
