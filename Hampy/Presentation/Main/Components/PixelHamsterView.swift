import SwiftUI

/// 16x16 픽셀 햄스터 (원본 스타일 + 치즈색 + 물광 눈)
struct PixelHamsterView: View {
    let emotion: HamsterEmotion
    let pixelSize: CGFloat

    init(emotion: HamsterEmotion, pixelSize: CGFloat = 4) {
        self.emotion = emotion
        self.pixelSize = pixelSize
    }

    var body: some View {
        Canvas { context, size in
            let grid = spriteData(for: emotion)
            for row in 0..<grid.count {
                let rowData = grid[row]
                for col in 0..<rowData.count {
                    let char = rowData[col]
                    guard let color = colorForPixel(char) else { continue }
                    let rect = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: pixelSize * 16, height: pixelSize * 16)
    }

    private func colorForPixel(_ char: Character) -> Color? {
        switch char {
        case "E": return Color(hex: 0x5c3a1e) // 외곽선
        case "B": return Color(hex: 0xf5c882) // 몸통 치즈
        case "D": return Color(hex: 0xc4944a) // 몸통 어두운
        case "K": return Color(hex: 0x1a1a1a) // 눈
        case "H": return Color(hex: 0xffffff) // 눈 물광
        case "P": return Color(hex: 0xff8fa0) // 볼
        case "W": return Color(hex: 0xc4944a) // 입
        case "L": return Color(hex: 0xfff4e0) // 배
        case "M": return Color(hex: 0x8B4513) // 입(열린)
        default: return nil
        }
    }

    private func spriteData(for emotion: HamsterEmotion) -> [[Character]] {
        let raw: String
        switch emotion {
        case .happy:  raw = happySprite
        case .hungry: raw = hungrySprite
        case .tired:  raw = tiredSprite
        case .upset:  raw = upsetSprite
        case .eating: raw = eatingSprite
        }
        return raw.split(separator: "\n").map { Array($0) }
    }

    // 행복
    private var happySprite: String {
        """
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
        ...EEEEEEEEEE..
        .....EE..EE.....
        """
    }

    // 배고픔
    private var hungrySprite: String {
        """
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
        ...EEEEEEEEEE..
        .....EE..EE.....
        """
    }

    // 피곤
    private var tiredSprite: String {
        """
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
        ...EEEEEEEEEE..
        .....EE..EE.....
        """
    }

    // 삐짐
    private var upsetSprite: String {
        """
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
        ...EEEEEEEEEE..
        .....EE..EE.....
        """
    }

    // 먹기 - 씹는 모션 (프레임 토글)
    private var eatingSprite: String {
        // 프레임 토글 기반으로 뺨 크기 변경
        let time = Int(Date.now.timeIntervalSince1970 * 3) % 2
        if time == 0 {
            return """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBEEBBBBEEBEE.
            EBBBBBBBBBBBBBBE
            EBBBBBBBBBBBBBBE
            EBPBBBBBBBBBBPBE
            EPPBBBBBBBBBPPEE
            EBBBBBBMMBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ...EEEEEEEEEE..
            .....EE..EE.....
            """
        } else {
            return """
            ....EE....EE....
            ...EEEE..EEEE...
            ...EBBB..BBBE...
            ..EBBBBBBBBBBEE.
            .EBBBBBBBBBBBEE.
            .EBBEEBBBBEEBEE.
            EBBBBBBBBBBBBBBE
            EBBBBBBBBBBBBBBE
            PPPPBBBBBBBPPPBE
            PPPPBBBBBBBPPPEE
            EBBBBBBMMBBBBBBE
            .EBBBLLLLLLLBBE.
            .EBBBLLLLLLLBBE.
            ..EBBBBBBBBBEE..
            ...EEEEEEEEEE..
            .....EE..EE.....
            """
        }
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
