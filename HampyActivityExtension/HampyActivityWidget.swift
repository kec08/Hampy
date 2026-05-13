import ActivityKit
import SwiftUI
import WidgetKit
import AppIntents

struct HampyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HampyActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .padding()
                .activityBackgroundTint(.black.opacity(0.9))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded: 햄스터 가운데 + 상태 + 버튼
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 10) {
                        // 햄스터 (가운데)
                        IslandPixelHamster(emotion: context.state.emotion, renderSize: 0)
                            .frame(width: 50, height: 50)

                        // 상태창
                        HStack(spacing: 8) {
                            IslandStatMini(label: "HGR", value: context.state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                            IslandStatMini(label: "HPY", value: context.state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                            IslandStatMini(label: "ENG", value: context.state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    let canFeed = context.state.remainingFeeds > 0
                    HStack(spacing: 10) {
                        Button(intent: FeedHampyIntent()) {
                            HStack(spacing: 4) {
                                Image("SeedIcon")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("밥주기")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                Text("x\(context.state.remainingFeeds)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(canFeed ? .yellow : .gray)
                            }
                            .foregroundStyle(canFeed ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(canFeed ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canFeed)

                        Button(intent: PetHampyIntent()) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.pink)
                                Text("쓰다듬기")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
            } compactLeading: {
                IslandPixelHamster(emotion: context.state.emotion, renderSize: 0)
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                HStack(spacing: 2) {
                    MiniBar(value: context.state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                    MiniBar(value: context.state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                    MiniBar(value: context.state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                }
            } minimal: {
                IslandPixelHamster(emotion: context.state.emotion, renderSize: 0)
                    .frame(width: 18, height: 18)
            }
        }
    }
}

// MARK: - 에셋 기반 햄스터

private struct IslandPixelHamster: View {
    let emotion: String
    let renderSize: CGFloat // 호환용 (사용 안 함)

    private var imageName: String {
        switch emotion {
        case "happy": "hampy_happy"
        case "hungry": "hampy_hungry"
        case "tired": "hampy_tired"
        case "upset": "hampy_upset"
        case "eating": "hampy_eating"
        case "yummy": "hampy_yummy"
        case "love": "hampy_love"
        case "surprised": "hampy_surprised"
        case "angry": "hampy_angry"
        case "annoyed": "hampy_annoyed"
        case "blank": "hampy_blank"
        case "bored": "hampy_bored"
        case "curious": "hampy_curious"
        default: "hampy_happy"
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Lock Screen

private struct LockScreenView: View {
    let state: HampyActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            IslandPixelHamster(emotion: state.emotion, renderSize: 0)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    IslandStatMini(label: "HGR", value: state.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                    IslandStatMini(label: "HPY", value: state.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                    IslandStatMini(label: "ENG", value: state.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                }
            }
        }
    }
}

// MARK: - 미니 스탯

private struct IslandStatMini: View {
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
                    .frame(width: 28, height: 4)
                Rectangle()
                    .fill(color)
                    .frame(width: 28 * (value / 100), height: 4)
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
