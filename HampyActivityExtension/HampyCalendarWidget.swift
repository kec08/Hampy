import SwiftUI
import WidgetKit

// MARK: - Widget 정의

struct HampyCalendarWidget: Widget {
    let kind = "HampyCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.35, green: 0.62, blue: 0.29) // 초원 배경 0x5a9e4a
                }
        }
        .configurationDisplayName("햄피 달력")
        .description("픽셀 달력과 함께하는 햄피")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Timeline Entry

struct CalendarEntry: TimelineEntry {
    let date: Date
    let emotion: String
}

// MARK: - Timeline Provider

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: .now, emotion: "happy")
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        let state = SharedStorage.load()
        completion(CalendarEntry(date: .now, emotion: state.currentEmotion.rawValue))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let state = SharedStorage.load()
        let entry = CalendarEntry(date: .now, emotion: state.currentEmotion.rawValue)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View (사이즈별 분기)

struct CalendarWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CalendarEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallCalendarView(entry: entry)
        case .systemMedium:
            MediumCalendarView(entry: entry)
        default:
            LargeCalendarView(entry: entry)
        }
    }
}

// MARK: - Small (오늘 날짜 + 햄피)

private struct SmallCalendarView: View {
    let entry: CalendarEntry

    private var calendar: Calendar { Calendar.current }
    private var month: Int { calendar.component(.month, from: entry.date) }
    private var day: Int { calendar.component(.day, from: entry.date) }
    private var weekdayIndex: Int { calendar.component(.weekday, from: entry.date) - 1 }
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 6) {
            // 월
            Text("\(month)월")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))

            // 오늘 날짜 (크게)
            Text("\(day)")
                .font(.system(size: 36, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white)

            // 요일
            Text(weekdays[weekdayIndex])
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0)) // 금색

            Spacer(minLength: 0)

            // 햄피
            Image(hampyImageName(entry.emotion))
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
        }
        .padding(10)
    }
}

// MARK: - Medium (달력 + 우측 햄피)

private struct MediumCalendarView: View {
    let entry: CalendarEntry

    var body: some View {
        HStack(spacing: 8) {
            // 좌측: 미니 달력
            MiniCalendarGrid(entry: entry)

            // 우측: 햄피 + 오늘 날짜
            VStack(spacing: 4) {
                Spacer(minLength: 0)

                Image(hampyImageName(entry.emotion))
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 52, height: 52)

                let day = Calendar.current.component(.day, from: entry.date)
                let month = Calendar.current.component(.month, from: entry.date)
                Text("\(month)/\(day)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Spacer(minLength: 0)
            }
            .frame(width: 70)
        }
        .padding(8)
    }
}

// MARK: - Large (전체 달력 + 하단 햄피)

private struct LargeCalendarView: View {
    let entry: CalendarEntry

    var body: some View {
        VStack(spacing: 4) {
            FullCalendarGrid(entry: entry)

            Spacer(minLength: 0)

            // 하단 햄피
            HStack {
                Spacer()
                Image(hampyImageName(entry.emotion))
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(10)
    }
}

// MARK: - 미니 달력 그리드 (Medium용)

private struct MiniCalendarGrid: View {
    let entry: CalendarEntry

    private var calendar: Calendar { Calendar.current }
    private var year: Int { calendar.component(.year, from: entry.date) }
    private var month: Int { calendar.component(.month, from: entry.date) }
    private var today: Int { calendar.component(.day, from: entry.date) }

    private var firstWeekday: Int {
        let comp = DateComponents(year: year, month: month, day: 1)
        return calendar.component(.weekday, from: calendar.date(from: comp)!)
    }

    private var daysInMonth: Int {
        let comp = DateComponents(year: year, month: month)
        return calendar.range(of: .day, in: .month, for: calendar.date(from: comp)!)!.count
    }

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 2) {
            // 월 헤더
            Text("\(month)월")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 요일
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdays[i])
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundStyle(weekdayColor(i))
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                    Text("").frame(height: 13)
                }
                ForEach(1...daysInMonth, id: \.self) { day in
                    let isToday = day == today
                    let wd = (firstWeekday - 1 + day - 1) % 7
                    Text("\(day)")
                        .font(.system(size: 8, weight: isToday ? .bold : .regular, design: .monospaced))
                        .foregroundStyle(dayColor(isToday: isToday, weekday: wd))
                        .frame(maxWidth: .infinity)
                        .frame(height: 13)
                        .background(
                            isToday ?
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.3))
                            : nil
                        )
                }
            }
        }
    }
}

// MARK: - 전체 달력 그리드 (Large용)

private struct FullCalendarGrid: View {
    let entry: CalendarEntry

    private var calendar: Calendar { Calendar.current }
    private var year: Int { calendar.component(.year, from: entry.date) }
    private var month: Int { calendar.component(.month, from: entry.date) }
    private var today: Int { calendar.component(.day, from: entry.date) }

    private var firstWeekday: Int {
        let comp = DateComponents(year: year, month: month, day: 1)
        return calendar.component(.weekday, from: calendar.date(from: comp)!)
    }

    private var daysInMonth: Int {
        let comp = DateComponents(year: year, month: month)
        return calendar.range(of: .day, in: .month, for: calendar.date(from: comp)!)!.count
    }

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 4) {
            // 년월 헤더
            Text("\(String(year))년 \(month)월")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 요일
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdays[i])
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(weekdayColor(i))
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                    Text("").frame(height: 20)
                }
                ForEach(1...daysInMonth, id: \.self) { day in
                    let isToday = day == today
                    let wd = (firstWeekday - 1 + day - 1) % 7
                    Text("\(day)")
                        .font(.system(size: 12, weight: isToday ? .bold : .regular, design: .monospaced))
                        .foregroundStyle(dayColor(isToday: isToday, weekday: wd))
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .background(
                            isToday ?
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                            : nil
                        )
                }
            }
        }
    }
}

// MARK: - 공통 헬퍼

private func hampyImageName(_ emotion: String) -> String {
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
    default: "hampy_happy"
    }
}

private func weekdayColor(_ index: Int) -> Color {
    if index == 0 { return Color(red: 1.0, green: 0.5, blue: 0.5) } // 일요일 연빨강
    if index == 6 { return Color(red: 0.5, green: 0.7, blue: 1.0) } // 토요일 연파랑
    return .white.opacity(0.7)
}

private func dayColor(isToday: Bool, weekday: Int) -> Color {
    if isToday { return .white }
    if weekday == 0 { return Color(red: 1.0, green: 0.5, blue: 0.5) }
    if weekday == 6 { return Color(red: 0.5, green: 0.7, blue: 1.0) }
    return .white.opacity(0.9)
}
