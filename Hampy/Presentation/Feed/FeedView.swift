import SwiftUI

struct FeedView: View {
    @Environment(HamsterService.self) private var service
    @Environment(\.dismiss) private var dismiss

    @State private var seedPosition: CGPoint = .zero
    @State private var seedVelocity: CGSize = .zero
    @State private var isDragging = false
    @State private var isFlying = false
    @State private var isChewing = false
    @State private var showSeed = true
    @State private var hampyPosition: CGPoint = .zero
    @State private var chewText = ""
    @State private var bounceCount = 0

    private let hampySize: CGFloat = 112

    private var canFeed: Bool { service.remainingFeeds > 0 }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: 0x5a9e4a)
                    .ignoresSafeArea()

                FeedBackground()
                    .ignoresSafeArea()

                // 햄피
                Image(isChewing ? "hampy_eating" : "hampy_happy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: hampySize, height: hampySize)
                    .position(x: hampyPosition.x, y: hampyPosition.y)
                    .animation(.easeInOut(duration: 0.4), value: hampyPosition)

                // 씹는 텍스트
                if !chewText.isEmpty {
                    OutlinedText(chewText, size: 18)
                        .position(x: hampyPosition.x, y: hampyPosition.y - 70)
                }

                // 해바라기씨 (에셋)
                if showSeed && !isChewing {
                    Image("SeedIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(isFlying ? Double(bounceCount) * 45 : 0))
                        .position(seedPosition)
                        .opacity(canFeed ? 1.0 : 0.3)
                        .gesture(
                            canFeed ?
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    seedPosition = value.location
                                }
                                .onEnded { value in
                                    let velocity = CGSize(
                                        width: value.predictedEndLocation.x - value.location.x,
                                        height: value.predictedEndLocation.y - value.location.y
                                    )
                                    throwSeed(from: value.location, velocity: velocity, in: geo.size)
                                }
                            : nil
                        )
                }

                // 상단
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            OutlinedText("돌아가기", size: 16, color: .white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()
                }

                // 하단 씨앗 개수
                VStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image("SeedIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                        OutlinedText("x\(service.remainingFeeds)", size: 20)
                    }
                    .opacity(canFeed ? 1.0 : 0.3)
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                seedPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height - 140)
                hampyPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.38)
            }
        }
    }

    // MARK: - 던지기 + 튕김

    private func throwSeed(from position: CGPoint, velocity: CGSize, in size: CGSize) {
        guard canFeed else { return }

        isFlying = true
        isDragging = false
        bounceCount = 0

        // 드래그 세기 계산
        let power = sqrt(velocity.width * velocity.width + velocity.height * velocity.height)
        let speedFactor = min(power / 300, 3.0) // 최대 3배속

        // 목표 위치 (드래그 방향)
        var targetX = position.x + velocity.width * 0.5
        var targetY = position.y + velocity.height * 0.5

        // 화면 안에 제한
        targetX = min(max(targetX, 30), size.width - 30)
        targetY = min(max(targetY, 80), size.height - 100)

        // 씨앗 날아가기
        let flyDuration = max(0.2, 0.5 / speedFactor)

        Task { @MainActor in
            // 1단계: 씨앗 날아감
            withAnimation(.easeOut(duration: flyDuration)) {
                seedPosition = CGPoint(x: targetX, y: targetY)
            }
            try? await Task.sleep(for: .seconds(flyDuration * 0.8))

            // 2단계: 튕김 (세게 던질수록 많이 튕김)
            let bounces = Int(min(speedFactor, 2))
            for _ in 0..<bounces {
                bounceCount += 1
                let bounceX = targetX + CGFloat.random(in: -30...30)
                let bounceY = targetY + CGFloat.random(in: -20...10)
                let clampedX = min(max(bounceX, 30), size.width - 30)
                let clampedY = min(max(bounceY, 80), size.height - 100)

                withAnimation(.easeOut(duration: 0.15)) {
                    seedPosition = CGPoint(x: clampedX, y: clampedY)
                }
                try? await Task.sleep(for: .seconds(0.15))

                targetX = clampedX
                targetY = clampedY
            }

            // 3단계: 햄피가 씨앗 위치로 이동해서 먹기
            let finalSeedPos = seedPosition
            withAnimation(.easeInOut(duration: 0.4)) {
                hampyPosition = CGPoint(x: finalSeedPos.x, y: finalSeedPos.y)
            }
            try? await Task.sleep(for: .seconds(0.4))

            // 4단계: 먹기
            let fed = service.feed()
            showSeed = false
            isFlying = false

            if fed {
                isChewing = true
                chewText = "-_- 냠냠..."
                try? await Task.sleep(for: .seconds(1.2))
                chewText = ""
                isChewing = false
            }

            // 리셋
            withAnimation(.easeInOut(duration: 0.3)) {
                hampyPosition = CGPoint(x: size.width / 2, y: size.height * 0.38)
            }
            try? await Task.sleep(for: .seconds(0.3))

            showSeed = true
            seedPosition = CGPoint(x: size.width / 2, y: size.height - 140)
            bounceCount = 0
        }
    }
}

// MARK: - 배경

private struct FeedBackground: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x5a9e4a)))
            let groundRect = CGRect(x: 0, y: size.height * 0.7, width: size.width, height: size.height * 0.3)
            context.fill(Path(groundRect), with: .color(Color(hex: 0x3d8a30)))

            let positions: [(CGFloat, CGFloat)] = [
                (40, 180), (300, 120), (80, 420), (260, 380),
                (180, 550), (320, 500), (60, 300),
            ]
            let px: CGFloat = 4
            for (x, y) in positions {
                let offsets: [(CGFloat, CGFloat)] = [(0, -px), (px, 0), (0, px), (-px, 0)]
                for (dx, dy) in offsets {
                    let rect = CGRect(x: x + dx, y: y + dy, width: px, height: px)
                    context.fill(Path(rect), with: .color(.white.opacity(0.5)))
                }
                let center = CGRect(x: x, y: y, width: px, height: px)
                context.fill(Path(center), with: .color(Color(hex: 0xffd700).opacity(0.6)))
            }
        }
        .allowsHitTesting(false)
    }
}
