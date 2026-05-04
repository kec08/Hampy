import SwiftUI

struct HampyView: View {
    let emotion: HamsterEmotion
    var onPet: () -> Void = {}
    var onTap: () -> Void = {}

    @State private var reactionState: ReactionState = .none
    @State private var frameToggle: Bool = false
    @State private var wiggleAngle: Double = 0

    // 하트
    @State private var showHeart = false
    @State private var heartOffset: CGFloat = 0
    @State private var heartOpacity: Double = 0

    // !?
    @State private var showSurprise = false
    @State private var surpriseOffset: CGFloat = 0
    @State private var surpriseOpacity: Double = 0

    var body: some View {
        ZStack {
            // 하트 (크게, 위로 떠오름)
            if showHeart {
                PixelHeartIcon(size: 4)
                    .offset(y: -80 + heartOffset)
                    .opacity(heartOpacity)
            }

            // !? (더 위에)
            if showSurprise {
                PixelSurpriseIcon(size: 5)
                    .offset(y: -100 + surpriseOffset)
                    .opacity(surpriseOpacity)
            }

            // 햄스터
            PixelHamsterView(emotion: displayEmotion, pixelSize: 9)
                .offset(y: frameToggle ? -3 : 0)
                .rotationEffect(.degrees(wiggleAngle))
                .gesture(petGesture)
                .onTapGesture { triggerSurprise() }
        }
        .frame(width: 160, height: 220)
        .onAppear { startIdleAnimation() }
    }

    private var displayEmotion: HamsterEmotion {
        switch reactionState {
        case .petted: return .happy
        case .surprised: return .upset
        case .none: return emotion
        }
    }

    // MARK: - 쓰다듬기

    private var petGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                wiggleAngle = sin(value.translation.width / 10) * 5
            }
            .onEnded { _ in triggerPetReaction() }
    }

    private func triggerPetReaction() {
        onPet()
        reactionState = .petted
        withAnimation(.easeInOut(duration: 0.2)) { wiggleAngle = 0 }

        // 하트 떠오르기
        showHeart = true
        heartOffset = 0
        heartOpacity = 1.0
        withAnimation(.easeOut(duration: 1.0)) {
            heartOffset = -50
            heartOpacity = 0
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            showHeart = false
            reactionState = .none
        }
    }

    // MARK: - 놀람

    private func triggerSurprise() {
        onTap()
        reactionState = .surprised

        // !? 떠오르기
        showSurprise = true
        surpriseOffset = 0
        surpriseOpacity = 1.0
        withAnimation(.easeOut(duration: 1.0)) {
            surpriseOffset = -40
            surpriseOpacity = 0
        }

        withAnimation(.easeInOut(duration: 0.05).repeatCount(8, autoreverses: true)) {
            wiggleAngle = 8
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation { wiggleAngle = 0 }
            try? await Task.sleep(for: .seconds(0.7))
            showSurprise = false
            reactionState = .none
        }
    }

    private func startIdleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            frameToggle.toggle()
        }
    }
}

private enum ReactionState {
    case none, petted, surprised
}

// MARK: - 픽셀 !? 아이콘

private struct PixelSurpriseIcon: View {
    let size: CGFloat

    var body: some View {
        Canvas { context, _ in
            // !  ?
            let grid: [[Character]] = [
                Array(".Y..YYY."),
                Array(".Y.Y...Y"),
                Array(".Y....Y."),
                Array(".Y...Y.."),
                Array("........"),
                Array(".Y...Y.."),
            ]
            for row in 0..<grid.count {
                for col in 0..<grid[row].count {
                    guard grid[row][col] == "Y" else { continue }
                    let rect = CGRect(x: CGFloat(col) * size, y: CGFloat(row) * size, width: size, height: size)
                    context.fill(Path(rect), with: .color(Color(hex: 0xffd700)))
                }
            }
        }
        .frame(width: size * 8, height: size * 6)
    }
}
