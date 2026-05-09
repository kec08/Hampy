import BackgroundTasks
import Foundation

enum BackgroundService {

    static let refreshTaskID = "com.eunchan.hampy.refresh"

    // MARK: - Register

    /// 앱 시작 시 한 번 호출 (application didFinishLaunching 시점)
    static func register(hamsterService: HamsterService) {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskID,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleRefresh(refreshTask, hamsterService: hamsterService)
        }
    }

    // MARK: - Schedule

    /// 백그라운드 진입 시 다음 리프레시 예약
    static func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 최소 15분 후
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[Background] 스케줄 실패: \(error)")
        }
    }

    // MARK: - Handle

    private static func handleRefresh(
        _ task: BGAppRefreshTask,
        hamsterService: HamsterService
    ) {
        // 시간 초과 시 태스크 종료
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // 다음 리프레시 미리 예약
        scheduleRefresh()

        // 시간 경과에 따른 스탯 감쇠 적용
        var state = SharedStorage.load()
        let now = Date.now
        let elapsed = now.timeIntervalSince(state.lastUpdated) / 60.0

        if elapsed > 1 {
            state.hunger = max(0, state.hunger - 0.5 * elapsed)
            state.happiness = max(0, state.happiness - 0.3 * elapsed)
            state.energy = min(100, state.energy + 0.2 * elapsed)
            state.lastUpdated = now
            SharedStorage.save(state)
        }

        // 다이나믹 아일랜드 갱신
        hamsterService.liveActivity.update(state: state)

        task.setTaskCompleted(success: true)
    }
}
