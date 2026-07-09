import Foundation
import Combine

@MainActor
final class StickerStore: ObservableObject {
    @Published private(set) var stickers: [Sticker] = []

    private let fileStore = StickerFileStore.shared

    init() {
        reload()
    }

    func reload() {
        stickers = fileStore.loadIndex().sorted { $0.dateAdded > $1.dateAdded }
    }

    func addSticker(data: Data, suggestedName: String, category: StickerCategory) throws {
        let fileName = try fileStore.writeGIFData(data, suggestedName: suggestedName)
        let displayName = (suggestedName as NSString).deletingPathExtension
        let sticker = Sticker(
            fileName: fileName,
            displayName: displayName.isEmpty ? "Sticker" : displayName,
            category: category.rawValue
        )
        stickers.insert(sticker, at: 0)
        persist()
    }

    func delete(_ sticker: Sticker) {
        stickers.removeAll { $0.id == sticker.id }
        fileStore.deleteGIFFile(named: sticker.fileName)
        persist()
    }

    func toggleFavorite(_ sticker: Sticker) {
        guard let index = stickers.firstIndex(where: { $0.id == sticker.id }) else { return }
        stickers[index].isFavorite.toggle()
        persist()
    }

    func updateCategory(_ sticker: Sticker, to category: StickerCategory) {
        guard let index = stickers.firstIndex(where: { $0.id == sticker.id }) else { return }
        stickers[index].category = category.rawValue
        persist()
    }

    func rename(_ sticker: Sticker, to newName: String) {
        guard let index = stickers.firstIndex(where: { $0.id == sticker.id }) else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        stickers[index].displayName = trimmed
        persist()
    }

    func stickers(in category: StickerCategory, search: String) -> [Sticker] {
        var filtered = stickers
        switch category {
        case .all:
            break
        case .favorites:
            filtered = filtered.filter(\.isFavorite)
        default:
            filtered = filtered.filter { $0.category == category.rawValue }
        }
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return filtered }
        return filtered.filter {
            $0.displayName.localizedCaseInsensitiveContains(trimmedSearch) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(trimmedSearch) }
        }
    }

    private func persist() {
        fileStore.saveIndex(stickers)
    }
}
