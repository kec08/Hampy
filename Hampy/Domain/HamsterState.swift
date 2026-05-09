import Foundation

struct HamsterState: Codable {
    var hunger: Double
    var happiness: Double
    var energy: Double
    var lastUpdated: Date
    var feedTimestamps: [Date] // 먹이 시간 기록 (1시간 10개 제한)

    // 레벨 시스템
    var level: Int
    var experience: Double

    static let initial = HamsterState(
        hunger: 80,
        happiness: 80,
        energy: 80,
        lastUpdated: .now,
        feedTimestamps: [],
        level: 1,
        experience: 0
    )

    /// 현재 레벨의 필요 경험치 (50, 100, 150, 200, 250, ...)
    var experienceToNext: Double {
        Double(level) * 50
    }

    /// 경험치 진행률 (0~1)
    var experienceProgress: Double {
        experience / experienceToNext
    }

    /// 현재 감정 상태 계산
    var currentEmotion: HamsterEmotion {
        if hunger < 30 { return .hungry }
        if energy < 30 { return .tired }
        if happiness < 20 { return .upset }
        if hunger > 60 && happiness > 60 { return .happy }
        return .happy
    }

    /// 레벨에 따른 햄스터 크기 배율 (0.7 ~ 1.65)
    var sizeScale: CGFloat {
        let scale = 0.7 + Double(min(level, 20) - 1) * 0.05
        return CGFloat(scale)
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
