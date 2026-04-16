import SwiftUI

struct ShopDetailView: View {
    let shop: Shop
    @EnvironmentObject private var store: AppStore
    @State private var showReviewForm = false

    private var rating: Double { store.averageRating(for: shop.id) }
    private var reviews: [Review] { store.reviews(for: shop.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                actionsBar
                aboutSection
                mapSection
                specSection
                menuSection
                reviewsSection
            }
            .padding(.bottom, 30)
        }
        .background(Theme.background)
        .navigationTitle(shop.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showReviewForm) {
            ReviewFormView(shop: shop)
        }
    }

    private var header: some View {
        ZStack {
            if let photoName = store.latestPhotoFilename(for: shop.id) {
                StoredPhotoView(filename: photoName)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                LinearGradient(
                    colors: [Color.black.opacity(0.2), Color.black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [shop.genre.color, Theme.dark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            VStack(spacing: 10) {
                if store.latestPhotoFilename(for: shop.id) == nil {
                    Text("🍜").font(.system(size: 84))
                }
                HStack(spacing: 6) {
                    Text(shop.genre.emoji)
                    Text(shop.genre.rawValue)
                        .font(.caption.weight(.bold))
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())

                Text(shop.name)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                Text(shop.nameKana)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                Text("\(shop.prefecture) \(shop.area)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 14) {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(Theme.accent)
                    RatingStars(rating: rating, size: 18, color: Theme.accent)
                    Text("・ラー活 \(reviews.count)件")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionsBar: some View {
        HStack(spacing: 10) {
            Button {
                showReviewForm = true
            } label: {
                Label("ラー活を記録", systemImage: "square.and.pencil")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button {
                store.toggleWant(shop)
            } label: {
                Label(
                    store.isWanted(shop) ? "行きたい登録済み" : "行きたい",
                    systemImage: store.isWanted(shop) ? "bookmark.fill" : "bookmark"
                )
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(store.isWanted(shop) ? Theme.accent : Theme.surfaceMuted)
                .foregroundStyle(store.isWanted(shop) ? Theme.text : Theme.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Theme.surface)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("この店について")
            Text(shop.description)
                .font(.system(size: 14))
                .foregroundStyle(Theme.text)

            Divider().padding(.vertical, 4)

            infoRow("住所", shop.address)
            infoRow("最寄駅", shop.nearestStation)
            infoRow("営業時間", shop.openHours)
            infoRow("定休日", shop.closedDay)
            infoRow("価格帯", shop.priceRange)
            infoRow("駐車場", shop.hasParking ? "あり" : "なし")
            infoRow("予約", shop.acceptsReservation ? "可" : "不可")
            infoRow("替え玉", shop.offersKaedama ? "あり" : "なし")
        }
        .padding(16)
        .background(Theme.surface)
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("地図")
            ShopMiniMapView(shop: shop, height: 180)
            Button {
                MapsLauncher.openInAppleMaps(shop)
            } label: {
                Label("Apple マップで経路を確認", systemImage: "map")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.surfaceMuted)
                    .foregroundStyle(Theme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Theme.surface)
    }

    private var specSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("一杯のスペック")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                specCard(label: "スープ", value: shop.soupRichness.rawValue)
                specCard(label: "麺", value: shop.noodleThickness.rawValue)
                specCard(label: "ジャンル", value: shop.genre.rawValue)
                specCard(label: "替え玉", value: shop.offersKaedama ? "あり" : "なし")
            }
        }
        .padding(16)
        .background(Theme.surfaceMuted)
    }

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("メニュー")
            VStack(spacing: 0) {
                ForEach(shop.menus) { menu in
                    HStack {
                        if menu.isSignature {
                            Text("看板")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.primary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        Text(menu.name)
                            .font(.system(size: 14))
                        Spacer()
                        Text(menu.price == 0 ? "-" : "¥\(menu.price)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.primary)
                    }
                    .padding(.vertical, 10)
                    if menu.id != shop.menus.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("ラー活（\(reviews.count)件）")
            if reviews.isEmpty {
                Text("まだラー活がありません。最初の一杯を記録しよう！")
                    .font(.caption)
                    .foregroundStyle(Theme.textSub)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(reviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.surfaceMuted)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .heavy))
            .padding(.leading, 8)
            .overlay(alignment: .leading) {
                Rectangle().fill(Theme.primary).frame(width: 4, height: 18)
            }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSub)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundStyle(Theme.text)
            Spacer()
        }
    }

    private func specCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.textSub)
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.menu)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text(review.visitedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSub)
            }
            HStack(spacing: 6) {
                RatingStars(rating: Double(review.overallRating), size: 13)
                Text("\(review.overallRating).0")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.primary)
            }
            HStack(spacing: 8) {
                scoreChip("スープ", review.soupScore)
                scoreChip("麺", review.noodleScore)
                scoreChip("具", review.toppingScore)
            }
            if !review.photoFilenames.isEmpty {
                PhotoThumbnailStrip(filenames: review.photoFilenames, size: 84)
                    .padding(.top, 2)
            }
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.caption)
                    .foregroundStyle(Theme.text)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func scoreChip(_ label: String, _ value: Int) -> some View {
        HStack(spacing: 3) {
            Text(label).font(.caption2).foregroundStyle(Theme.textSub)
            Text("\(value)").font(.caption2.weight(.bold))
        }
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Theme.surfaceMuted)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        ShopDetailView(shop: SampleData.makeShops()[0])
    }
    .environmentObject(AppStore(preview: true))
}
