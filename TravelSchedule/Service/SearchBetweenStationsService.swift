import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias SearchBetweenStations = Components.Schemas.SearchResponse

protocol SearchBetweenStationsServiceProtocol {
    func search(from: String, to: String, date: String?) async throws -> SearchBetweenStations
}

final class SearchBetweenStationsService: SearchBetweenStationsServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func search(from: String, to: String, date: String?) async throws -> SearchBetweenStations {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            date: date
        ))
        return try response.ok.body.json
    }
}
