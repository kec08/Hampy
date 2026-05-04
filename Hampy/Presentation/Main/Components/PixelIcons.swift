import SwiftUI

// MARK: - 해바라기씨 아이콘 (10x10 현실적)

struct PixelSeedIcon: View {
    let size: CGFloat

    init(size: CGFloat = 3) { self.size = size }

    var body: some View {
        Canvas { context, _ in
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
            drawGrid(context: context, grid: grid, px: size) { char in
                switch char {
                case "O": Color(hex: 0x1a1a1a)
                case "D": Color(hex: 0x3d3d3d)
                case "L": Color(hex: 0xd4c9a8)
                default: nil
                }
            }
        }
        .frame(width: size * 10, height: size * 10)
    }
}

// MARK: - 쳇바퀴 아이콘 (10x10 현실적)

struct PixelWheelIcon: View {
    let size: CGFloat

    init(size: CGFloat = 3) { self.size = size }

    var body: some View {
        Canvas { context, _ in
            let grid: [[Character]] = [
                Array("...OOOO..."),
                Array("..O....O.."),
                Array(".O..OO..O."),
                Array("O..O..O..O"),
                Array("O.O.OO.O.O"),
                Array("O.O.OO.O.O"),
                Array("O..O..O..O"),
                Array(".O..OO..O."),
                Array("..O....O.."),
                Array("...OOOO..."),
            ]
            drawGrid(context: context, grid: grid, px: size) { char in
                char == "O" ? Color(hex: 0x8B7355) : nil
            }
        }
        .frame(width: size * 10, height: size * 10)
    }
}

// MARK: - 픽셀 사과 아이콘 (hunger)

struct PixelAppleIcon: View {
    let size: CGFloat

    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Canvas { context, _ in
            let grid: [[Character]] = [
                Array("...G...."),
                Array("..GG...."),
                Array(".RRRR..."),
                Array("RRRRRR.."),
                Array("RRHRRR.."),
                Array("RRRRRR.."),
                Array(".RRRR..."),
                Array("..RR...."),
            ]
            drawGrid(context: context, grid: grid, px: size) { char in
                switch char {
                case "R": Color(hex: 0xff4444)
                case "G": Color(hex: 0x4ecdc4)
                case "H": Color(hex: 0xff8888)
                default: nil
                }
            }
        }
        .frame(width: size * 8, height: size * 8)
    }
}

// MARK: - 픽셀 하트 아이콘 (happiness)

struct PixelHeartIcon: View {
    let size: CGFloat

    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Canvas { context, _ in
            let grid: [[Character]] = [
                Array(".RR.RR.."),
                Array("RRRRRR.."),
                Array("RHRRRR.."),
                Array("RRRRRR.."),
                Array(".RRRR..."),
                Array("..RR...."),
                Array("........"),
                Array("........"),
            ]
            drawGrid(context: context, grid: grid, px: size) { char in
                switch char {
                case "R": Color(hex: 0xff6b9d)
                case "H": Color(hex: 0xffaacc)
                default: nil
                }
            }
        }
        .frame(width: size * 8, height: size * 8)
    }
}

// MARK: - 픽셀 번개 아이콘 (energy)

struct PixelBoltIcon: View {
    let size: CGFloat

    init(size: CGFloat = 2) { self.size = size }

    var body: some View {
        Canvas { context, _ in
            let grid: [[Character]] = [
                Array("...YY..."),
                Array("..YY...."),
                Array(".YY....."),
                Array("YYYYY..."),
                Array("..YY...."),
                Array(".YY....."),
                Array("YY......"),
                Array("........"),
            ]
            drawGrid(context: context, grid: grid, px: size) { char in
                char == "Y" ? Color(hex: 0xffd700) : nil
            }
        }
        .frame(width: size * 8, height: size * 8)
    }
}

// MARK: - 공통 그리드 드로잉

private func drawGrid(
    context: GraphicsContext,
    grid: [[Character]],
    px: CGFloat,
    colorMap: (Character) -> Color?
) {
    for row in 0..<grid.count {
        for col in 0..<grid[row].count {
            guard let color = colorMap(grid[row][col]) else { continue }
            let rect = CGRect(x: CGFloat(col) * px, y: CGFloat(row) * px, width: px, height: px)
            context.fill(Path(rect), with: .color(color))
        }
    }
}
