import SwiftUI

@main
struct HampyApp: App {
    @State private var hamsterService = HamsterService()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(hamsterService)
        }
    }
}
