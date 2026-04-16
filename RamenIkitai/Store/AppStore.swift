import Foundation
import SwiftUI
import CoreLocation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var shops: [Shop] = []
    @Published private(set) var reviews: [Review] = []
    @Published private(set) var wantIDs: Set<UUID> = []
    @Published var userName: String = "ラーメン好き"
    @Published var favoriteGenreNote: String = ""

    private let reviewsKey   = "ri.reviews.v1"
    private let wantsKey     = "ri.wants.v1"
    private let userNameKey  = "ri.userName.v1"
    private let favGenreKey  = "ri.favGenreNote.v1"

    init(preview: Bool = false) {
        self.shops = SampleData.makeShops()
        load()
        if preview && reviews.isEmpty {
            reviews = SampleData.makeReviews(for: shops)
        }
    }

    // MARK: - Persistence

    private func load() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: reviewsKey),
           let decoded = try? JSONDecoder.isoDecoder.decode([Review].self, from: data) {
            self.reviews = decoded
        } else {
            self.reviews = SampleData.makeReviews(for: shops)
        }

        if let data = defaults.data(forKey: wantsKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            self.wantIDs = Set(decoded)
        }

        if let name = defaults.string(forKey: userNameKey), !name.isEmpty {
            self.userName = name
        }
        self.favoriteGenreNote = defaults.string(forKey: favGenreKey) ?? ""
    }

    private func saveReviews() {
        if let data = try? JSONEncoder.isoEncoder.encode(reviews) {
            UserDefaults.standard.set(data, forKey: reviewsKey)
        }
    }

    private func saveWants() {
        if let data = try? JSONEncoder().encode(Array(wantIDs)) {
            UserDefaults.standard.set(data, forKey: wantsKey)
        }
    }

    func saveProfile() {
        UserDefaults.standard.set(userName, forKey: userNameKey)
        UserDefaults.standard.set(favoriteGenreNote, forKey: favGenreKey)
    }

    // MARK: - Want list

    func isWanted(_ shop: Shop) -> Bool {
        wantIDs.contains(shop.id)
    }

    func toggleWant(_ shop: Shop) {
        if wantIDs.contains(shop.id) {
            wantIDs.remove(shop.id)
        } else {
            wantIDs.insert(shop.id)
        }
        saveWants()
    }

    var wantedShops: [Shop] {
        shops.filter { wantIDs.contains($0.id) }
    }

    // MARK: - Reviews

    func addReview(_ review: Review) {
        reviews.append(review)
        saveReviews()
    }

    func removeReview(_ review: Review) {
        reviews.removeAll { $0.id == review.id }
        saveReviews()
    }

    func reviews(for shopID: UUID) -> [Review] {
        reviews
            .filter { $0.shopID == shopID }
            .sorted { $0.visitedAt > $1.visitedAt }
    }

    var myReviewsSorted: [Review] {
        reviews.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Aggregates

    func averageRating(for shopID: UUID) -> Double {
        let scoped = reviews.filter { $0.shopID == shopID }
        guard !scoped.isEmpty else { return 0 }
        let total = scoped.reduce(0) { $0 + $1.overallRating }
        return Double(total) / Double(scoped.count)
    }

    func reviewCount(for shopID: UUID) -> Int {
        reviews.filter { $0.shopID == shopID }.count
    }

    func shop(by id: UUID) -> Shop? {
        shops.first { $0.id == id }
    }

    var totalReviews: Int { reviews.count }
    var totalWants: Int { wantIDs.count }
    var totalShops: Int { shops.count }

    var myAverageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.overallRating }
        return Double(total) / Double(reviews.count)
    }

    // MARK: - Search / Ranking

    enum SortOrder: String, CaseIterable, Identifiable {
        case rating     = "評価順"
        case reviews    = "ラー活数"
        case distance   = "近い順"
        case name       = "名前順"
        var id: String { rawValue }
    }

    func filteredShops(
        query: String = "",
        genre: Genre? = nil,
        prefecture: String? = nil,
        wantsOnly: Bool = false,
        sort: SortOrder = .rating,
        userLocation: CLLocation? = nil
    ) -> [Shop] {
        var list = shops

        if wantsOnly {
            list = list.filter { wantIDs.contains($0.id) }
        }
        if let genre {
            list = list.filter { $0.genre == genre }
        }
        if let prefecture, !prefecture.isEmpty {
            list = list.filter { $0.prefecture == prefecture }
        }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            list = list.filter { shop in
                shop.name.localizedCaseInsensitiveContains(trimmed) ||
                shop.nameKana.localizedCaseInsensitiveContains(trimmed) ||
                shop.area.localizedCaseInsensitiveContains(trimmed) ||
                shop.prefecture.localizedCaseInsensitiveContains(trimmed) ||
                shop.genre.rawValue.localizedCaseInsensitiveContains(trimmed) ||
                shop.description.localizedCaseInsensitiveContains(trimmed)
            }
        }

        switch sort {
        case .rating:
            list.sort {
                let a = averageRating(for: $0.id)
                let b = averageRating(for: $1.id)
                if a == b {
                    return reviewCount(for: $0.id) > reviewCount(for: $1.id)
                }
                return a > b
            }
        case .reviews:
            list.sort { reviewCount(for: $0.id) > reviewCount(for: $1.id) }
        case .distance:
            if let userLocation {
                list.sort { $0.distance(from: userLocation) < $1.distance(from: userLocation) }
            }
        case .name:
            list.sort { $0.nameKana < $1.nameKana }
        }
        return list
    }

    var allPrefectures: [String] {
        Array(Set(shops.map(\.prefecture))).sorted()
    }

    func genreCount(_ genre: Genre) -> Int {
        shops.filter { $0.genre == genre }.count
    }

    // MARK: - Reset

    func resetAll() {
        reviews.removeAll()
        wantIDs.removeAll()
        userName = "ラーメン好き"
        favoriteGenreNote = ""
        let d = UserDefaults.standard
        d.removeObject(forKey: reviewsKey)
        d.removeObject(forKey: wantsKey)
        d.removeObject(forKey: userNameKey)
        d.removeObject(forKey: favGenreKey)
    }
}

private extension JSONEncoder {
    static var isoEncoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
}

private extension JSONDecoder {
    static var isoDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}
