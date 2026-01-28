import Foundation

enum ThreadUIDExtractor {
    static func firstThreadUID(from searchData: Data) -> String? {
        guard
            let root = try? JSONSerialization.jsonObject(with: searchData) as? [String: Any],
            let segments = root["segments"] as? [[String: Any]],
            let first = segments.first,
            let thread = first["thread"] as? [String: Any],
            let uid = thread["uid"] as? String,
            !uid.isEmpty
        else {
            return nil
        }
        return uid
    }
}
