import SwiftUI
import UIKit

struct KeyboardSetupView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "keyboard.badge.ellipsis")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.accentColor)
                        Text("Use your stickers anywhere")
                            .font(.title3.bold())
                        Text("Enable the VSA Keyboard to browse your GIF stickers from any app. Tap a sticker to copy it, then paste it into your message.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Setup steps") {
                    StepRow(number: 1, text: "Open the Settings app")
                    StepRow(number: 2, text: "Go to General → Keyboard → Keyboards")
                    StepRow(number: 3, text: "Tap \"Add New Keyboard…\" and choose VSA")
                    StepRow(number: 4, text: "Tap VSA Keyboard again and enable \"Allow Full Access\"")
                }

                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open Settings", systemImage: "gear")
                    }
                }

                Section("Why Full Access?") {
                    Text("Full Access lets the keyboard read your saved stickers and copy the tapped GIF to the clipboard. VSA never sends your data over the network.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Keyboard")
        }
    }
}

private struct StepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor.opacity(0.15)))
                .foregroundStyle(Color.accentColor)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    KeyboardSetupView()
}
