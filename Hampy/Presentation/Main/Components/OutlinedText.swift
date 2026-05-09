import SwiftUI

/// 검정 테두리 텍스트
struct OutlinedText: View {
    let text: String
    let size: CGFloat
    let color: Color
    let outlineWidth: CGFloat

    init(_ text: String, size: CGFloat = 14, color: Color = .white, outlineWidth: CGFloat = 1) {
        self.text = text
        self.size = size
        self.color = color
        self.outlineWidth = outlineWidth
    }

    var body: some View {
        ZStack {
            // 검정 테두리 (4방향)
            ForEach([-outlineWidth, outlineWidth], id: \.self) { x in
                ForEach([-outlineWidth, outlineWidth], id: \.self) { y in
                    Text(text)
                        .font(.custom("DOSSaemmul", size: size))
                        .foregroundStyle(.black)
                        .offset(x: x, y: y)
                }
            }
            // 본문
            Text(text)
                .font(.custom("DOSSaemmul", size: size))
                .foregroundStyle(color)
        }
    }
}
