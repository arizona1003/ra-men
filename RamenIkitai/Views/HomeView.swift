import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    private var featured: [Shop] {
        store.filteredShops(sort: .rating).prefix(6).map { $0 }
    }

    private var recentReviews: [Review] {
        Array(store.myReviewsSorted.prefix(3))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    genreSection
                    featuredSection
                    recentReviewSection
                    featureSection
                }
                .padding(.bottom, 30)
            }
            .background(Theme.background)
            .navigationTitle("ラーメンイキタイ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primary, Theme.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 12) {
                Text("🍜")
                    .font(.system(size: 64))
                Text("今日、ラーメンを食べに行こう。")
                    .font(.system(size: 22, weight: .heavy))
                    .multilineTextAlignment(.center)
                Text("全国のラーメン店を検索・記録できる\nラーメン好きのためのアプリ")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .opacity(0.9)

                HStack(spacing: 32) {
                    statView(value: store.totalShops, label: "店舗")
                    statView(value: store.totalReviews, label: "ラー活")
                    statView(value: store.totalWants, label: "行きたい")
                }
                .padding(.top, 8)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
    }

    private func statView(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 26, weight: .heavy))
            Text(label)
                .font(.caption2)
                .opacity(0.85)
        }
    }

    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("ジャンルから探す")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                ForEach(Genre.allCases) { genre in
                    NavigationLink {
                        SearchView(initialGenre: genre)
                    } label: {
                        VStack(spacing: 6) {
                            Text(genre.emoji).font(.system(size: 32))
                            Text(genre.rawValue)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("\(store.genreCount(genre))店")
                                .font(.caption2)
                                .foregroundStyle(Theme.textSub)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("注目のラーメン店")
                Spacer()
                NavigationLink("ランキング →") {
                    RankingView()
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featured) { shop in
                        NavigationLink {
                            ShopDetailView(shop: shop)
                        } label: {
                            ShopCard(shop: shop)
                                .frame(width: 240)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var recentReviewSection: some View {
        if !recentReviews.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("最新のラー活")
                VStack(spacing: 10) {
                    ForEach(recentReviews) { review in
                        if let shop = store.shop(by: review.shopID) {
                            NavigationLink {
                                ShopDetailView(shop: shop)
                            } label: {
                                ActivityRow(review: review, shop: shop)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var featureSection: some View {
        VStack(spacing: 16) {
            Text("ラーメンイキタイでできること")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.top, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featureCard(icon: "magnifyingglass", title: "検索", desc: "ジャンル・エリア・評価で絞込")
                featureCard(icon: "square.and.pencil", title: "ラー活", desc: "食べた一杯を記録")
                featureCard(icon: "bookmark.fill", title: "行きたい", desc: "次の一杯を計画")
                featureCard(icon: "trophy.fill", title: "ランキング", desc: "人気店をチェック")
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.dark)
    }

    private func featureCard(icon: String, title: String, desc: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(Theme.accent)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Text(desc)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .heavy))
            .padding(.leading, 8)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Theme.primary)
                    .frame(width: 4, height: 20)
            }
    }
}

struct ActivityRow: View {
    let review: Review
    let shop: Shop

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(shop.genre.color.opacity(0.18))
                Text(shop.genre.emoji).font(.system(size: 22))
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(shop.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.primary)
                    Spacer()
                    Text(review.visitedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(Theme.textSub)
                }
                HStack(spacing: 6) {
                    RatingStars(rating: Double(review.overallRating), size: 12)
                    Text(review.menu)
                        .font(.caption2)
                        .foregroundStyle(Theme.textSub)
                        .lineLimit(1)
                }
                if !review.comment.isEmpty {
                    Text(review.comment)
                        .font(.caption)
                        .foregroundStyle(Theme.text)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
        }
        .padding(12)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    HomeView().environmentObject(AppStore(preview: true))
}
