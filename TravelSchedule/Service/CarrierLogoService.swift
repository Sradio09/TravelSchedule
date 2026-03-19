import Foundation

actor CarrierLogoService {
    static let shared = CarrierLogoService()

    private let networkClient: RaspNetworkClient

    init(networkClient: RaspNetworkClient = .shared) {
        self.networkClient = networkClient
    }

    func logoURL(for carrierCode: Int?) async -> URL? {
        await networkClient.carrierLogoURL(for: carrierCode)
    }
}
