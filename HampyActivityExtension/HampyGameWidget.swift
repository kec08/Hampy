import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Widget 정의

struct HampyGameWidget: Widget {
    let kind = "HampyGameWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GameWidgetProvider()) { entry in
            GameWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.35, green: 0.62, blue: 0.29)
                }
        }
        .configurationDisplayName("햄피 게임")
        .description("위젯에서 직접 햄피를 키워보세요!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry

struct GameWidgetEntry: TimelineEntry {
    let date: Date
    let hunger: Double
    let happiness: Double
    let energy: Double
    let emotion: String
    let feedStock: Int
    let level: Int
}

// MARK: - Provider

struct GameWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GameWidgetEntry {
        GameWidgetEntry(date: .now, hunger: 80, happiness: 80, energy: 80, emotion: "happy", feedStock: 10, level: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (GameWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GameWidgetEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> GameWidgetEntry {
        var state = SharedStorage.load()
        state.refillFeedStock()

        let reaction = SharedStorage.shared.string(forKey: "widget_reaction") ?? ""
        let displayEmotion = reaction.isEmpty ? state.currentEmotion.rawValue : reaction

        return GameWidgetEntry(
            date: .now,
            hunger: state.hunger,
            happiness: state.happiness,
            energy: state.energy,
            emotion: displayEmotion,
            feedStock: state.feedStock,
            level: state.level
        )
    }
}

// MARK: - View 분기

struct GameWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: GameWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallGameView(entry: entry)
        default:
            MediumGameView(entry: entry)
        }
    }
}

// MARK: - Small

private struct SmallGameView: View {
    let entry: GameWidgetEntry

    var body: some View {
        VStack(spacing: 0) {
            // 상단
            HStack(alignment: .top) {
                Text("Lv.\(entry.level)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    PixelMiniBar(value: entry.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                    PixelMiniBar(value: entry.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                    PixelMiniBar(value: entry.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                }
            }

            Spacer()

            // 햄피
            Image(emotionImage(entry.emotion))
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .frame(width: 46, height: 46)
                .invalidatableContent()

            Spacer()

            // 하단: 3개 버튼 (동일 크기)
            HStack(spacing: 4) {
                Button(intent: WidgetFeedIntent()) {
                    JoyBtn(icon: "🌻", color: Color(red: 1.0, green: 0.59, blue: 0.26))
                }
                .buttonStyle(.plain)

                Button(intent: WidgetPetIntent()) {
                    JoyBtn(icon: "❤️", color: Color(red: 1.0, green: 0.42, blue: 0.61))
                }
                .buttonStyle(.plain)

                Button(intent: WidgetExerciseIntent()) {
                    JoyBtn(icon: "💪", color: Color(red: 0.31, green: 0.8, blue: 0.77))
                }
                .buttonStyle(.plain)
            }
            .frame(height: 32)
        }
        .padding(8)
    }
}

// MARK: - Medium

private struct MediumGameView: View {
    let entry: GameWidgetEntry

    var body: some View {
        HStack(spacing: 6) {
            // 좌: 스크린
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.24, green: 0.54, blue: 0.19))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.16, green: 0.36, blue: 0.12), lineWidth: 3)
                    )

                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        Text("Lv.\(entry.level)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            PixelStatRow(label: "HP", value: entry.hunger, color: Color(red: 1.0, green: 0.59, blue: 0.26))
                            PixelStatRow(label: "LV", value: entry.happiness, color: Color(red: 1.0, green: 0.42, blue: 0.61))
                            PixelStatRow(label: "EN", value: entry.energy, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                        }
                    }

                    Spacer()

                    Image(emotionImage(entry.emotion))
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .invalidatableContent()

                    Spacer()
                }
                .padding(8)
            }

            // 우: 게임패드
            VStack(spacing: 0) {
                // 상단 버튼 (밥)
                Button(intent: WidgetFeedIntent()) {
                    PadBtn(icon: "🌻", label: "\(entry.feedStock)", color: Color(red: 1.0, green: 0.59, blue: 0.26))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 4)

                // 중단: 좌(쓰담) 우(운동) 나란히
                HStack(spacing: 4) {
                    Button(intent: WidgetPetIntent()) {
                        PadCircle(icon: "❤️", color: Color(red: 1.0, green: 0.42, blue: 0.61))
                    }
                    .buttonStyle(.plain)

                    Button(intent: WidgetExerciseIntent()) {
                        PadCircle(icon: "💪", color: Color(red: 0.31, green: 0.8, blue: 0.77))
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 4)

                // 하단: 먹이 개수
                Text("🌻x\(entry.feedStock)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(width: 76)
            .padding(.vertical, 6)
        }
        .padding(6)
    }
}

// MARK: - 조이스틱 버튼 (Small 공통)

private struct JoyBtn: View {
    let icon: String
    let color: Color

    var body: some View {
        Text(icon)
            .font(.system(size: 14))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    // 그림자 (눌린 느낌)
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .offset(y: 2)
                    // 외곽
                    Circle()
                        .fill(color.opacity(0.3))
                    // 내부
                    Circle()
                        .fill(color.opacity(0.7))
                        .padding(3)
                    // 하이라이트
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(4)
                }
            )
    }
}

// MARK: - 패드 버튼 (Medium 상단 직사각)

private struct PadBtn: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 14))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.4))
                    .offset(y: 2)
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(color.opacity(0.9), lineWidth: 1.5)
                    )
                // 하이라이트
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .padding(2)
            }
        )
    }
}

// MARK: - 패드 원형 버튼 (Medium 좌우)

private struct PadCircle: View {
    let icon: String
    let color: Color

    var body: some View {
        Text(icon)
            .font(.system(size: 16))
            .frame(width: 36, height: 36)
            .background(
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .offset(y: 2)
                    Circle()
                        .fill(color.opacity(0.3))
                    Circle()
                        .fill(color.opacity(0.7))
                        .padding(3)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.35), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(5)
                }
            )
    }
}

// MARK: - 미니 바 (Small)

private struct PixelMiniBar: View {
    let value: Double
    let color: Color

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(width: 30, height: 4)
            Rectangle()
                .fill(color)
                .frame(width: max(1, 30 * (value / 100)), height: 4)
        }
    }
}

// MARK: - 스탯 행 (Medium)

private struct PixelStatRow: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 36, height: 5)
                Rectangle()
                    .fill(color)
                    .frame(width: max(1, 36 * (value / 100)), height: 5)
            }
        }
    }
}

// MARK: - 헬퍼

private func emotionImage(_ emotion: String) -> String {
    switch emotion {
    case "hungry": "hampy_hungry"
    case "tired": "hampy_tired"
    case "upset": "hampy_upset"
    case "eating": "hampy_eating"
    case "angry": "hampy_angry"
    case "annoyed": "hampy_annoyed"
    case "blank": "hampy_blank"
    case "bored": "hampy_bored"
    case "curious": "hampy_curious"
    case "love": "hampy_love"
    case "yummy": "hampy_yummy"
    case "surprised": "hampy_surprised"
    case "running": "hampy_run1"
    default: "hampy_happy"
    }
}
