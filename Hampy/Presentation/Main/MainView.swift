import SwiftUI

struct MainView: View {
    @Environment(HamsterService.self) private var service
    @State private var showWheel = false
    @State private var showFeed = false

    var body: some View {
        ZStack {
            // 초원 배경
            Color(hex: 0x5a9e4a)
                .ignoresSafeArea()

            DaisyParticles()

            VStack {
                Spacer()
                GrassFloor()
                    .frame(height: 100)
            }
            .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                // 상단
                HStack(alignment: .top) {
                    ProfileView()
                    Spacer()
                    StatsBarView(state: service.state)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // 햄피 (큰 사이즈)
                HampyView(
                    emotion: service.state.currentEmotion,
                    onPet: { service.pet() },
                    onTap: { service.pet() }
                )

                Spacer()

                // 하단 액션 (세로 정렬)
                HStack(spacing: 60) {
                    VStack(spacing: 6) {
                        PixelSeedIcon(size: 4)
                        Text("먹이")
                            .font(.custom("DOSGothic", size: 16))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture { showFeed = true }

                    VStack(spacing: 6) {
                        PixelWheelIcon(size: 4)
                        Text("쳇바퀴")
                            .font(.custom("DOSGothic", size: 16))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture { showWheel = true }
                }
                .padding(.bottom, 36)
            }
        }
        .fullScreenCover(isPresented: $showWheel) {
            WheelView()
        }
        .fullScreenCover(isPresented: $showFeed) {
            FeedView()
        }
    }
}

// MARK: - 프로필

private struct ProfileView: View {
    var body: some View {
        HStack(spacing: 10) {
            PixelHamsterView(emotion: .happy, pixelSize: 2.5)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text("햄피")
                    .font(.custom("DOSGothic", size: 18))
                    .foregroundStyle(.white)
                Text("Lv.1")
                    .font(.custom("DOSGothic", size: 13))
                    .foregroundStyle(Color(hex: 0xffd700))
            }
        }
    }
}

// MARK: - 데이지 파티클

private struct DaisyParticles: View {
    @State private var petals: [Petal] = (0..<10).map { _ in Petal.random() }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
            Canvas { context, size in
                for petal in petals {
                    let px: CGFloat = 5
                    // 꽃잎 4장
                    let offsets: [(CGFloat, CGFloat)] = [(0, -px), (px, 0), (0, px), (-px, 0)]
                    for (dx, dy) in offsets {
                        let rect = CGRect(x: petal.x + dx, y: petal.y + dy, width: px, height: px)
                        context.fill(Path(rect), with: .color(.white.opacity(petal.opacity)))
                    }
                    // 중심
                    let center = CGRect(x: petal.x, y: petal.y, width: px, height: px)
                    context.fill(Path(center), with: .color(Color(hex: 0xffd700).opacity(petal.opacity)))
                }
            }
            .onChange(of: timeline.date) { _, _ in updatePetals() }
        }
        .allowsHitTesting(false)
    }

    private func updatePetals() {
        for i in 0..<petals.count {
            petals[i].y += petals[i].speed
            petals[i].x += sin(petals[i].y / 30) * 0.5
            if petals[i].y > UIScreen.main.bounds.height {
                petals[i] = Petal.random()
                petals[i].y = -10
            }
        }
    }
}

private struct Petal {
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var opacity: Double

    static func random() -> Petal {
        Petal(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: -100...UIScreen.main.bounds.height),
            speed: CGFloat.random(in: 0.3...0.8),
            opacity: Double.random(in: 0.2...0.5)
        )
    }
}

// MARK: - 풀 바닥

private struct GrassFloor: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x3d8a30)))
            let px: CGFloat = 5
            for x in stride(from: 0, to: size.width, by: px * 3) {
                for y in stride(from: 0, to: size.height, by: px * 3) {
                    let offset = Int(y / px) % 2 == 0 ? px : 0
                    let rect = CGRect(x: x + offset, y: y, width: px, height: px * 2)
                    context.fill(Path(rect), with: .color(Color(hex: 0x4d9a40).opacity(0.5)))
                }
            }
        }
    }
}
