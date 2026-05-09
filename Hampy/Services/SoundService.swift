import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ sound: HampySound) {
        guard let url = sound.systemSoundURL else { return }

        if let player = players[sound.rawValue] {
            player.currentTime = 0
            player.play()
        } else if let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = sound.volume
            player.prepareToPlay()
            player.play()
            players[sound.rawValue] = player
        }
    }
}

enum HampySound: String {
    case feed
    case eat
    case pet
    case surprise
    case wheelTap
    case tired

    var volume: Float {
        switch self {
        case .feed:     return 0.5
        case .eat:      return 0.4
        case .pet:      return 0.3
        case .surprise: return 0.6
        case .wheelTap: return 0.2
        case .tired:    return 0.4
        }
    }

    var systemSoundURL: URL? {
        switch self {
        case .feed:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_click.caf")
        case .eat:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_modifier.caf")
        case .pet:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/payment_success.caf")
        case .surprise:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf")
        case .wheelTap:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
        case .tired:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/low_power.caf")
        }
    }

    func play() {
        SoundManager.shared.play(self)
    }

    func playWithHaptic() {
        play()
        switch self {
        case .pet:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .surprise:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .feed, .eat:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .wheelTap:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .tired:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}
