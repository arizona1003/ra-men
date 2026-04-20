import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }

            RankingView()
                .tabItem {
                    Label("ランキング", systemImage: "trophy.fill")
                }

            MyPageView()
                .tabItem {
                    Label("マイページ", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(Theme.primary)
    }
}

#Preview {
    ContentView().environmentObject(AppStore(preview: true))
}
