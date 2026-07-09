import SwiftUI

struct StickerLibraryView: View {
    @EnvironmentObject private var store: StickerStore
    @Binding var showingAddSticker: Bool

    @State private var selectedCategory: StickerCategory = .all
    @State private var searchText = ""
    @State private var stickerToShow: Sticker?

    private let columns = [GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 14)]

    private var visibleStickers: [Sticker] {
        store.stickers(in: selectedCategory, search: searchText)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryTabBar(selected: $selectedCategory)

                if visibleStickers.isEmpty {
                    EmptyStateView(category: selectedCategory, hasSearch: !searchText.isEmpty) {
                        showingAddSticker = true
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(visibleStickers) { sticker in
                                Button {
                                    stickerToShow = sticker
                                } label: {
                                    StickerGridCell(sticker: sticker)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Stickers")
            .searchable(text: $searchText, prompt: "Search stickers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSticker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSticker) {
                AddStickerView()
            }
            .sheet(item: $stickerToShow) { sticker in
                StickerDetailView(sticker: sticker)
            }
            .onAppear { store.reload() }
        }
    }
}

struct StickerGridCell: View {
    let sticker: Sticker

    var body: some View {
        VStack(spacing: 6) {
            GIFThumbnail(sticker: sticker)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    if sticker.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                            .padding(6)
                    }
                }

            Text(sticker.displayName)
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StickerLibraryView(showingAddSticker: .constant(false))
        .environmentObject(StickerStore())
}
