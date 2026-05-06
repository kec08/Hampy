import ActivityKit
import Foundation

struct HampyActivityAttributes: ActivityAttributes {
    // 고정 데이터 (Activity 생성 시 설정)
    struct ContentState: Codable, Hashable {
        var hunger: Double
        var happiness: Double
        var energy: Double
        var emotion: String
        var remainingFeeds: Int
    }
}
