import SwiftUI
import UIKit

/// Renders an animated GIF from a shared-container file URL.
struct GIFImageView: UIViewRepresentable {
    let url: URL
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.contentMode = contentMode
        guard let data = try? Data(contentsOf: url) else {
            uiView.image = nil
            return
        }
        uiView.image = GIFDecoder.animatedImage(data: data)
    }
}

struct GIFThumbnail: View {
    let sticker: Sticker
    var cornerRadius: CGFloat = 14

    var body: some View {
        GIFImageView(url: sticker.fileURL)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.secondarySystemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
