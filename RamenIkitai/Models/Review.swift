import Foundation

struct Review: Identifiable, Codable, Hashable {
    let id: UUID
    var shopID: UUID
    var visitedAt: Date
    var menu: String
    var overallRating: Int
    var soupScore: Int
    var noodleScore: Int
    var toppingScore: Int
    var comment: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        shopID: UUID,
        visitedAt: Date = Date(),
        menu: String,
        overallRating: Int,
        soupScore: Int = 3,
        noodleScore: Int = 3,
        toppingScore: Int = 3,
        comment: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.shopID = shopID
        self.visitedAt = visitedAt
        self.menu = menu
        self.overallRating = overallRating
        self.soupScore = soupScore
        self.noodleScore = noodleScore
        self.toppingScore = toppingScore
        self.comment = comment
        self.createdAt = createdAt
    }
}
