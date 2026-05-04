import ActivityKit
import SwiftUI
import WidgetKit

struct HampyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HampyActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .padding()
                .activityBackgroundTint(.black.opacity(0.9))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    IslandPixelHamster(emotion: context.state.emotion, renderSize: 3)
                        .scaleEffect(0.8)
                        .frame(width: 40, height: 40)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        IslandStatBar(label: "HGR", value: context.state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                        IslandStatBar(label: "HPY", value: context.state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                        IslandStatBar(label: "ENG", value: context.state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    IslandGrass()
                        .frame(height: 18)
                }
            } compactLeading: {
                IslandPixelHamster(emotion: context.state.emotion, renderSize: 2)
                    .scaleEffect(0.7)
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                HStack(spacing: 2) {
                    MiniBar(value: context.state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                    MiniBar(value: context.state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                    MiniBar(value: context.state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                }
            } minimal: {
                IslandPixelHamster(emotion: context.state.emotion, renderSize: 2)
                    .scaleEffect(0.55)
                    .frame(width: 18, height: 18)
            }
        }
    }
}

// MARK: - 픽셀 햄스터 (안전한 반복)

private struct IslandPixelHamster: View {
    let emotion: String
    let renderSize: CGFloat // 정수만 사용 (2, 3 등)

    var body: some View {
        Canvas { context, _ in
            let grid = spriteForEmotion(emotion)
            for row in 0..<grid.count {
                let rowData = grid[row]
                for col in 0..<rowData.count {
                    let char = rowData[col]
                    guard let color = pixelColor(char) else { continue }
                    let rect = CGRect(
                        x: CGFloat(col) * renderSize,
                        y: CGFloat(row) * renderSize,
                        width: renderSize,
                        height: renderSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: renderSize * 16, height: renderSize * 16)
    }

    private func pixelColor(_ char: Character) -> Color? {
        switch char {
        case "E": return Color(red: 0.36, green: 0.23, blue: 0.12)
        case "B": return Color(red: 0.96, green: 0.78, blue: 0.51)
        case "K": return Color(red: 0.1, green: 0.1, blue: 0.1)
        case "H": return Color(red: 1.0, green: 1.0, blue: 1.0)
        case "P": return Color(red: 1.0, green: 0.56, blue: 0.63)
        case "W": return Color(red: 0.77, green: 0.58, blue: 0.29)
        case "L": return Color(red: 1.0, green: 0.96, blue: 0.88)
        case "M": return Color(red: 0.55, green: 0.27, blue: 0.07)
        default: return nil
        }
    }

    private func spriteForEmotion(_ emotion: String) -> [[Character]] {
        let raw: String
        switch emotion {
        case "happy":
            raw = """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBHKBBBBHKBEE.
            EBBBKKBBBBKKBBEE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EBBBBBBWWBBBBBBE
            EBBBBBBBBBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ....EEEEEEEE....
            .....EE..EE.....
            """
        case "hungry":
            raw = """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBHKBBBBHKBEE.
            EBBBKKBBBBKKBBEE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EBBBBBBMMBBBBBBE
            EBBBBBBMMBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ....EEEEEEEE....
            .....EE..EE.....
            """
        case "tired":
            raw = """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBEEBBBBEEBBE.
            EBBBBBBBBBBBBBBE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EBBBBBBWBBBBBBEE
            EBBBBBBBBBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ....EEEEEEEE....
            .....EE..EE.....
            """
        case "upset":
            raw = """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBEBBBBBBBBEBE.
            .EBBHKBBBBHKBEE.
            EBBBKKBBBBKKBBEE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EBBBBBBBBBBBBBBE
            EBBBBBBWWBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ....EEEEEEEE....
            .....EE..EE.....
            """
        default:
            raw = """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBHKBBBBHKBEE.
            EBBBKKBBBBKKBBEE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EBBBBBBWWBBBBBBE
            EBBBBBBBBBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ....EEEEEEEE....
            .....EE..EE.....
            """
        }
        return raw.split(separator: "\n").map { Array($0) }
    }
}

// MARK: - Lock Screen

private struct LockScreenView: View {
    let state: HampyActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            IslandPixelHamster(emotion: state.emotion, renderSize: 3)
                .scaleEffect(0.8)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                IslandStatBar(label: "HGR", value: state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                IslandStatBar(label: "HPY", value: state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                IslandStatBar(label: "ENG", value: state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
            }
        }
    }
}

// MARK: - 스탯 바

private struct IslandStatBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 36, height: 5)
                Rectangle()
                    .fill(color)
                    .frame(width: 36 * (value / 100), height: 5)
            }
        }
    }
}

// MARK: - 풀 + 꽃

private struct IslandGrass: View {
    var body: some View {
        Canvas { context, size in
            // 풀
            let grassRect = CGRect(x: 0, y: size.height - 10, width: size.width, height: 10)
            context.fill(Path(grassRect), with: .color(Color(red: 0.3, green: 0.6, blue: 0.25)))

            // 꽃 3개
            let px: CGFloat = 2
            let positions: [CGFloat] = [size.width * 0.2, size.width * 0.5, size.width * 0.8]
            for x in positions {
                let y = size.height - 8
                let offsets: [(CGFloat, CGFloat)] = [(0, -px), (px, 0), (0, px), (-px, 0)]
                for (dx, dy) in offsets {
                    let rect = CGRect(x: x + dx, y: y + dy, width: px, height: px)
                    context.fill(Path(rect), with: .color(.white.opacity(0.7)))
                }
                let center = CGRect(x: x, y: y, width: px, height: px)
                context.fill(Path(center), with: .color(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8)))
            }
        }
    }
}

// MARK: - 미니 바

private struct MiniBar: View {
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(color)
                .frame(width: 3, height: CGFloat(value / 100) * 16)
        }
        .frame(width: 3, height: 16)
    }
}
