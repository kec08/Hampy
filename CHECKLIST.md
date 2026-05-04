# Hampy 개발 체크리스트

## STEP 1: 프로젝트 구조 세팅
- [ ] 폴더 구조 생성 (Presentation, Domain, Services, Resources)
- [ ] HampyApp.swift 정리 (ContentView → MainView 연결)

## STEP 2: Domain 모델
- [ ] HamsterState.swift (hunger, happiness, energy, lastUpdated)
- [ ] HamsterEmotion.swift (happy, hungry, tired, upset, eating enum)

## STEP 3: Service 레이어
- [ ] HamsterService.swift - 스탯 계산 로직
- [ ] HamsterService.swift - 시간 경과 감소 로직
- [ ] HamsterService.swift - UserDefaults 저장/불러오기
- [ ] HamsterService.swift - feed(), pet(), runWheel() 액션

## STEP 4: MainView + ViewModel
- [ ] MainViewModel.swift (@Observable, Service 연결)
- [ ] MainView.swift (전체 레이아웃)
- [ ] StatsBarView.swift (hunger/happiness/energy 바)
- [ ] ActionBarView.swift (먹이주기/쳇바퀴 버튼)

## STEP 5: HampyView 스프라이트
- [ ] 임시 플레이스홀더 스프라이트 적용
- [ ] TimelineView 프레임 애니메이션 구현
- [ ] 감정 상태별 애니메이션 분기

## STEP 6: 제스처 인터랙션
- [ ] DragGesture → 쓰다듬기 반응
- [ ] TapGesture (빠른 탭) → 놀람 반응
- [ ] 먹이주기 탭 → 먹기 애니메이션 + hunger 증가

## STEP 7: 쳇바퀴 미니게임
- [ ] WheelViewModel.swift
- [ ] WheelView.swift (회전 UI)
- [ ] 탭 연타/드래그 속도 감지
- [ ] 회전 속도 연동 애니메이션
- [ ] happiness↑ energy↓ 스탯 반영

## STEP 8: Live Activity (다이나믹 아일랜드)
- [ ] ActivityExtension 타겟 추가
- [ ] HampyActivityAttributes.swift 정의
- [ ] HampyActivityWidget.swift (compact/expanded 레이아웃)
- [ ] LiveActivityService.swift (start/update/end)
- [ ] 스탯 변경 시 아일랜드 업데이트 연동

## STEP 9: 백그라운드 처리
- [ ] BGAppRefreshTask 등록
- [ ] 앱 재진입 시 경과 시간 스탯 차감
- [ ] Live Activity 8시간 만료 대응 (재진입 시 재시작)

## STEP 10: 마무리
- [ ] 픽셀아트 스프라이트 에셋 교체
- [ ] UI 다듬기 (색상, 레이아웃, 전환 애니메이션)
- [ ] 테스트 (스탯 계산, 시간 경과, 제스처)
- [ ] TestFlight 배포
