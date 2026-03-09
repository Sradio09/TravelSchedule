import Foundation

struct Story: Identifiable, Hashable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

extension Story {
    /// Temporary mock data. Preview + full-size images will be wired later.
    static let mock: [Story] = (1...9).map { Story(title: "История \($0)") }
}
