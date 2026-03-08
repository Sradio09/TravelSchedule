import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class StationsRepository {

    enum RepositoryError: Error {
        case invalidServerURL
    }

    static let shared = StationsRepository()

    private let service: StationsListService?
    private var cached: [StationChoice]?

    private init() {
        guard let serverURL = try? Servers.Server1.url() else {
            service = nil
            return
        }

        let client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )

        service = StationsListService(
            client: client,
            apikey: APIKey.yandexRasp
        )
    }

    func loadStations() async throws -> [StationChoice] {
        if let cached {
            return cached
        }

        guard let service else {
            throw RepositoryError.invalidServerURL
        }

        let data = try await service.loadStationsData()
        let stations = parse(data: data)
        cached = stations
        return stations
    }

    private func parse(data: Data) -> [StationChoice] {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let countries = json["countries"] as? [[String: Any]]
        else {
            return []
        }

        var result: [StationChoice] = []

        for country in countries {
            let regions = country["regions"] as? [[String: Any]] ?? []

            for region in regions {
                let settlements = region["settlements"] as? [[String: Any]] ?? []

                for settlement in settlements {
                    let settlementTitle = settlement["title"] as? String
                    let stations = settlement["stations"] as? [[String: Any]] ?? []

                    for station in stations {
                        guard
                            let title = station["title"] as? String,
                            let codes = station["codes"] as? [String: Any],
                            let yandexCode = codes["yandex_code"] as? String
                        else {
                            continue
                        }

                        let stationType = station["station_type"] as? String
                        let stationTypeName = station["station_type_name"] as? String

                        let item = StationChoice(
                            title: title,
                            yandexCode: yandexCode,
                            settlementTitle: settlementTitle,
                            stationType: stationType,
                            stationTypeName: stationTypeName
                        )

                        result.append(item)
                    }
                }
            }
        }

        return result.sorted { lhs, rhs in
            lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }
}
