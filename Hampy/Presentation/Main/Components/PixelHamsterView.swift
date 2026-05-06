import SwiftUI

/// 에셋 기반 햄스터 이미지
struct PixelHamsterView: View {
    let emotion: HamsterEmotion
    let pixelSize: CGFloat // 호환용, 프레임 크기 계산에 사용

    init(emotion: HamsterEmotion, pixelSize: CGFloat = 4) {
        self.emotion = emotion
        self.pixelSize = pixelSize
    }

    private var imageName: String {
        switch emotion {
        case .happy: "hampy_happy"
        case .hungry: "hampy_hungry"
        case .tired: "hampy_tired"
        case .upset: "hampy_upset"
        case .eating: "hampy_eating"
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: pixelSize * 16, height: pixelSize * 16)
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
