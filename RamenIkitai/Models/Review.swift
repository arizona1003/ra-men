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
    var photoFilenames: [String]
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
        photoFilenames: [String] = [],
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
        self.photoFilenames = photoFilenames
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, shopID, visitedAt, menu, overallRating
        case soupScore, noodleScore, toppingScore
        case comment, photoFilenames, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.shopID = try c.decode(UUID.self, forKey: .shopID)
        self.visitedAt = try c.decode(Date.self, forKey: .visitedAt)
        self.menu = try c.decode(String.self, forKey: .menu)
        self.overallRating = try c.decode(Int.self, forKey: .overallRating)
        self.soupScore = try c.decode(Int.self, forKey: .soupScore)
        self.noodleScore = try c.decode(Int.self, forKey: .noodleScore)
        self.toppingScore = try c.decode(Int.self, forKey: .toppingScore)
        self.comment = try c.decode(String.self, forKey: .comment)
        self.photoFilenames = (try? c.decode([String].self, forKey: .photoFilenames)) ?? []
        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
