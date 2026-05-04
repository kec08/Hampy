import SwiftUI

struct WheelView: View {
    @Environment(HamsterService.self) private var service
    @State private var viewModel: WheelViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: 0x5a9e4a)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // 상단
                HStack {
                    Button(action: { dismiss() }) {
                        Text("돌아가기")
                            .font(.custom("DOSGothic", size: 16))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        PixelBoltIcon(size: 2.5)
                        Text("\(Int(service.state.energy))")
                            .font(.custom("DOSGothic", size: 16))
                            .foregroundStyle(Color(hex: 0xffd700))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                if let vm = viewModel {
                    // 쳇바퀴 + 햄스터 조합
                    ZStack {
                        // 쳇바퀴 (옆면, 나무 베이지)
                        SideWheel(angle: vm.rotationAngle)
                            .frame(width: 220, height: 220)

                        // 햄스터 (쳇바퀴 바닥에 붙어서 달림)
                        RunningHampy(isRunning: vm.isRunning, speed: vm.speed)
                            .offset(y: 50)
                    }

                    // 거치대
                    WheelStand()
                        .frame(width: 240, height: 40)
                        .offset(y: -8)

                    // 속도 게이지
                    SpeedBar(speed: vm.speed, maxSpeed: 10.0)
                        .frame(height: 12)
                        .padding(.horizontal, 40)

                    // 상태 텍스트
                    Group {
                        if vm.isTired {
                            Text("지쳤다... 쉬어야 해")
                                .foregroundStyle(Color(hex: 0xff9642))
                        } else if vm.isRunning {
                            Text("달리는 중! 탭탭탭!")
                                .foregroundStyle(Color(hex: 0xffd700))
                        } else {
                            Text("화면을 탭해서 달리기!")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .font(.custom("DOSGothic", size: 16))
                }

                Spacer()
            }
            .padding(.top, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel?.tap()
            }
        }
        .onAppear { viewModel = WheelViewModel(service: service) }
    }
}

// MARK: - 옆에서 본 쳇바퀴 (나무 베이지)

private struct SideWheel: View {
    let angle: Double

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let radius: CGFloat = 95
            let px: CGFloat = 4

            // 외곽 원 (나무 베이지)
            for i in stride(from: 0, to: 360, by: 2) {
                let rad = Double(i) * .pi / 180
                let x = cx + radius * cos(rad)
                let y = cy + radius * sin(rad)
                let rect = CGRect(x: x - px/2, y: y - px/2, width: px, height: px)
                context.fill(Path(rect), with: .color(Color(hex: 0xD2B48C)))
            }

            // 안쪽 트랙
            let innerR = radius - 14
            for i in stride(from: 0, to: 360, by: 3) {
                let rad = Double(i) * .pi / 180
                let x = cx + innerR * cos(rad)
                let y = cy + innerR * sin(rad)
                let rect = CGRect(x: x - px/2, y: y - px/2, width: px, height: px)
                context.fill(Path(rect), with: .color(Color(hex: 0xC4A882).opacity(0.4)))
            }

            // 살 (스포크) 회전 - 나무색
            for i in 0..<6 {
                let baseAngle = (Double(i) * 60 + angle) * .pi / 180
                for step in stride(from: 8.0, to: radius - 4, by: px + 1) {
                    let x = cx + step * cos(baseAngle)
                    let y = cy + step * sin(baseAngle)
                    let rect = CGRect(x: x - px/2, y: y - px/2, width: px, height: px)
                    context.fill(Path(rect), with: .color(Color(hex: 0xC4A882).opacity(0.6)))
                }
            }

            // 중심 축
            let axle: CGFloat = 10
            let axleRect = CGRect(x: cx - axle/2, y: cy - axle/2, width: axle, height: axle)
            context.fill(Path(axleRect), with: .color(Color(hex: 0x8B7355)))
        }
    }
}

// MARK: - 달리는 햄스터 (다리 모션)

private struct RunningHampy: View {
    let isRunning: Bool
    let speed: Double

