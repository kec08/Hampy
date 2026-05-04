import Foundation

@Observable
final class HamsterService {

    private(set) var state: HamsterState
    let liveActivity = LiveActivityService()

    // 분당 감소량
    private let hungerDecayPerMinute: Double = 0.5
    private let happinessDecayPerMinute: Double = 0.3
    private let energyRecoveryPerMinute: Double = 0.2

    private let storageKey = "hamster_state"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(HamsterState.self, from: data) {
            self.state = saved
        } else {
            self.state = .initial
        }
        applyTimeDecay()
        liveActivity.start(state: state)
    }

    // MARK: - Actions

    /// 남은 먹이 개수 (1시간 5개 제한)
    var remainingFeeds: Int {
        let oneHourAgo = Date.now.addingTimeInterval(-3600)
        let recentCount = state.feedTimestamps.filter { $0 > oneHourAgo }.count
        return max(0, 5 - recentCount)
    }

    func feed() -> Bool {
        // 1시간 내 5개 제한
        let oneHourAgo = Date.now.addingTimeInterval(-3600)
        state.feedTimestamps = state.feedTimestamps.filter { $0 > oneHourAgo }

        guard state.feedTimestamps.count < 5 else { return false }

        state.feedTimestamps.append(.now)
        state.hunger = min(100, state.hunger + 20)
        state.happiness = min(100, state.happiness + 5)
        state.energy = min(100, state.energy + 5)
        save()
        return true
    }

    func pet() {
        state.happiness = min(100, state.happiness + 10)
        save()
    }

    func runWheel(intensity: Double) {
        let happinessGain = 15 * intensity
        let energyCost = 20 * intensity
        state.happiness = min(100, state.happiness + happinessGain)
        state.energy = max(0, state.energy - energyCost)
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
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        liveActivity.update(state: state)
    }
}
