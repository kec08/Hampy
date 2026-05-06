import Foundation

/// 앱과 위젯 Extension 간 공유 저장소
enum SharedStorage {
    static let suiteName = "group.com.eunchan.hampy"
    static let stateKey = "hamster_state"

    static var shared: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func save(_ state: HamsterState) {
        if let data = try? JSONEncoder().encode(state) {
            shared.set(data, forKey: stateKey)
        }
    }

    static func load() -> HamsterState {
        guard let data = shared.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(HamsterState.self, from: data) else {
            return .initial
        }
        return state
    }
}
