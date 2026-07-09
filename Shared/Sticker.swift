import Foundation

struct Sticker: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var fileName: String
    var displayName: String
    var category: String
    var tags: [String]
    var dateAdded: Date
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        fileName: String,
        displayName: String,
        category: String = StickerCategory.uncategorized.rawValue,
        tags: [String] = [],
        dateAdded: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.fileName = fileName
        self.displayName = displayName
        self.category = category
        self.tags = tags
        self.dateAdded = dateAdded
        self.isFavorite = isFavorite
    }

    var fileURL: URL {
        AppGroup.stickersDirectory.appendingPathComponent(fileName)
    }
}

enum StickerCategory: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case favorites = "Favorites"
    case uncategorized = "Uncategorized"
    case reactions = "Reactions"
    case memes = "Memes"
    case animals = "Animals"
    case emotions = "Emotions"

    var id: String { rawValue }

    /// Categories a sticker can actually be filed under (excludes the virtual "All"/"Favorites" filters).
    static var assignable: [StickerCategory] {
        allCases.filter { $0 != .all && $0 != .favorites }
    }

    var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .favorites: return "star.fill"
        case .uncategorized: return "tray"
        case .reactions: return "face.smiling"
        case .memes: return "theatermasks"
        case .animals: return "pawprint"
        case .emotions: return "heart"
        }
    }
}
