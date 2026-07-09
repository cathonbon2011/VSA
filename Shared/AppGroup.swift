import Foundation

enum AppGroup {
    static let identifier = "group.com.vsa.stickers"

    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("App Group '\(identifier)' is not configured. Enable it in both targets' Signing & Capabilities.")
        }
        return url
    }

    static var stickersDirectory: URL {
        let url = containerURL.appendingPathComponent("Stickers", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    static var indexFileURL: URL {
        containerURL.appendingPathComponent("sticker_index.json")
    }
}
