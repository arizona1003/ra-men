import SwiftUI

enum Genre: String, CaseIterable, Identifiable, Codable, Hashable {
    case shoyu       = "醤油"
    case miso        = "味噌"
    case shio        = "塩"
    case tonkotsu    = "豚骨"
    case iekei       = "家系"
    case jiro        = "二郎系"
    case tsukemen    = "つけ麺"
    case tantanmen   = "担々麺"
    case niboshi     = "煮干し"
    case abura       = "油そば"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .shoyu:     return "🍶"
        case .miso:      return "🌾"
        case .shio:      return "🧂"
        case .tonkotsu:  return "🐷"
        case .iekei:     return "🏠"
        case .jiro:      return "💪"
        case .tsukemen:  return "🥢"
        case .tantanmen: return "🌶️"
        case .niboshi:   return "🐟"
        case .abura:     return "🫒"
        }
    }

    var color: Color {
        switch self {
        case .shoyu:     return Color(red: 0.42, green: 0.23, blue: 0.10)
        case .miso:      return Color(red: 0.71, green: 0.40, blue: 0.11)
        case .shio:      return Color(red: 0.54, green: 0.63, blue: 0.71)
        case .tonkotsu:  return Color(red: 0.85, green: 0.77, blue: 0.68)
        case .iekei:     return Color(red: 0.30, green: 0.30, blue: 0.35)
        case .jiro:      return Color(red: 0.90, green: 0.70, blue: 0.20)
        case .tsukemen:  return Color(red: 0.60, green: 0.40, blue: 0.25)
        case .tantanmen: return Color(red: 0.85, green: 0.27, blue: 0.22)
        case .niboshi:   return Color(red: 0.40, green: 0.55, blue: 0.65)
        case .abura:     return Color(red: 0.70, green: 0.55, blue: 0.20)
        }
    }
}
