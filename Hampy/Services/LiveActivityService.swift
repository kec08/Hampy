import ActivityKit
import Foundation

@Observable
final class LiveActivityService {

    private var currentActivity: Activity<HampyActivityAttributes>?

    var isActivityActive: Bool {
        currentActivity != nil
    }

    // MARK: - Start

    func start(state: HamsterState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = HampyActivityAttributes()
        let contentState = makeContentState(from: state)
        let content = ActivityContent(state: contentState, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("[LiveActivity] 시작 실패: \(error)")
        }
    }

    // MARK: - Update

    func update(state: HamsterState) {
        guard let activity = currentActivity else { return }

        let contentState = makeContentState(from: state)
        let content = ActivityContent(state: contentState, staleDate: nil)

        Task {
            await activity.update(content)
        }
    }

    // MARK: - End

    func end() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }

    // MARK: - Helper

    private func makeContentState(from state: HamsterState) -> HampyActivityAttributes.ContentState {
        return HampyActivityAttributes.ContentState(
            hunger: state.hunger,
            happiness: state.happiness,
            energy: state.energy,
            emotion: state.currentEmotion.rawValue,
            remainingFeeds: state.feedStock
        )
    }
}
