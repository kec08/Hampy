import SwiftUI

// MARK: - 해바라기씨 아이콘

struct PixelSeedIcon: View {
    let size: CGFloat
    init(size: CGFloat = 3) { self.size = size }

    var body: some View {
        Image("SeedIcon")
            .interpolation(.none)
            .resizable()
            .frame(width: size * 10, height: size * 10)
    }
}

// MARK: - 쳇바퀴 아이콘

struct PixelWheelIcon: View {
    let size: CGFloat
    init(size: CGFloat = 3) { self.size = size }

    var body: some View {
        Image("WheelIcon")
            .interpolation(.none)
            .resizable()
            .frame(width: size * 10, height: size * 10)
    }
}

// MARK: - 사과 아이콘

struct PixelAppleIcon: View {
    let size: CGFloat
    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Image("PixelApple")
            .interpolation(.none)
            .resizable()
            .frame(width: size * 8, height: size * 8)
    }
}

// MARK: - 하트 아이콘

struct PixelHeartIcon: View {
    let size: CGFloat
    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Image("PixelHeart")
            .interpolation(.none)
            .resizable()
            .frame(width: size * 8, height: size * 8)
    }
}

// MARK: - 번개 아이콘

struct PixelBoltIcon: View {
    let size: CGFloat
    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Image("PixelBolt")
            .interpolation(.none)
            .resizable()
            .frame(width: size * 8, height: size * 8)
    }
}
