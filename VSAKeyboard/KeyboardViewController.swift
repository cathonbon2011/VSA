import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    private var hostingController: UIHostingController<KeyboardRootView>?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        installHostingController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hostingController?.rootView = makeRootView()
    }

    override func textWillChange(_ textInput: UITextInput?) {}
    override func textDidChange(_ textInput: UITextInput?) {}

    private func installHostingController() {
        let rootView = makeRootView()
        let hosting = UIHostingController(rootView: rootView)
        hostingController = hosting

        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)

        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 300)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint
    }

    private func makeRootView() -> KeyboardRootView {
        KeyboardRootView(
            showsNextKeyboardButton: needsInputModeSwitchKey,
            onStickerTapped: { [weak self] sticker in
                self?.copySticker(sticker)
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            onOpenHostApp: { [weak self] in
                guard let self else { return }
                HostAppLauncher.open(HostAppLauncher.addStickerURL, from: self)
            },
            onBackspace: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            }
        )
    }

    private func copySticker(_ sticker: Sticker) {
        guard let data = try? Data(contentsOf: sticker.fileURL) else { return }
        let pasteboard = UIPasteboard.general
        pasteboard.setItems([["com.compuserve.gif": data]], options: [
            .expirationDate: Date().addingTimeInterval(180)
        ])
    }
}
