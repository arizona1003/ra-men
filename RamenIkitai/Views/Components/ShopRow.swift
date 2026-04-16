import SwiftUI
import CoreLocation

struct ShopRow: View {
    let shop: Shop
    var userLocation: CLLocation? = nil
    @EnvironmentObject private var store: AppStore

    private var distanceText: String? {
        guard let userLocation else { return nil }
        return LocationManager.formatDistance(shop.distance(from: userLocation))
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                LinearGradient(
                    colors: [shop.genre.color.opacity(0.85), shop.genre.color.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Text("🍜").font(.system(size: 28))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(shop.genre.rawValue)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(shop.genre.color.opacity(0.12))
                        .foregroundStyle(shop.genre.color)
                        .clipShape(Capsule())
                    Text("\(shop.prefecture) \(shop.area)")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSub)
                        .lineLimit(1)
                    if let distanceText {
                        Text("・\(distanceText)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.primary)
                    }
                }
                Text(shop.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(String(format: "%.1f", store.averageRating(for: shop.id)))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Theme.primary)
                    RatingStars(rating: store.averageRating(for: shop.id), size: 11)
                    Text("・\(store.reviewCount(for: shop.id))件")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSub)
                }
            }

            Spacer(minLength: 0)

            if store.isWanted(shop) {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Theme.accent)
                    .font(.system(size: 16))
            }
        }
        .padding(.vertical, 4)
    }
}
