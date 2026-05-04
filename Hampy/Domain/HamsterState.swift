import Foundation

struct HamsterState: Codable {
    var hunger: Double
    var happiness: Double
    var energy: Double
    var lastUpdated: Date
    var feedTimestamps: [Date] // 먹이 시간 기록 (1시간 5개 제한)

    static let initial = HamsterState(
        hunger: 80,
        happiness: 80,
        energy: 80,
        lastUpdated: .now,
        feedTimestamps: []
    )

    /// 현재 감정 상태 계산
    var currentEmotion: HamsterEmotion {
        if hunger < 30 { return .hungry }
        if energy < 30 { return .tired }
        if happiness < 20 { return .upset }
        if hunger > 60 && happiness > 60 { return .happy }
        return .happy
    }
}
