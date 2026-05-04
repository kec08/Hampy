import SwiftUI

struct FeedView: View {
    @Environment(HamsterService.self) private var service
    @Environment(\.dismiss) private var dismiss

    @State private var seedPosition: CGPoint = .zero
    @State private var isDragging = false
    @State private var isThrown = false
    @State private var isChewing = false
    @State private var showSeed = true
    @State private var throwTarget: CGPoint = .zero
    @State private var hampyPosition: CGPoint = .zero
    @State private var chewText = ""

    private let hampyBaseY: CGFloat = 280

    private var canFeed: Bool { service.remainingFeeds > 0 }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: 0x5a9e4a)
                    .ignoresSafeArea()

                FeedBackground()
                    .ignoresSafeArea()

                // 햄피
                PixelHamsterView(
                    emotion: isChewing ? .eating : .happy,
                    pixelSize: 7
                )
                .position(x: hampyPosition.x, y: hampyPosition.y)
                .animation(.easeInOut(duration: 0.3), value: hampyPosition)

                // 씹는 중 텍스트
                if !chewText.isEmpty {
                    Text(chewText)
                        .font(.custom("DOSGothic", size: 18))
                        .foregroundStyle(.white)
                        .position(x: hampyPosition.x, y: hampyBaseY - 70)
                }

                // 해바라기씨
                if showSeed && !isChewing {
                    SeedSprite(disabled: !canFeed)
                        .frame(width: 50, height: 50)
                        .position(seedPosition)
                        .gesture(
                            canFeed ?
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    seedPosition = value.location
                                }
                                .onEnded { value in
                                    throwSeed(from: value.location, velocity: value.predictedEndLocation, in: geo.size)
                                }
                            : nil
                        )
                }

                // 상단
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("돌아가기")
                                .font(.custom("DOSGothic", size: 16))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()
                }

                // 하단: 해바라기씨 아이콘 + 개수
                VStack {
                    Spacer()
                    HStack(spacing: 4) {
                        PixelSeedIcon(size: 3)
                            .opacity(canFeed ? 1.0 : 0.3)
                        Text("x\(service.remainingFeeds)")
                            .font(.custom("DOSGothic", size: 20))
                            .foregroundStyle(canFeed ? .white : .gray)
                    }
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                seedPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height - 130)
                hampyPosition = CGPoint(x: geo.size.width / 2, y: hampyBaseY)
            }
        }
    }

    // MARK: - 던지기

    private func throwSeed(from position: CGPoint, velocity: CGPoint, in size: CGSize) {
        guard canFeed else { return }

        isThrown = true
        throwTarget = CGPoint(
            x: min(max(velocity.x, 40), size.width - 40),
            y: max(100, velocity.y)
        )

        withAnimation(.easeOut(duration: 0.4)) {
            seedPosition = throwTarget
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.2))

            withAnimation(.easeInOut(duration: 0.3)) {
                hampyPosition = CGPoint(x: throwTarget.x, y: hampyBaseY)
            }

            try? await Task.sleep(for: .seconds(0.3))

            let fed = service.feed()
            showSeed = false

            if fed {
                isChewing = true
                chewText = "-_- 냠냠..."
                try? await Task.sleep(for: .seconds(1.2))
                chewText = ""
                isChewing = false
            }

            withAnimation {
                isThrown = false
                isDragging = false
            }
            showSeed = true
            seedPosition = CGPoint(x: size.width / 2, y: size.height - 130)
            hampyPosition = CGPoint(x: size.width / 2, y: hampyBaseY)
        }
    }
}

// MARK: - 해바라기씨 스프라이트

private struct SeedSprite: View {
    var disabled: Bool = false

    var body: some View {
        Canvas { context, size in
            let px: CGFloat = 5
            let grid: [[Character]] = [
                Array("....OO...."),
                Array("...ODDO..."),
                Array("..ODDLDO.."),
                Array(".ODDLDDO.."),
                Array("ODDLDDDO.."),
                Array("ODDDDDDO.."),
                Array(".ODDDDDO.."),
                Array("..ODDDO..."),
                Array("...OOO...."),
                Array(".........."),
            ]
            let offsetX = (size.width - 10 * px) / 2
            let offsetY = (size.height - 10 * px) / 2
            for row in 0..<grid.count {
                for col in 0..<grid[row].count {
                    let char = grid[row][col]
                    let color: Color?
                    if disabled {
                        color = switch char {
                        case "O": Color.gray.opacity(0.3)
                        case "D": Color.gray.opacity(0.2)
                        case "L": Color.gray.opacity(0.15)
                        default: nil
                        }
                    } else {
                        color = switch char {
                        case "O": Color(hex: 0x1a1a1a)
                        case "D": Color(hex: 0x3d3d3d)
                        case "L": Color(hex: 0xd4c9a8)
                        default: nil
                        }
                    }
                    guard let c = color else { continue }
                    let rect = CGRect(x: offsetX + CGFloat(col) * px, y: offsetY + CGFloat(row) * px, width: px, height: px)
                    context.fill(Path(rect), with: .color(c))
                }
            }
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
