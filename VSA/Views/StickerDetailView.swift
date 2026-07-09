import SwiftUI

struct StickerDetailView: View {
    @EnvironmentObject private var store: StickerStore
    @Environment(\.dismiss) private var dismiss

    let sticker: Sticker

    @State private var name: String
    @State private var category: StickerCategory
    @State private var showingDeleteConfirm = false

    init(sticker: Sticker) {
        self.sticker = sticker
        _name = State(initialValue: sticker.displayName)
        _category = State(initialValue: StickerCategory(rawValue: sticker.category) ?? .uncategorized)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        GIFThumbnail(sticker: sticker)
                            .frame(width: 180, height: 180)
                        Spacer()
                    }
                }

                Section("Details") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(StickerCategory.assignable) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    Toggle("Favorite", isOn: Binding(
                        get: { current?.isFavorite ?? sticker.isFavorite },
                        set: { _ in store.toggleFavorite(sticker) }
                    ))
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete Sticker", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(sticker.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applyChanges()
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Delete this sticker?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    store.delete(sticker)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var current: Sticker? {
        store.stickers.first { $0.id == sticker.id }
    }

    private func applyChanges() {
        if name != sticker.displayName {
            store.rename(sticker, to: name)
        }
        if category.rawValue != sticker.category {
            store.updateCategory(sticker, to: category)
        }
    }
}

#Preview {
    StickerDetailView(sticker: Sticker(fileName: "demo.gif", displayName: "Demo"))
        .environmentObject(StickerStore())
}
