import SwiftUI

struct EmptyStateView: View {
    let category: StickerCategory
    let hasSearch: Bool
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: hasSearch ? "magnifyingglass" : "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(hasSearch ? "No stickers found" : emptyTitle)
                .font(.headline)
            if !hasSearch {
                Text("Import a GIF to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button(action: onAddTapped) {
                    Label("Add Sticker", systemImage: "plus")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var emptyTitle: String {
        switch category {
        case .favorites: return "No favorites yet"
        case .all: return "No stickers yet"
        default: return "No stickers in \(category.rawValue)"
        }
    }
}
