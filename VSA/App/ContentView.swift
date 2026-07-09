import SwiftUI

struct ContentView: View {
    @Binding var showingAddSticker: Bool

    var body: some View {
        TabView {
            StickerLibraryView(showingAddSticker: $showingAddSticker)
                .tabItem { Label("Stickers", systemImage: "square.grid.2x2.fill") }

            KeyboardSetupView()
                .tabItem { Label("Keyboard", systemImage: "keyboard") }
        }
    }
}

#Preview {
    ContentView(showingAddSticker: .constant(false))
        .environmentObject(StickerStore())
}
