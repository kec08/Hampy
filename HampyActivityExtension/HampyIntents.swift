import AppIntents
import ActivityKit

// MARK: - 먹이주기 Intent

struct FeedHampyIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "먹이주기"
    static var description: IntentDescription = "햄피에게 먹이를 줍니다"

    @MainActor
    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()

        let oneHourAgo = Date.now.addingTimeInterval(-3600)
        state.feedTimestamps = state.feedTimestamps.filter { $0 > oneHourAgo }
        guard state.feedTimestamps.count < 5 else { return .result() }

        state.feedTimestamps.append(.now)
        state.hunger = min(100, state.hunger + 20)
        state.happiness = min(100, state.happiness + 5)
        state.energy = min(100, state.energy + 5)
        state.lastUpdated = .now
        SharedStorage.save(state)

        updateLiveActivity(state: state, emotion: "eating")

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            let current = SharedStorage.load()
            updateLiveActivity(state: current, emotion: "yummy")

            try? await Task.sleep(for: .seconds(1.5))
            let latest = SharedStorage.load()
            await updateLiveActivityAsync(state: latest, emotion: latest.currentEmotion.rawValue)
        }

        return .result()
    }
}

// MARK: - 쓰다듬기 Intent

struct PetHampyIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "쓰다듬기"
    static var description: IntentDescription = "햄피를 쓰다듬습니다"

    @MainActor
    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()
        state.happiness = min(100, state.happiness + 10)
        state.lastUpdated = .now
        SharedStorage.save(state)

        updateLiveActivity(state: state, emotion: "love")

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.0))
            let latest = SharedStorage.load()
            await updateLiveActivityAsync(state: latest, emotion: latest.currentEmotion.rawValue)
        }

        return .result()
    }
}

// MARK: - Live Activity 업데이트

@MainActor
private func updateLiveActivity(state: HamsterState, emotion: String) {
    let oneHourAgo = Date.now.addingTimeInterval(-3600)
    let remaining = max(0, 5 - state.feedTimestamps.filter { $0 > oneHourAgo }.count)
    let contentState = HampyActivityAttributes.ContentState(
        hunger: state.hunger,
        happiness: state.happiness,
        energy: state.energy,
        emotion: emotion,
        remainingFeeds: remaining
    )
    let content = ActivityContent(state: contentState, staleDate: nil)

    Task {
        for activity in Activity<HampyActivityAttributes>.activities {
            await activity.update(content)
        }
    }
}

@MainActor
private func updateLiveActivityAsync(state: HamsterState, emotion: String) async {
    let oneHourAgo = Date.now.addingTimeInterval(-3600)
    let remaining = max(0, 5 - state.feedTimestamps.filter { $0 > oneHourAgo }.count)
    let contentState = HampyActivityAttributes.ContentState(
        hunger: state.hunger,
        happiness: state.happiness,
        energy: state.energy,
        emotion: emotion,
        remainingFeeds: remaining
    )
    let content = ActivityContent(state: contentState, staleDate: nil)

    for activity in Activity<HampyActivityAttributes>.activities {
        await activity.update(content)
    }
}
