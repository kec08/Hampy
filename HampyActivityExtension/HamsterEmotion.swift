import Foundation

enum HamsterEmotion: String, Codable, CaseIterable {
    case happy
    case hungry
    case tired
    case upset
    case eating
    case angry
    case annoyed
    case blank
    case bored
    case curious

    var displayName: String {
        switch self {
        case .happy: "행복"
        case .hungry: "배고픔"
        case .tired: "피곤함"
        case .upset: "삐짐"
        case .eating: "먹는 중"
        case .angry: "화남"
        case .annoyed: "짜증"
        case .blank: "멍"
        case .bored: "심심"
        case .curious: "호기심"
        }
    }

    var emoji: String {
        switch self {
        case .happy: "😊"
        case .hungry: "🥺"
        case .tired: "😴"
        case .upset: "😤"
        case .eating: "🐹"
        case .angry: "😡"
        case .annoyed: "😒"
        case .blank: "😶"
        case .bored: "😑"
        case .curious: "🤔"
        }
    }
}
