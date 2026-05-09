import SwiftUI

struct StatsBarView: View {
    let state: HamsterState

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            StatIndicator(icon: { PixelAppleIcon(size: 2.5) }, value: state.hunger, color: Color(hex: 0xff9642))
            StatIndicator(icon: { PixelHeartIcon(size: 2.5) }, value: state.happiness, color: Color(hex: 0xff6b9d))
            StatIndicator(icon: { PixelBoltIcon(size: 2.5) }, value: state.energy, color: Color(hex: 0xffd700))
        }
    }
}

private struct StatIndicator<Icon: View>: View {
    let icon: () -> Icon
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            icon()

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 55, height: 8)
                Rectangle()
                    .fill(color)
                    .frame(width: 55 * (value / 100), height: 8)
            }

            Text("\(Int(value))")
                .font(.custom("DOSSaemmul", size: 12))
                .foregroundStyle(.white)
                .frame(width: 24, alignment: .trailing)
        }
    }
}
