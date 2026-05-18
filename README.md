# 🐹 햄피 (Hampy) - 다이나믹 아일랜드 가상 펫 햄스터

<p align="center">
  <img src="https://github.com/user-attachments/assets/ccf07cb9-f5a5-49d0-a58b-b55bbd471a47" alt="햄피" width="878"/>
</p>

<p align="center">
  <strong>"다이나믹 아일랜드에 살고 있는 작은 햄스터, 햄피를 만나보세요."</strong>
</p>

<p align="center">
  <a href="https://apps.apple.com/kr/app/%ED%96%84%ED%94%BC/id6766738253">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store" height="40"/>
  </a>
</p>

---

## 소개

**햄피**는 다이나믹 아일랜드 위에 사는 가상 펫 햄스터 앱입니다.

밥 주고, 쓰다듬고, 쳇바퀴도 돌리며 키울수록 커지는 햄피를 지금 키워보세요!
밥 안 주면 배고파하고, 놀아주면 좋아하고, 방치하면 삐져요.

## 주요 기능

### 1. 먹이주기
> 던져도, 놓아도, 클릭해도 OK. 햄피가 알아서 달려가서 먹어요.

- 해바라기씨를 탭, 드래그, 던지기 등 다양한 방식으로 먹이기 가능
- 1시간마다 간식 5개 자동 지급 (최대 20개 저장)
- 먹이를 줄수록 경험치 획득

### 2. 쓰다듬기 & 놀라기
> 쓰다듬으면 좋아하고, 탭하면 깜짝 놀라요.

- 드래그로 쓰다듬기 → 행복도 상승 + 경험치 획득
- 탭으로 놀라기 → 행복도, 에너지 감소
- 행복도가 가득 차면 경험치는 오르지 않아요

### 3. 쳇바퀴
> 탭할수록, 더 빠르게. 운동을 소홀히 하면 안 되겠죠?

- 빠르게 탭하여 쳇바퀴 회전
- 속도에 따른 행복도 상승 + 에너지 소모
- 운동을 통한 경험치 획득

### 4. 다이나믹 아일랜드
> 화면 위에 항상 같이. 앱을 열지 않아도 밥 주고 쓰다듬을 수 있어요.

- Live Activity를 통한 실시간 상태 표시
- 다이나믹 아일랜드에서 직접 먹이주기, 쓰다듬기 가능
- 잠금화면에서도 햄스터 상태 확인

### 5. 성장 시스템
> 쓰다듬고, 먹이주고, 같이 크는 중. 레벨이 오르면 햄피도 조금씩 커져요.

- 먹이주기, 쓰다듬기, 쳇바퀴를 통한 경험치 획득
- 레벨업 시 햄스터 크기 증가 (Lv.1: 0.7x → Lv.20: 1.65x)
- 레벨이 오를수록 더 많은 경험치 필요 (50, 100, 150, 200 ...)

### 6. 표정 변화
> 표정으로 다 말해요. 사용자 동작에 따라 다양한 표정을 지어요.

| 상태 | 조건 |
|------|------|
| 😊 행복 | 배고픔 > 60, 행복 > 60 |
| 🥺 배고픔 | 배고픔 < 30 |
| 😴 피곤 | 에너지 < 30 |
| 😤 삐짐 | 행복 < 20 |
| 🐹 먹는 중 | 먹이주기 직후 |

## 프로젝트 구조

```
Hampy/
├── App/
│   └── HampyApp.swift              # @main 엔트리
│
├── Domain/
│   ├── HamsterState.swift           # 핵심 상태 모델 (배고픔, 행복, 에너지, 레벨)
│   ├── HamsterEmotion.swift         # 감정 상태 enum
│   ├── HampyIntents.swift           # Live Activity Intent (먹이, 쓰다듬기)
│   └── SharedStorage.swift          # App Group UserDefaults 래퍼
│
├── Presentation/
│   ├── Main/
│   │   ├── MainView.swift           # 메인 화면 (프로필, 스탯, 햄스터)
│   │   ├── MainViewModel.swift      # 메인 뷰 로직
│   │   └── Components/
│   │       ├── HampyView.swift      # 햄스터 스프라이트 + 제스처
│   │       ├── StatsBarView.swift   # 배고픔/행복/에너지 스탯 바
│   │       ├── OutlinedText.swift   # 외곽선 텍스트
│   │       └── PixelIcons.swift     # 픽셀아트 아이콘
│   ├── Feed/
│   │   └── FeedView.swift           # 먹이주기 화면
│   └── Wheel/
│       ├── WheelView.swift          # 쳇바퀴 미니게임
│       └── WheelViewModel.swift     # 쳇바퀴 로직
│
├── Services/
│   ├── HamsterService.swift         # 핵심 상태 관리 + 시간 감쇠
│   ├── LiveActivityService.swift    # ActivityKit 관리
│   ├── BackgroundService.swift      # BGAppRefreshTask 백그라운드 처리
│   ├── NotificationService.swift    # 간식 지급 알림
│   └── SoundService.swift           # 효과음 + 햅틱
│
├── Resources/
│   └── Sprites/                     # 픽셀아트 PNG
│
└── Assets.xcassets/                 # 이미지 및 컬러 리소스

HampyActivityExtension/              # 다이나믹 아일랜드 Widget Target
├── HampyActivityWidget.swift        # Live Activity UI
├── HampyActivityAttributes.swift    # ActivityKit 데이터 모델
├── HampyIntents.swift               # 먹이/쓰다듬기 Intent
├── HamsterState.swift               # 공유 상태 모델
├── HamsterEmotion.swift             # 공유 감정 enum
└── SharedStorage.swift              # 공유 저장소
```

## 아키텍처

```
┌─────────────────┐
│      View        │  SwiftUI 화면 + 제스처
├─────────────────┤
│    ViewModel     │  @Observable 상태 관리
├─────────────────┤
│    Service       │  HamsterService (스탯 계산 + 저장)
│                  │  LiveActivityService (다이나믹 아일랜드)
│                  │  BackgroundService (백그라운드 감쇠)
├─────────────────┤
│    Domain        │  HamsterState + SharedStorage (UserDefaults)
└─────────────────┘
```

View에서 제스처 입력 → Service에서 스탯 계산 및 저장 → LiveActivity 갱신의 흐름으로 동작하며, App Group을 통해 메인 앱과 Widget Extension 간 데이터를 공유합니다.

## 앱 다운로드

<p align="center">
  <a href="https://apps.apple.com/kr/app/%ED%96%84%ED%94%BC/id6766738253">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store" height="40"/>
  </a>
</p>

## 개발 정보

- 1인 개발 프로젝트
- 외부 의존성 없음 (순수 Apple 프레임워크)
- 서버 없음 (완전 오프라인)
- 인앱 결제 없음

## 라이선스

이 프로젝트는 개인 프로젝트로, 무단 복제 및 배포를 금합니다.
