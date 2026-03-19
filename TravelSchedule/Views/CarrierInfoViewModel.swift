import Foundation

@MainActor
final class CarrierInfoViewModel: ObservableObject {

    enum State: Sendable {
        case loading
        case loaded(Components.Schemas.CarrierInfo)
        case failed(LoadError)
    }

    @Published private(set) var state: State = .loading

    private let carrierCode: Int
    private let networkClient: RaspNetworkClient

    init(carrierCode: Int, networkClient: RaspNetworkClient = .shared) {
        self.carrierCode = carrierCode
        self.networkClient = networkClient
    }

    func load() async {
        state = .loading

        do {
            if let carrier = try await networkClient.carrierInfo(code: carrierCode) {
                state = .loaded(carrier)
            } else {
                state = .failed(.server)
            }
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                state = .failed(.noInternet)
            } else {
                state = .failed(.server)
            }
        } catch {
            state = .failed(.server)
        }
    }
}
