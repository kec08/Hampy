import SwiftUI

@main
struct HampyApp: App {
    @State private var hamsterService = HamsterService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(hamsterService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 다이나믹 아일랜드에서 변경된 데이터 동기화
                hamsterService.syncFromShared()
            }
        }
    }
}
