import SwiftUI

@main
struct HampyApp: App {
    @State private var hamsterService = HamsterService()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        BackgroundService.register(hamsterService: hamsterService)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(hamsterService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // 다이나믹 아일랜드에서 변경된 데이터 동기화
                hamsterService.syncFromShared()
            case .background:
                // 백그라운드 리프레시 예약
                BackgroundService.scheduleRefresh()
            default:
                break
            }
        }
    }
}
