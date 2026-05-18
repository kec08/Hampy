import Foundation

struct HamsterState: Codable {
    var hunger: Double
    var happiness: Double
    var energy: Double
    var lastUpdated: Date

    // 먹이 시스템 (아침 8시, 점심 12:30, 저녁 19시 각 10개 지급, 최대 30개)
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

    /// 식사 시간 기반 먹이 보충 (8:00, 12:30, 19:00 각 10개, 최대 30개)
    mutating func refillFeedStock() {
        let cal = Calendar.current
        let now = Date.now

        // 식사 시간 (시, 분)
        let mealTimes: [(Int, Int)] = [(8, 0), (12, 30), (19, 0)]

        // 오늘 + 어제 식사 시간 중 lastRefillDate 이후 ~ 현재 사이에 해당하는 것 카운트
        var mealsToAdd = 0
        for dayOffset in -1...0 {
            guard let baseDay = cal.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            for (hour, minute) in mealTimes {
                var comp = cal.dateComponents([.year, .month, .day], from: baseDay)
                comp.hour = hour
                comp.minute = minute
                comp.second = 0
                guard let mealDate = cal.date(from: comp) else { continue }
                if mealDate > lastRefillDate && mealDate <= now {
                    mealsToAdd += 1
                }
            }
        }

        guard mealsToAdd > 0 else { return }
        feedStock = min(30, feedStock + mealsToAdd * 10)
        lastRefillDate = now
    }

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
        // 극단적 상태 (우선순위 높음)
        if happiness < 10 { return .angry }
        if hunger < 15 && happiness < 30 { return .angry }

        // 기본 부정 상태
        if hunger < 30 { return .hungry }
        if energy < 20 { return .tired }
        if happiness < 20 { return .upset }

        // 중간 상태
        if happiness < 35 { return .annoyed }
        if happiness < 50 && energy > 30 { return .bored }

        // 무표정 (모든 스탯 중간)
        if hunger > 40 && hunger < 65 && happiness > 40 && happiness < 65 { return .blank }

        // 호기심 (에너지 높고 행복 적당)
        if energy > 70 && happiness > 50 && happiness < 75 { return .curious }

        // 행복
        if hunger > 60 && happiness > 60 { return .happy }

        return .blank
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
