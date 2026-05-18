import Foundation
import WidgetKit

@Observable
final class HamsterService {

    private(set) var state: HamsterState
    let liveActivity = LiveActivityService()

    // 분당 감소량
    private let hungerDecayPerMinute: Double = 0.5
    private let happinessDecayPerMinute: Double = 0.3
    private let energyRecoveryPerMinute: Double = 0.2

    init() {
        self.state = SharedStorage.load()
        state.refillFeedStock()
        applyTimeDecay()
        liveActivity.start(state: state)
    }

    // MARK: - Actions

    /// 남은 먹이 개수
    var remainingFeeds: Int {
        state.feedStock
    }

    func feed() -> Bool {
        state.refillFeedStock()
        guard state.feedStock > 0 else { return false }

        state.feedStock -= 1
        state.hunger = min(100, state.hunger + 12)
        state.happiness = min(100, state.happiness + 3)
        state.energy = min(100, state.energy + 2)
        state.addExperience(8)
        save()
        return true
    }

    func pet() {
        guard state.happiness < 100 else {
            // 하트 꽉 차면 쓰다듬기 효과 없음
            state.happiness = 100
            save()
            return
        }
        state.happiness = min(100, state.happiness + 10)
        state.addExperience(1)
        save()
    }

    /// 놀람 (탭) - 페널티
    func surprise() {
        state.happiness = max(0, state.happiness - 5)
        state.energy = max(0, state.energy - 2)
        save()
    }

    func runWheel(intensity: Double) {
        let happinessGain = 15 * intensity
        let energyCost = 20 * intensity
        state.happiness = min(100, state.happiness + happinessGain)
        state.energy = max(0, state.energy - energyCost)
        state.addExperience(3 * intensity)
        save()
    }

    // MARK: - Time Decay

    func applyTimeDecay() {
        let now = Date.now
        let elapsed = now.timeIntervalSince(state.lastUpdated) / 60.0 // 분 단위

        guard elapsed > 1 else { return }

        state.hunger = max(0, state.hunger - hungerDecayPerMinute * elapsed)
        state.happiness = max(0, state.happiness - happinessDecayPerMinute * elapsed)
        state.energy = min(100, state.energy + energyRecoveryPerMinute * elapsed)
        state.lastUpdated = now
        save()
    }

    // MARK: - Persistence

    private func save() {
        state.lastUpdated = .now
        SharedStorage.save(state)
        liveActivity.update(state: state)
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
    }

    /// 앱 포그라운드 복귀 시 공유 저장소에서 동기화
    func syncFromShared() {
        state = SharedStorage.load()
        state.refillFeedStock()
        applyTimeDecay()
        // 위젯에서 변경된 데이터도 반영
        SharedStorage.save(state)
        liveActivity.update(state: state)
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
    }
}
