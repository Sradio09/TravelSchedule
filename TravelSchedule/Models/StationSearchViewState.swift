import Foundation

enum StationSearchViewState: Equatable, Sendable {
    case loading
    case success([StationChoice])
    case error(LoadError)
}
