import Foundation

struct Shop: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var nameKana: String
    var genre: Genre
    var prefecture: String
    var area: String
    var address: String
    var nearestStation: String
    var openHours: String
    var closedDay: String
    var priceRange: String
    var hasParking: Bool
    var acceptsReservation: Bool
    var offersKaedama: Bool
    var description: String
    var menus: [Menu]
    var noodleThickness: NoodleThickness
    var soupRichness: SoupRichness

    struct Menu: Codable, Hashable, Identifiable {
        var id: UUID = UUID()
        var name: String
        var price: Int
        var isSignature: Bool = false
    }

    enum NoodleThickness: String, Codable, CaseIterable {
        case thin = "細麺"
        case medium = "中太麺"
        case thick = "太麺"
        case extraThick = "極太麺"
    }

    enum SoupRichness: String, Codable, CaseIterable {
        case light = "あっさり"
        case medium = "ふつう"
        case rich = "こってり"
        case extraRich = "ガツン系"
    }
}
