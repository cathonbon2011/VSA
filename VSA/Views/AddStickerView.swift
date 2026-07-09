import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddStickerView: View {
    @EnvironmentObject private var store: StickerStore
    @Environment(\.dismiss) private var dismiss

    @State private var pendingData: Data?
    @State private var pendingName = "Sticker"
    @State private var category: StickerCategory = .uncategorized
    @State private var photosSelection: PhotosPickerItem?
    @State private var showingFileImporter = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Source") {
                    Button {
                        showingFileImporter = true
                    } label: {
                        Label("Choose GIF from Files", systemImage: "folder")
                    }

                    PhotosPicker(selection: $photosSelection, matching: .images) {
                        Label("Choose from Photos", systemImage: "photo.on.rectangle")
                    }
                }

                if let pendingData {
                    Section("Preview") {
                        HStack {
                            Spacer()
                            GIFPreview(data: pendingData)
                                .frame(width: 140, height: 140)
                            Spacer()
                        }
                    }

                    Section("Details") {
                        TextField("Name", text: $pendingName)
                        Picker("Category", selection: $category) {
                            ForEach(StickerCategory.assignable) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Sticker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(pendingData == nil)
                }
            }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.gif]) { result in
                handleFileImport(result)
            }
            .onChange(of: photosSelection) { _, newValue in
                loadFromPhotos(newValue)
            }
        }
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                pendingData = try Data(contentsOf: url)
                pendingName = url.deletingPathExtension().lastPathComponent
                errorMessage = nil
            } catch {
                errorMessage = "Couldn't read that file."
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func loadFromPhotos(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        pendingData = data
                        pendingName = item.itemIdentifier ?? "Sticker"
                        errorMessage = nil
                    }
                } else {
                    await MainActor.run { errorMessage = "That item couldn't be loaded as a GIF." }
                }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
        }
    }

    private func save() {
        guard let pendingData else { return }
        do {
            try store.addSticker(data: pendingData, suggestedName: pendingName, category: category)
            dismiss()
        } catch {
            errorMessage = "Couldn't save sticker: \(error.localizedDescription)"
        }
    }
}

private struct GIFPreview: View {
    let data: Data

    var body: some View {
        if let temp = try? Self.writeTemp(data) {
            GIFImageView(url: temp)
        } else {
            Image(systemName: "photo")
        }
    }

    static func writeTemp(_ data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".gif")
        try data.write(to: url)
        return url
    }
}

#Preview {
    AddStickerView()
        .environmentObject(StickerStore())
}
