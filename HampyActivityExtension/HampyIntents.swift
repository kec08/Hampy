import AppIntents
import ActivityKit
import WidgetKit

// MARK: - 먹이주기 Intent

struct FeedHampyIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "먹이주기"
    static var description: IntentDescription = "햄피에게 먹이를 줍니다"

    @MainActor
    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()
        state.refillFeedStock()
        guard state.feedStock > 0 else { return .result() }

        state.feedStock -= 1
        state.hunger = min(100, state.hunger + 12)
        state.happiness = min(100, state.happiness + 3)
        state.energy = min(100, state.energy + 2)
        state.addExperience(8)
        state.lastUpdated = .now
        SharedStorage.save(state)

        updateLiveActivity(state: state, emotion: "eating")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")

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
        if state.happiness < 100 {
            state.happiness = min(100, state.happiness + 10)
            state.addExperience(1)
        }
        state.lastUpdated = .now
        SharedStorage.save(state)

        updateLiveActivity(state: state, emotion: "love")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.0))
            let latest = SharedStorage.load()
            await updateLiveActivityAsync(state: latest, emotion: latest.currentEmotion.rawValue)
        }

        return .result()
    }
}

// MARK: - 운동 Intent

struct ExerciseHampyIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "운동하기"
    static var description: IntentDescription = "햄피가 쳇바퀴를 돕니다"

    @MainActor
    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()
        guard state.energy > 5 else { return .result() }

        state.happiness = min(100, state.happiness + 8)
        state.energy = max(0, state.energy - 10)
        state.addExperience(3)
        state.lastUpdated = .now
        SharedStorage.save(state)

        updateLiveActivity(state: state, emotion: state.currentEmotion.rawValue)
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")

        return .result()
    }
}

// MARK: - Live Activity 업데이트

@MainActor
private func updateLiveActivity(state: HamsterState, emotion: String) {
    let contentState = HampyActivityAttributes.ContentState(
        hunger: state.hunger,
        happiness: state.happiness,
        energy: state.energy,
        emotion: emotion,
        remainingFeeds: state.feedStock
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
    let contentState = HampyActivityAttributes.ContentState(
        hunger: state.hunger,
        happiness: state.happiness,
        energy: state.energy,
        emotion: emotion,
        remainingFeeds: state.feedStock
    )
    let content = ActivityContent(state: contentState, staleDate: nil)

    for activity in Activity<HampyActivityAttributes>.activities {
        await activity.update(content)
    }
}
