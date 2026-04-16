import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: AppStore

    @State private var query: String = ""
    @State private var selectedGenre: Genre?
    @State private var selectedPrefecture: String = ""
    @State private var wantsOnly: Bool = false
    @State private var sort: AppStore.SortOrder = .rating

    init(initialGenre: Genre? = nil) {
        _selectedGenre = State(initialValue: initialGenre)
    }

    private var results: [Shop] {
        store.filteredShops(
            query: query,
            genre: selectedGenre,
            prefecture: selectedPrefecture.isEmpty ? nil : selectedPrefecture,
            wantsOnly: wantsOnly,
            sort: sort
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
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
                                ShopRow(shop: shop)
                            }
                            .listRowBackground(Theme.surface)
                        }
                    }
                    .listStyle(.plain)
                    .background(Theme.background)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.background)
            .navigationTitle("検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "店名・エリア・ジャンル")
        }
    }

    private var filterBar: some View {
        VStack(spacing: 10) {
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
