import SwiftUI

struct RankingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedGenre: Genre?

    private var ranked: [Shop] {
        store.filteredShops(genre: selectedGenre, sort: .rating)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                genreTabs
                if ranked.isEmpty {
                    Spacer()
                    Text("データがありません")
                        .foregroundStyle(Theme.textSub)
                    Spacer()
                } else {
                    List {
                        ForEach(Array(ranked.enumerated()), id: \.element.id) { index, shop in
                            NavigationLink {
                                ShopDetailView(shop: shop)
                            } label: {
                                RankingRow(rank: index + 1, shop: shop)
                            }
                            .listRowBackground(Theme.surface)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .background(Theme.background)
            .navigationTitle("ランキング")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var genreTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                tab(label: "総合", selected: selectedGenre == nil) {
                    selectedGenre = nil
                }
                ForEach(Genre.allCases) { g in
                    tab(label: "\(g.emoji) \(g.rawValue)", selected: selectedGenre == g) {
                        selectedGenre = (selectedGenre == g) ? nil : g
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Theme.surface)
    }

    private func tab(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(selected ? Theme.primary : Theme.surfaceMuted)
                .foregroundStyle(selected ? .white : Theme.text)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct RankingRow: View {
    let rank: Int
    let shop: Shop
    @EnvironmentObject private var store: AppStore

    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 0.83, green: 0.69, blue: 0.22)
        case 2: return Color(red: 0.54, green: 0.54, blue: 0.54)
        case 3: return Color(red: 0.69, green: 0.41, blue: 0.12)
        default: return Theme.textSub
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(rankColor)
                .frame(width: 40)

            ZStack {
                Circle().fill(shop.genre.color.opacity(0.18))
                Text(shop.genre.emoji).font(.system(size: 28))
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(shop.name)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                Text("\(shop.prefecture) \(shop.area) ・ \(shop.genre.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSub)
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
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RankingView().environmentObject(AppStore(preview: true))
}
