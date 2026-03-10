import Foundation

struct DepartureFilter: Sendable {
    
    let morning: Bool
    let day: Bool
    let evening: Bool
    let night: Bool
    
    let allowTransfers: Bool
}
