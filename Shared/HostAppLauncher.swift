import UIKit

/// App extensions can't call `UIApplication.shared.open(_:)` directly (UIApplication is
/// unavailable there), but walking the responder chain to find `openURL:` still works.
enum HostAppLauncher {
    static let addStickerURL = URL(string: "vsa://add-sticker")!

    static func open(_ url: URL, from responder: UIResponder) {
        var current: UIResponder? = responder
        let selector = sel_registerName("openURL:")
        while let candidate = current {
            if candidate.responds(to: selector) {
                candidate.perform(selector, with: url)
                return
            }
            current = candidate.next
        }
    }
}
