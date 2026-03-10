import Foundation

enum CitySearchViewState: Equatable, Sendable {
    case loading
    case success([StationChoice])
    case error(LoadError)
}
