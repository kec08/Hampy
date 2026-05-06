import Foundation

enum HamsterEmotion: String, Codable, CaseIterable {
    case happy
    case hungry
    case tired
    case upset
    case eating

    var displayName: String {
        switch self {
        case .happy: "행복"
        case .hungry: "배고픔"
        case .tired: "피곤함"
        case .upset: "삐짐"
        case .eating: "먹는 중"
        }
    }

    var emoji: String {
        switch self {
        case .happy: "😊"
        case .hungry: "🥺"
        case .tired: "😴"
        case .upset: "😤"
        case .eating: "🐹"
        }
    }
}
