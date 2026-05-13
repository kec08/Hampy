import Foundation

struct HamsterState: Codable {
    var hunger: Double
    var happiness: Double
    var energy: Double
    var lastUpdated: Date

    // 먹이 시스템 (1시간마다 5개 지급, 최대 20개)
    var feedStock: Int
    var lastRefillDate: Date

    // 레벨 시스템
    var level: Int
    var experience: Double

    static let initial = HamsterState(
        hunger: 80,
        happiness: 80,
        energy: 80,
        lastUpdated: .now,
        feedStock: 10,
        lastRefillDate: .now,
        level: 1,
        experience: 0
    )

    /// 경과 시간에 따라 먹이 보충
    mutating func refillFeedStock() {
        let hoursPassed = Int(Date.now.timeIntervalSince(lastRefillDate) / 3600)
        guard hoursPassed > 0 else { return }
        let added = hoursPassed * 5
        feedStock = min(20, feedStock + added)
        lastRefillDate = lastRefillDate.addingTimeInterval(Double(hoursPassed) * 3600)
    }

    /// 현재 레벨의 필요 경험치 (50, 100, 150, 200, 250, ...)
    var experienceToNext: Double {
        Double(level) * 50
    }

    /// 현재 감정 상태 계산
    var currentEmotion: HamsterEmotion {
        if happiness < 10 { return .angry }
        if hunger < 15 && happiness < 30 { return .angry }
        if hunger < 30 { return .hungry }
        if energy < 20 { return .tired }
        if happiness < 20 { return .upset }
        if happiness < 35 { return .annoyed }
        if happiness < 50 && energy > 30 { return .bored }
        if hunger > 40 && hunger < 65 && happiness > 40 && happiness < 65 { return .blank }
        if energy > 70 && happiness > 50 && happiness < 75 { return .curious }
        if hunger > 60 && happiness > 60 { return .happy }
        return .blank
    }

    /// 경험치 추가 + 레벨업 처리
    mutating func addExperience(_ amount: Double) {
        experience += amount
        while experience >= experienceToNext {
            experience -= experienceToNext
            level += 1
        }
    }
}
