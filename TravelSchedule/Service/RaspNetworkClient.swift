import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor RaspNetworkClient {

    enum ClientError: Error {
        case invalidServerURL
    }

    static let shared = RaspNetworkClient()

    private let serverURL: URL
    private let apiKey: String

    private var cachedStations: [StationChoice]?
    private var cachedCarrierLogos: [Int: URL?] = [:]

    init(apiKey: String = APIKey.yandexRasp) {
        guard let serverURL = try? Servers.Server1.url() else {
            fatalError("Failed to build Yandex Rasp server URL")
        }

        self.serverURL = serverURL
        self.apiKey = apiKey
    }

    func loadStations() async throws -> [StationChoice] {
        if let cachedStations {
            return cachedStations
        }

        let data = try await StationsListService(
            client: makeClient(),
            apikey: apiKey
        ).loadStationsData()

        let stations = parseStations(from: data)
        cachedStations = stations
        return stations
    }

    func search(
        from: String,
        to: String,
        date: String?
    ) async throws -> Components.Schemas.SearchResponse {
        try await SearchBetweenStationsService(
            client: makeClient(),
            apikey: apiKey
        ).search(from: from, to: to, date: date)
    }

    func carrierInfo(code: Int) async throws -> Components.Schemas.CarrierInfo? {
        let response = try await CarrierInfoService(
            client: makeClient(),
            apikey: apiKey
        ).getCarrier(code: code)

        return response.carrier
    }

    func schedule(station: String, date: String?) async throws -> ScheduleOnStation {
        try await ScheduleOnStationService(
            client: makeClient(),
            apikey: apiKey
        ).getSchedule(station: station, date: date)
    }

    func thread(uid: String, date: String?) async throws -> ThreadStations {
        try await ThreadStationsService(
            client: makeClient(),
            apikey: apiKey
        ).getThread(uid: uid, date: date)
    }

    func nearestStations(
        lat: Double,
        lng: Double,
        distance: Int
    ) async throws -> NearestStations {
        try await NearestStationsService(
            client: makeClient(),
            apikey: apiKey
        ).getNearestStations(lat: lat, lng: lng, distance: distance)
    }

    func nearestSettlement(
        lat: Double,
        lng: Double
    ) async throws -> NearestSettlement {
        try await NearestSettlementService(
            client: makeClient(),
            apikey: apiKey
        ).getNearestSettlement(lat: lat, lng: lng)
    }

    func copyright() async throws -> YandexRaspCopyright {
        try await CopyrightService(
            client: makeClient(),
            apikey: apiKey
        ).getCopyright()
    }

    func carrierLogoURL(for carrierCode: Int?) async -> URL? {
        guard let carrierCode else { return nil }

        if let cached = cachedCarrierLogos[carrierCode] {
            return cached
        }

        do {
            guard let carrier = try await carrierInfo(code: carrierCode) else {
                cachedCarrierLogos[carrierCode] = nil
                return nil
            }

            let normalized = Self.normalizedURL(from: carrier.logo)
            cachedCarrierLogos[carrierCode] = normalized
            return normalized
        } catch {
            cachedCarrierLogos[carrierCode] = nil
            return nil
        }
    }

    private func makeClient() -> Client {
        Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }

    private func parseStations(from data: Data) -> [StationChoice] {
        guard let response = try? JSONDecoder().decode(StationsResponse.self, from: data) else {
            return []
        }

        var result: [StationChoice] = []

        for country in response.countries {
            for region in country.regions {
                for settlement in region.settlements {
                    for station in settlement.stations {
                        result.append(
                            StationChoice(
                                title: station.title,
                                yandexCode: station.codes.yandexCode,
                                settlementTitle: settlement.title,
                                stationType: station.stationType,
                                stationTypeName: station.stationTypeName
                            )
                        )
                    }
                }
            }
        }

        return result.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private static func normalizedURL(from rawLogo: String?) -> URL? {
        guard let rawLogo else { return nil }

        let trimmed = rawLogo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.hasPrefix("//") {
            return URL(string: "https:" + trimmed)
        }

        return URL(string: trimmed)
    }
}

private struct StationsResponse: Decodable {
    let countries: [Country]
}

private struct Country: Decodable {
    let regions: [Region]
}

private struct Region: Decodable {
    let settlements: [Settlement]
}

private struct Settlement: Decodable {
    let title: String?
    let stations: [Station]
}

private struct Station: Decodable {
    let title: String
    let stationType: String?
    let stationTypeName: String?
    let codes: StationCodes

    enum CodingKeys: String, CodingKey {
        case title
        case stationType = "station_type"
        case stationTypeName = "station_type_name"
        case codes
    }
}

private struct StationCodes: Decodable {
    let yandexCode: String

    enum CodingKeys: String, CodingKey {
        case yandexCode = "yandex_code"
    }
}
