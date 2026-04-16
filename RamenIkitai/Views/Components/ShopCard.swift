import SwiftUI

struct ShopCard: View {
    let shop: Shop
    @EnvironmentObject private var store: AppStore

    private var rating: Double { store.averageRating(for: shop.id) }
    private var reviewCount: Int { store.reviewCount(for: shop.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [shop.genre.color.opacity(0.85), shop.genre.color.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                Text("🍜")
                    .font(.system(size: 56))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(spacing: 6) {
                    Text(shop.genre.emoji)
                    Text(shop.genre.rawValue)
                        .font(.caption2.weight(.bold))
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.black.opacity(0.55))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(10)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(Theme.text)

                Text("\(shop.prefecture) \(shop.area)")
                    .font(.caption)
                    .foregroundStyle(Theme.textSub)

                HStack(spacing: 6) {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Theme.primary)
                    RatingStars(rating: rating, size: 12)
                    Text("・ラー活\(reviewCount)")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSub)
                }
            }
            .padding(.top, 10)
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