    @State private var legToggle = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: speed > 0 ? max(0.06, 0.3 - speed * 0.025) : 1.0)) { timeline in
            Canvas { context, size in
                let px: CGFloat = 4
                let grid = isRunning ? (legToggle ? runFrame1 : runFrame2) : idleFrame
                let gridW = CGFloat(grid[0].count) * px
                let gridH = CGFloat(grid.count) * px
                let ox = (size.width - gridW) / 2
                let oy = (size.height - gridH) / 2

                for row in 0..<grid.count {
                    for col in 0..<grid[row].count {
                        let char = grid[row][col]
                        guard let color = hamColor(char) else { continue }
                        let rect = CGRect(x: ox + CGFloat(col) * px, y: oy + CGFloat(row) * px, width: px, height: px)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
            .frame(width: 80, height: 60)
            .onChange(of: timeline.date) { _, _ in
                if isRunning { legToggle.toggle() }
            }
        }
    }

    private func hamColor(_ char: Character) -> Color? {
        switch char {
        case "E": return Color(hex: 0x5c3a1e)
        case "B": return Color(hex: 0xf5c882)
        case "L": return Color(hex: 0xfff4e0)
        case "P": return Color(hex: 0xff8fa0)
        case "K": return Color(hex: 0x1a1a1a)
        case "H": return Color(hex: 0xffffff)
        case "W": return Color(hex: 0xc4944a)
        default: return nil
        }
    }

    // 달리기1
    private var runFrame1: [[Character]] {
        [
            Array("..EE..EE...."),
            Array(".EEEE.EEE..."),
            Array(".EBBB.BBBE.."),
            Array("EBBBBBBBBEE."),
            Array("EBBHKBBHKEE."),
            Array("EBBKKBBKKEE."),
            Array("EBPBBWBBPBE."),
            Array("EBBLLLLLLBE."),
            Array(".EBLLLLLBE.."),
            Array("..EE..EBE..."),
            Array("..E....EE..."),
        ]
    }

    // 달리기2
    private var runFrame2: [[Character]] {
        [
            Array("..EE..EE...."),
            Array(".EEEE.EEE..."),
            Array(".EBBB.BBBE.."),
            Array("EBBBBBBBBEE."),
            Array("EBBHKBBHKEE."),
            Array("EBBKKBBKKEE."),
            Array("EBPBBWBBPBE."),
            Array("EBBLLLLLLBE."),
            Array(".EBLLLLLBE.."),
            Array("...EBE.EE..."),
            Array("...EE..E...."),
        ]
    }

    // 멈춤
    private var idleFrame: [[Character]] {
        [
            Array("..EE..EE...."),
            Array(".EEEE.EEE..."),
            Array(".EBBB.BBBE.."),
            Array("EBBBBBBBBEE."),
            Array("EBBHKBBHKEE."),
            Array("EBBKKBBKKEE."),
            Array("EBPBBWBBPBE."),
            Array("EBBLLLLLLBE."),
            Array(".EBLLLLLBE.."),
            Array("..EE..EE...."),
            Array("..EE..EE...."),
        ]
    }
}

// MARK: - 거치대

private struct WheelStand: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2

            // 왼쪽 다리
            let left = Path { p in
                p.move(to: CGPoint(x: cx - 15, y: 0))
                p.addLine(to: CGPoint(x: cx - 50, y: size.height))
                p.addLine(to: CGPoint(x: cx - 44, y: size.height))
                p.addLine(to: CGPoint(x: cx - 9, y: 0))
                p.closeSubpath()
            }
            context.fill(left, with: .color(Color(hex: 0x8B7355)))

            // 오른쪽 다리
            let right = Path { p in
                p.move(to: CGPoint(x: cx + 15, y: 0))
                p.addLine(to: CGPoint(x: cx + 50, y: size.height))
                p.addLine(to: CGPoint(x: cx + 44, y: size.height))
                p.addLine(to: CGPoint(x: cx + 9, y: 0))
                p.closeSubpath()
            }
            context.fill(right, with: .color(Color(hex: 0x8B7355)))

            // 바닥
            let base = CGRect(x: cx - 55, y: size.height - 4, width: 110, height: 4)
            context.fill(Path(base), with: .color(Color(hex: 0x6B5B3E)))
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
