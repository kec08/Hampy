import SwiftUI

struct WheelView: View {
    @Environment(HamsterService.self) private var service
    @State private var viewModel: WheelViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PlaygroundBG()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단
                HStack {
                    Button(action: { dismiss() }) {
                        OutlinedText("돌아가기", size: 16, color: .white.opacity(0.8))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        PixelBoltIcon(size: 2.5)
                        OutlinedText("\(Int(service.state.energy))", size: 16, color: Color(hex: 0xffd700))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                Spacer()

                if let vm = viewModel {
                    // 쳇바퀴 + 햄스터 (정중앙)
                    ZStack {
                        SideWheel(angle: vm.rotationAngle)
                            .frame(width: 260, height: 260)

                        // 햄스터가 쳇바퀴 안 바닥에서 달림
                        WheelRunningHampy(
                            isRunning: vm.isRunning,
                            speed: vm.speed,
                            wheelAngle: vm.rotationAngle
                        )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel?.tap() }

                    // 거치대
                    WheelStand()
                        .frame(width: 280, height: 45)
                        .offset(y: -10)

                    Spacer()
                        .frame(height: 12)

                    // 지침 상태
                    if vm.isTired {
                        OutlinedText("지쳤다... 쉬어야 해", size: 16, color: Color(hex: 0xff9642))
                    }

                    Spacer()
                        .frame(height: 10)

                    // 게이지 바
                    SpeedBar(speed: vm.speed, maxSpeed: 10.0)
                        .frame(height: 12)
                        .padding(.horizontal, 40)
                        .onTapGesture { viewModel?.tap() }
                }

                Spacer()
            }
        }
        .onAppear { viewModel = WheelViewModel(service: service) }
    }
}

// MARK: - 쳇바퀴 (나무 베이지)

private struct SideWheel: View {
    let angle: Double

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR: CGFloat = 120
            let innerR: CGFloat = 98
            let px: CGFloat = 4

            // 테두리
            for i in stride(from: 0, to: 360, by: 1.5) {
                let rad = Double(i) * .pi / 180
                for r in stride(from: innerR, through: outerR, by: 3) {
                    let x = cx + r * cos(rad)
                    let y = cy + r * sin(rad)
                    let brightness = (r - innerR) / (outerR - innerR)
                    let color = brightness > 0.5 ? Color(hex: 0xC8A870) : Color(hex: 0xDCC090)
                    context.fill(Path(CGRect(x: x - px/2, y: y - px/2, width: px, height: px)), with: .color(color))
                }
            }

            // 외곽선
            for i in stride(from: 0, to: 360, by: 1.5) {
                let rad = Double(i) * .pi / 180
                let x1 = cx + outerR * cos(rad)
                let y1 = cy + outerR * sin(rad)
                context.fill(Path(CGRect(x: x1 - px/2, y: y1 - px/2, width: px, height: px)), with: .color(Color(hex: 0x7A5C3A)))
                let x2 = cx + innerR * cos(rad)
                let y2 = cy + innerR * sin(rad)
                context.fill(Path(CGRect(x: x2 - px/2, y: y2 - px/2, width: px, height: px)), with: .color(Color(hex: 0x7A5C3A).opacity(0.6)))
            }

            // 살 8개
            for i in 0..<8 {
                let baseAngle = (Double(i) * 45 + angle) * .pi / 180
                for step in stride(from: 10.0, to: innerR - 2, by: px) {
                    let x = cx + step * cos(baseAngle)
                    let y = cy + step * sin(baseAngle)
                    let perpX = -sin(baseAngle) * 1.5
                    let perpY = cos(baseAngle) * 1.5
                    context.fill(Path(CGRect(x: x + perpX - px/2, y: y + perpY - px/2, width: px, height: px)), with: .color(Color(hex: 0xB89860)))
                    context.fill(Path(CGRect(x: x - perpX - px/2, y: y - perpY - px/2, width: px, height: px)), with: .color(Color(hex: 0xC8A870)))
                }
            }

            // 중심 축
            let axle: CGFloat = 16
            context.fill(Path(CGRect(x: cx - axle/2, y: cy - axle/2, width: axle, height: axle)), with: .color(Color(hex: 0x8B7355)))
            context.fill(Path(CGRect(x: cx - axle/2 + 2, y: cy - axle/2 + 2, width: 5, height: 5)), with: .color(Color(hex: 0xA89070)))
        }
    }
}

// MARK: - 쳇바퀴 안 바닥에서 달리는 햄스터

private struct WheelRunningHampy: View {
    let isRunning: Bool
    let speed: Double
    let wheelAngle: Double

    private let runImages = ["hampy_run1", "hampy_run2", "hampy_run3", "hampy_run4",
                             "hampy_run5", "hampy_run6", "hampy_run7", "hampy_run8"]
    private let bounceValues: [CGFloat] = [0, -2, -4, -2, 0, -2, -4, -2]

