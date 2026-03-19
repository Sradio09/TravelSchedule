import Foundation

actor StationsRepository {
    static let shared = StationsRepository()

    private let networkClient: RaspNetworkClient

    init(networkClient: RaspNetworkClient = .shared) {
        self.networkClient = networkClient
    }

    func loadStations() async throws -> [StationChoice] {
        try await networkClient.loadStations()
    }
}
