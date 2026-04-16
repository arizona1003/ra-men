import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab: Tab = .reviews
    @State private var showResetConfirm = false

    enum Tab: String, CaseIterable, Identifiable {
        case reviews = "ラー活履歴"
        case wants   = "行きたい"
        case settings = "設定"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    tabBar
                    switch selectedTab {
                    case .reviews:  reviewsPanel
                    case .wants:    wantsPanel
                    case .settings: settingsPanel
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog("すべてのデータをリセットしますか？",
                                isPresented: $showResetConfirm,
                                titleVisibility: .visible) {
                Button("リセットする", role: .destructive) { store.resetAll() }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("ラー活・行きたいリスト・プロフィールがすべて削除されます。")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.white.opacity(0.15))
                Text("🍜").font(.system(size: 38))
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(store.userName)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
                HStack(spacing: 20) {
                    stat("\(store.totalReviews)", "ラー活")
                    stat("\(store.totalWants)", "行きたい")
                    stat(store.totalReviews > 0 ? String(format: "%.1f", store.myAverageRating) : "-",
                         "平均")
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Theme.primary, Theme.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 16, weight: .heavy)).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(.white.opacity(0.85))
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: selectedTab == tab ? .heavy : .medium))
                            .foregroundStyle(selectedTab == tab ? Theme.primary : Theme.textSub)
                        Rectangle()
                            .fill(selectedTab == tab ? Theme.primary : .clear)
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Theme.surface)
    }

    @ViewBuilder
    private var reviewsPanel: some View {
        if store.myReviewsSorted.isEmpty {
            emptyView(
                emoji: "📝",
                title: "まだラー活の記録がありません",
                subtitle: "お店を見つけて、最初の一杯を記録しよう"
            )
        } else {
            LazyVStack(spacing: 10) {
                ForEach(store.myReviewsSorted) { review in
                    if let shop = store.shop(by: review.shopID) {
                        NavigationLink {
                            ShopDetailView(shop: shop)
                        } label: {
                            MyReviewCard(review: review, shop: shop)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("削除", role: .destructive) { store.removeReview(review) }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var wantsPanel: some View {
        if store.wantedShops.isEmpty {
            emptyView(
                emoji: "🔖",
                title: "行きたいリストが空です",
                subtitle: "気になるラーメン店をブックマークしよう"
            )
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(store.wantedShops) { shop in
                    NavigationLink {
                        ShopDetailView(shop: shop)
                    } label: {
                        ShopCard(shop: shop)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var settingsPanel: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ユーザー名").font(.caption.weight(.bold)).foregroundStyle(Theme.textSub)
                TextField("ニックネーム", text: $store.userName)
                    .textFieldStyle(.roundedBorder)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("好きなジャンル・メモ").font(.caption.weight(.bold)).foregroundStyle(Theme.textSub)
                TextField("例：家系、二郎系", text: $store.favoriteGenreNote)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                store.saveProfile()
            } label: {
                Text("保存する")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Divider().padding(.vertical, 4)

            Button {
                showResetConfirm = true
            } label: {
                Text("すべてのデータをリセット")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(Theme.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.primary, lineWidth: 1)
                    )
            }

            Text("本アプリはデモ版です。掲載されている店舗情報はサンプルデータです。")
                .font(.caption2)
                .foregroundStyle(Theme.textSub)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(20)
    }

    private func emptyView(emoji: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Text(emoji).font(.system(size: 50))
            Text(title).font(.system(size: 15, weight: .bold))
            Text(subtitle).font(.caption).foregroundStyle(Theme.textSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct MyReviewCard: View {
    let review: Review
    let shop: Shop

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(shop.genre.emoji)
                Text(shop.name).font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.primary)
                Spacer()
                Text(review.visitedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundStyle(Theme.textSub)
            }
            HStack(spacing: 6) {
                RatingStars(rating: Double(review.overallRating), size: 12)
                Text(review.menu).font(.caption2).foregroundStyle(Theme.textSub)
            }
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.caption)
                    .foregroundStyle(Theme.text)
                    .lineLimit(3)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    MyPageView().environmentObject(AppStore(preview: true))
}
