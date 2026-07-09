import SwiftUI

struct CategoryTabBar: View {
    @Binding var selected: StickerCategory

    private var categories: [StickerCategory] {
        [.all, .favorites] + StickerCategory.assignable
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    Button {
                        selected = category
                    } label: {
                        Label(category.rawValue, systemImage: category.systemImage)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(selected == category ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                            .foregroundStyle(selected == category ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    CategoryTabBar(selected: .constant(.all))
}
