import AppIntents
import ActivityKit
import WidgetKit

// MARK: - 위젯 전용 먹이주기

struct WidgetFeedIntent: AppIntent {
    static var title: LocalizedStringResource = "위젯 먹이주기"

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

        // eating 표정으로 즉시 갱신
        setReaction("eating")
        reloadAll()
        updateActivity(state: state, emotion: "eating")

        // 시간차 표정 복원
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            setReaction("yummy")
            reloadAll()
            let current = SharedStorage.load()
            updateActivity(state: current, emotion: "yummy")

            try? await Task.sleep(for: .seconds(1.5))
            clearReaction()
            reloadAll()
            let latest = SharedStorage.load()
            updateActivity(state: latest, emotion: latest.currentEmotion.rawValue)
        }

        return .result()
    }
}

// MARK: - 위젯 전용 쓰다듬기

struct WidgetPetIntent: AppIntent {
    static var title: LocalizedStringResource = "위젯 쓰다듬기"

    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()
        if state.happiness < 100 {
            state.happiness = min(100, state.happiness + 10)
            state.addExperience(1)
        }
        state.lastUpdated = .now
        SharedStorage.save(state)

        // love 표정으로 즉시 갱신
        setReaction("love")
        reloadAll()
        updateActivity(state: state, emotion: "love")

        Task {
            try? await Task.sleep(for: .seconds(2.0))
            clearReaction()
            reloadAll()
            let latest = SharedStorage.load()
            updateActivity(state: latest, emotion: latest.currentEmotion.rawValue)
        }

        return .result()
    }
}

// MARK: - 위젯 전용 운동

struct WidgetExerciseIntent: AppIntent {
    static var title: LocalizedStringResource = "위젯 운동하기"

    func perform() async throws -> some IntentResult {
        var state = SharedStorage.load()
        guard state.energy > 5 else { return .result() }

        state.happiness = min(100, state.happiness + 8)
        state.energy = max(0, state.energy - 10)
        state.addExperience(3)
        state.lastUpdated = .now
        SharedStorage.save(state)

        // 달리기 표정으로 즉시 갱신
        setReaction("running")
        reloadAll()
        updateActivity(state: state, emotion: state.currentEmotion.rawValue)

        Task {
            try? await Task.sleep(for: .seconds(2.0))
            clearReaction()
            reloadAll()
        }

        return .result()
    }
}

// MARK: - 헬퍼

private func setReaction(_ emotion: String) {
    SharedStorage.shared.set(emotion, forKey: "widget_reaction")
}

private func clearReaction() {
    SharedStorage.shared.removeObject(forKey: "widget_reaction")
}

private func reloadAll() {
    WidgetCenter.shared.reloadTimelines(ofKind: "HampyGameWidget")
    WidgetCenter.shared.reloadTimelines(ofKind: "HampyCalendarWidget")
}

private func updateActivity(state: HamsterState, emotion: String) {
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
