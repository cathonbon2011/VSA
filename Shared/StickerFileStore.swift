import Foundation

/// Reads and writes the shared sticker index + GIF files inside the App Group container.
/// Safe to use from both the host app and the keyboard extension process.
final class StickerFileStore {
    static let shared = StickerFileStore()

    private init() {}

    private let queue = DispatchQueue(label: "com.vsa.stickers.filestore", attributes: .concurrent)

    func loadIndex() -> [Sticker] {
        queue.sync {
            guard let data = try? Data(contentsOf: AppGroup.indexFileURL) else { return [] }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return (try? decoder.decode([Sticker].self, from: data)) ?? []
        }
    }

    @discardableResult
    func saveIndex(_ stickers: [Sticker]) -> Bool {
        queue.sync(flags: .barrier) {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            guard let data = try? encoder.encode(stickers) else { return false }
            return (try? data.write(to: AppGroup.indexFileURL, options: .atomic)) != nil
        }
    }

    /// Copies raw GIF data into the shared container and returns the generated file name.
    func writeGIFData(_ data: Data, suggestedName: String) throws -> String {
        let sanitizedBase = suggestedName
            .replacingOccurrences(of: "/", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let base = sanitizedBase.isEmpty ? "sticker" : (sanitizedBase as NSString).deletingPathExtension
        let fileName = "\(base)-\(UUID().uuidString.prefix(8)).gif"
        let url = AppGroup.stickersDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    func deleteGIFFile(named fileName: String) {
        let url = AppGroup.stickersDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
}
