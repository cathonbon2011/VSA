import SwiftUI

struct KeyboardRootView: View {
    let showsNextKeyboardButton: Bool
    let onStickerTapped: (Sticker) -> Void
    let onNextKeyboard: () -> Void
    let onOpenHostApp: () -> Void
    let onBackspace: () -> Void

    @State private var stickers: [Sticker] = StickerFileStore.shared.loadIndex()
    @State private var toastText: String?

    private let columns = [GridItem(.adaptive(minimum: 72, maximum: 96), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if stickers.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(stickers) { sticker in
                            Button {
                                onStickerTapped(sticker)
                                showToast("Copied — paste it in your message")
                            } label: {
                                GIFImageView(url: sticker.fileURL)
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemFill)))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                }
            }

            if let toastText {
                Text(toastText)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(.systemGray5)))
                    .padding(.bottom, 6)
                    .transition(.opacity)
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            stickers = StickerFileStore.shared.loadIndex()
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            if showsNextKeyboardButton {
                Button(action: onNextKeyboard) {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .medium))
                }
            }

            Button(action: onOpenHostApp) {
                Label("Add Stickers", systemImage: "plus.circle")
                    .font(.caption.weight(.medium))
            }

            Spacer()

            Button(action: onBackspace) {
                Image(systemName: "delete.left")
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "photo.stack")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("No stickers yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Open VSA to add stickers", action: onOpenHostApp)
                .font(.caption)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func showToast(_ text: String) {
        withAnimation { toastText = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { toastText = nil }
        }
    }
}
