import Foundation

@Observable
final class WheelViewModel {
    private let service: HamsterService

    var rotationAngle: Double = 0
    var speed: Double = 0
    var isRunning: Bool = false
    var isTired: Bool = false

    private var tapTimestamps: [Date] = []
    private let maxSpeed: Double = 10.0
    private let decayRate: Double = 0.95

    init(service: HamsterService) {
        self.service = service
    }

    // MARK: - 탭으로 속도 올리기

    func tap() {
        guard !isTired else { return }

        // 에너지 체크
        if service.state.energy <= 0 {
            HampySound.tired.playWithHaptic()
            isTired = true
            speed = 0
            return
        }

        HampySound.wheelTap.playWithHaptic()
        tapTimestamps.append(.now)
        // 최근 2초 내 탭만 유지
        tapTimestamps = tapTimestamps.filter { Date.now.timeIntervalSince($0) < 2.0 }

        // 탭 빈도 → 속도
        let tapsPerSecond = Double(tapTimestamps.count) / 2.0
        speed = min(maxSpeed, tapsPerSecond * 2.5)

        if !isRunning {
            isRunning = true
            startRunLoop()
        }
    }

    // MARK: - 매 프레임 업데이트

    private func startRunLoop() {
        Task { @MainActor in
            while speed > 0.3 {
                rotationAngle += speed * 15
                speed *= decayRate

                // 속도에 비례해서 스탯 변화
                let intensity = speed / maxSpeed
                service.runWheel(intensity: intensity * 0.02)

                if service.state.energy <= 5 {
                    isTired = true
                    speed = 0
                    break
                }

                try? await Task.sleep(for: .milliseconds(50))
            }

            speed = 0
            isRunning = false

            // 지치면 5초 후 자동 회복
            if isTired {
                try? await Task.sleep(for: .seconds(5))
                isTired = false
                tapTimestamps = []
            }
        }
    }
}