    var body: some View {
        // TimelineView로 확실한 리렌더링
        TimelineView(.periodic(from: .now, by: isRunning ? max(0.06, 0.18 - speed * 0.015) : 1.0)) { timeline in
            let seconds = timeline.date.timeIntervalSince1970
            let frame = isRunning ? Int(seconds / max(0.06, 0.18 - speed * 0.015)) % 8 : 0
            let imageName = isRunning ? runImages[frame] : "hampy_run1"
            let bounce = isRunning ? bounceValues[frame] : 0.0

            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .offset(y: 55 + bounce)
        }
        .frame(width: 260, height: 260)
    }
}

// MARK: - 거치대 (나무)

private struct WheelStand: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2

            let left = Path { p in
                p.move(to: CGPoint(x: cx - 15, y: 0))
                p.addLine(to: CGPoint(x: cx - 60, y: size.height - 6))
                p.addLine(to: CGPoint(x: cx - 50, y: size.height - 6))
                p.addLine(to: CGPoint(x: cx - 6, y: 0))
                p.closeSubpath()
            }
            context.fill(left, with: .color(Color(hex: 0x9B8365)))

            let right = Path { p in
                p.move(to: CGPoint(x: cx + 15, y: 0))
                p.addLine(to: CGPoint(x: cx + 60, y: size.height - 6))
                p.addLine(to: CGPoint(x: cx + 50, y: size.height - 6))
                p.addLine(to: CGPoint(x: cx + 6, y: 0))
                p.closeSubpath()
            }
            context.fill(right, with: .color(Color(hex: 0x8B7355)))

            let base = CGRect(x: cx - 65, y: size.height - 6, width: 130, height: 6)
            context.fill(Path(base), with: .color(Color(hex: 0x7A6345)))
        }
    }
}

// MARK: - 속도 바

private struct SpeedBar: View {
    let speed: Double
    let maxSpeed: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.black.opacity(0.3))
                Rectangle().fill(gaugeColor).frame(width: geo.size.width * (speed / maxSpeed))
            }
        }
    }

    private var gaugeColor: Color {
        let ratio = speed / maxSpeed
        if ratio > 0.7 { return Color(hex: 0xff4444) }
        if ratio > 0.4 { return Color(hex: 0xffd700) }
        return Color(hex: 0x4ecdc4)
    }
}

// MARK: - 놀이터 배경 (움직이는 구름)

private struct PlaygroundBG: View {
    @State private var cloudOffset: CGFloat = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
            Canvas { context, size in
                // 하늘
                let skyRect = CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.55)
                context.fill(Path(skyRect), with: .color(Color(hex: 0x87CEEB)))

                // 모래 바닥
                let sandRect = CGRect(x: 0, y: size.height * 0.55, width: size.width, height: size.height * 0.45)
                context.fill(Path(sandRect), with: .color(Color(hex: 0xF4D9A0)))

                // 모래 텍스처
                let px: CGFloat = 5
                for x in stride(from: 0, to: size.width, by: px * 3) {
                    for y in stride(from: size.height * 0.55, to: size.height, by: px * 3) {
                        if Int(x + y) % 7 < 2 {
                            let rect = CGRect(x: x, y: y, width: px, height: px)
                            context.fill(Path(rect), with: .color(Color(hex: 0xE8C880).opacity(0.5)))
                        }
                    }
                }

                // 경계선
                let border = CGRect(x: 0, y: size.height * 0.55 - 3, width: size.width, height: 3)
                context.fill(Path(border), with: .color(Color(hex: 0xD4B880)))

                // 구름들 (움직임)
                let clouds: [(CGFloat, CGFloat, CGFloat)] = [
                    (0, 50, 6),
                    (size.width * 0.3, 30, 5),
                    (size.width * 0.55, 70, 7),
                    (size.width * 0.8, 45, 5),
                    (size.width * 0.15, 90, 4),
                ]
                for (baseX, y, cpx) in clouds {
                    let x = (baseX + cloudOffset).truncatingRemainder(dividingBy: size.width + 80) - 40
                    drawCloud(context: &context, x: x, y: y, px: cpx)
                }
            }
            .onChange(of: timeline.date) { _, _ in
                cloudOffset += 0.3
            }
        }
    }

    private func drawCloud(context: inout GraphicsContext, x: CGFloat, y: CGFloat, px: CGFloat) {
        let cloud: [(CGFloat, CGFloat)] = [
            (0, 0), (1, 0), (2, 0), (3, 0), (4, 0),
            (-1, -1), (0, -1), (1, -1), (2, -1), (3, -1), (4, -1), (5, -1),
            (0, -2), (1, -2), (2, -2), (3, -2), (4, -2),
            (1, -3), (2, -3), (3, -3),
        ]
        for (dx, dy) in cloud {
            let rect = CGRect(x: x + dx * px, y: y + dy * px, width: px, height: px)
            context.fill(Path(rect), with: .color(.white.opacity(0.6)))
        }
    }
}
