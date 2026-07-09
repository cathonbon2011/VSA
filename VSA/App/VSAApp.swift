import SwiftUI

@main
struct VSAApp: App {
    @StateObject private var store = StickerStore()
    @State private var showingAddSticker = false

    var body: some Scene {
        WindowGroup {
            ContentView(showingAddSticker: $showingAddSticker)
                .environmentObject(store)
                .onOpenURL { url in
                    handle(url)
                }
        }
    }

    private func handle(_ url: URL) {
        guard url.scheme == "vsa" else { return }
        if url.host == "add-sticker" {
            showingAddSticker = true
        }
    }
}
