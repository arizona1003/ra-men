import SwiftUI
import CoreLocation

struct SearchView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var location = LocationManager()

    @State private var query: String = ""
    @State private var selectedGenre: Genre?
    @State private var selectedPrefecture: String = ""
    @State private var wantsOnly: Bool = false
    @State private var sort: AppStore.SortOrder = .rating
    @State private var displayMode: DisplayMode = .list
    @State private var navShop: Shop?

    enum DisplayMode: String, CaseIterable, Identifiable {
        case list = "リスト"
        case map  = "地図"
        var id: String { rawValue }
    }

    init(initialGenre: Genre? = nil) {
        _selectedGenre = State(initialValue: initialGenre)
    }

    private var results: [Shop] {
        store.filteredShops(
            query: query,
            genre: selectedGenre,
            prefecture: selectedPrefecture.isEmpty ? nil : selectedPrefecture,
            wantsOnly: wantsOnly,
            sort: sort,
            userLocation: location.currentLocation
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                if displayMode == .list {
                    listContent
                } else {
                    mapContent
                }
            }
            .background(Theme.background)
            .navigationTitle("検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "店名・エリア・ジャンル")
            .navigationDestination(item: $navShop) { shop in
                ShopDetailView(shop: shop)
            }
            .onChange(of: sort) { _, newValue in
                if newValue == .distance {
                    location.request()
                }
            }
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if results.isEmpty {
            emptyState
        } else {
            List {
                Section {
                    Text("\(results.count) 件のラーメン店")
                        .font(.caption)
                        .foregroundStyle(Theme.textSub)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                ForEach(results) { shop in
                    NavigationLink {
                        ShopDetailView(shop: shop)
                    } label: {
                        ShopRow(shop: shop, userLocation: location.currentLocation)
                    }
                    .listRowBackground(Theme.surface)
                }
            }
            .listStyle(.plain)
            .background(Theme.background)
            .scrollContentBackground(.hidden)
        }
    }

    private var mapContent: some View {
        ZStack(alignment: .top) {
            ShopsMapView(
                shops: results,
                userLocation: location.currentLocation,
                onSelect: { shop in navShop = shop }
            )
            if results.isEmpty {
                Text("該当するラーメン店がありません")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Theme.surface)
                    .clipShape(Capsule())
                    .padding(.top, 14)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            } else {
                Text("\(results.count) 店舗を表示中")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Theme.surface)
                    .clipShape(Capsule())
                    .padding(.top, 14)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }
        }
        .onAppear {
            if location.authorizationStatus == .notDetermined {
                location.request()
            }
        }
    }

    private var filterBar: some View {
        VStack(spacing: 10) {
            Picker("表示", selection: $displayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip(label: "すべて", emoji: "🍜", selected: selectedGenre == nil) {
                        selectedGenre = nil
                    }
                    ForEach(Genre.allCases) { g in
                        chip(label: g.rawValue, emoji: g.emoji, selected: selectedGenre == g) {
                            selectedGenre = (selectedGenre == g) ? nil : g
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack(spacing: 8) {
                Menu {
                    Button("すべてのエリア") { selectedPrefecture = "" }
                    Divider()
                    ForEach(store.allPrefectures, id: \.self) { pref in
                        Button(pref) { selectedPrefecture = pref }
                    }
                } label: {
                    filterPill(
                        icon: "mappin.and.ellipse",
                        text: selectedPrefecture.isEmpty ? "すべてのエリア" : selectedPrefecture
                    )
                }

                Menu {
                    ForEach(AppStore.SortOrder.allCases) { order in
                        Button(order.rawValue) { sort = order }
                    }
                } label: {
                    filterPill(icon: "arrow.up.arrow.down", text: sort.rawValue)
                }

                Toggle(isOn: $wantsOnly) {
                    Label("行きたい", systemImage: "bookmark")
                        .font(.caption.weight(.bold))
                }
                .toggleStyle(.button)
                .tint(Theme.accent)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(Theme.surface)
    }

    private func chip(label: String, emoji: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                Text(label).font(.caption.weight(.bold))
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(selected ? Theme.primary : Theme.surfaceMuted)
            .foregroundStyle(selected ? .white : Theme.text)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func filterPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption.weight(.semibold))
            Image(systemName: "chevron.down").font(.system(size: 9))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Theme.surfaceMuted)
        .foregroundStyle(Theme.text)
        .clipShape(Capsule())
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("🔍").font(.system(size: 50))
            Text("該当するラーメン店が見つかりません")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.text)
            Text("条件を変更して再度お試しください")
                .font(.caption)
                .foregroundStyle(Theme.textSub)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SearchView().environmentObject(AppStore(preview: true))
}
