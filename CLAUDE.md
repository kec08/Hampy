# Hampy - CLAUDE.md

## 프로젝트 정보
- 앱: 햄피 (Hampy) - 다이나믹 아일랜드 햄스터 가상펫
- Bundle ID: `com.eunchan.hampy`
- 플랫폼: iOS 17.0+ (iPhone 전용)
- 언어: Swift 5.9+, SwiftUI
- 아키텍처: MVVM + Service Layer
- 1인 개발 프로젝트

## 기술 스택
- UI: SwiftUI
- 상태 관리: Combine + @Observable
- Live Activity: ActivityKit + WidgetKit
- 백그라운드: BGAppRefreshTask
- 로컬 저장: UserDefaults
- 애니메이션: SwiftUI Animation + TimelineView (스프라이트)
- 서버: 없음 (완전 로컬)

## 폴더 구조
```
Hampy/
├── App/
│   └── HampyApp.swift
├── Presentation/
│   ├── Main/
│   │   ├── MainView.swift
│   │   ├── MainViewModel.swift
│   │   └── Components/
│   │       ├── HampyView.swift        # 스프라이트 + 제스처
│   │       ├── StatsBarView.swift     # 스탯 바 UI
│   │       └── ActionBarView.swift    # 먹이/쳇바퀴 버튼
│   └── Wheel/
│       ├── WheelView.swift
│       └── WheelViewModel.swift
├── Domain/
│   ├── HamsterState.swift             # 핵심 상태 모델
│   └── HamsterEmotion.swift           # 감정 enum
├── Services/
│   ├── HamsterService.swift           # 스탯 계산 + UserDefaults
│   └── LiveActivityService.swift      # ActivityKit 관리
├── Resources/
│   └── Sprites/                       # 픽셀아트 PNG
└── ActivityExtension/                 # Live Activity Target
    ├── HampyActivityWidget.swift
    └── HampyActivityAttributes.swift
```

## 핵심 모델
```swift
struct HamsterState: Codable {
    var hunger: Double       // 0~100, 시간 경과로 감소
    var happiness: Double    // 0~100, 방치 시 감소
    var energy: Double       // 0~100, 쳇바퀴 시 감소 / 수면 회복
    var lastUpdated: Date    // 백그라운드 경과 계산용
}
```

## 감정 상태 조건
| 상태 | 조건 |
|------|------|
| Happy | hunger > 60, happiness > 60 |
| Hungry | hunger < 30 |
| Tired | energy < 30 |
| Upset | happiness < 20 |
| Eating | 먹이주기 직후 2~3초 |

## MVP 기능 (3가지)
1. **먹이주기**: 음식 탭 → 먹기 애니메이션 → hunger 증가
2. **쓰다듬기/탭**: DragGesture → 반응 / 빠른 탭 → 놀람 → happiness 증가
3. **쳇바퀴**: 탭 연타/드래그 → 회전 속도 연동 → happiness↑ energy↓

## 데이터 흐름
```
View (탭/제스처)
  → ViewModel.action()
    → HamsterService.update()    # 스탯 계산 + UserDefaults 저장
    → LiveActivityService.update() # 다이나믹 아일랜드 갱신
```

## 다이나믹 아일랜드 제약
- Live Activity 최대 8시간 → 앱 재진입 시 갱신 필수
- 아일랜드 내 직접 인터랙션 불가 (탭 = 앱 딥링크만)
- 60fps 불가 → 상태 이미지 교체 방식

## 스프라이트
- 스타일: 픽셀아트 8bit
- 해상도: 32×32 or 64×64px (@2x, @3x)
- 배경: 투명 PNG
- 다이나믹 아일랜드용: 밝은 색상 (검정 배경 대비)

## 개발 순서
1. Domain 모델 + HamsterService 구현
2. MainView + HampyView 스프라이트 렌더링
3. 제스처 인터랙션 (먹이주기, 쓰다듬기, 탭)
4. WheelView 쳇바퀴 미니게임
5. ActivityKit Live Activity 연동
6. BGAppRefreshTask 백그라운드 처리
7. QA + TestFlight

## 코드 컨벤션
- ViewModel: `@Observable` 클래스, 접미사 `ViewModel`
- Service: 싱글톤 or 환경객체로 주입
- View 파일 하나에 하나의 주요 뷰
- 네이밍: Swift API Design Guidelines 준수
- 주석: 로직이 불명확한 곳에만 최소한으로
