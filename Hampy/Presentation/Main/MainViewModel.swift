import Foundation

@Observable
final class MainViewModel {
    private let service: HamsterService

    var isEating: Bool = false

    init(service: HamsterService) {
        self.service = service
    }

    func feed() {
        guard service.feed() else { return }
        isEating = true

        // 2.5초 후 먹기 상태 해제
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            isEating = false
        }
    }

    func pet() {
        service.pet()
    }

    func runWheel(intensity: Double) {
        service.runWheel(intensity: intensity)
    }
}
