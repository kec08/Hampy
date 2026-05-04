# Hampy 디자인 스타일 가이드

## 컨셉
- **Pixel Pals** 스타일 레트로 픽셀아트
- 모든 UI 요소가 픽셀 기반 (둥근 모서리 X, 각진 모서리)
- 다이나믹 아일랜드 포함 전체 통일된 픽셀 스타일

---

## 컬러 팔레트

### 배경
| 용도 | 색상 | Hex |
|------|------|-----|
| 메인 배경 | 다크 네이비 | #1a1a2e |
| 케이지/바닥 | 다크 브라운 | #3d2b1f |
| 카드/패널 배경 | 반투명 다크 | #000000 40% |

### 햄피 캐릭터
| 부위 | 색상 | Hex |
|------|------|-----|
| 몸통 (밝은 부분) | 크림 | #f5d6a0 |
| 몸통 (어두운 부분) | 황갈색 | #c4944a |
| 외곽선 | 다크 브라운 | #5c3a1e |
| 볼 | 핑크 | #ff8fa0 |
| 눈 | 검정 | #1a1a1a |
| 배 (밝은 부분) | 밝은 크림 | #fff4e0 |

### UI 요소
| 용도 | 색상 | Hex |
|------|------|-----|
| hunger 바 | 오렌지 | #ff9642 |
| happiness 바 | 핑크 | #ff6b9d |
| energy 바 | 그린 | #4ecdc4 |
| 바 배경 | 다크 그레이 | #2a2a3e |
| 텍스트 | 밝은 화이트 | #e8e8e8 |
| 서브 텍스트 | 그레이 | #8888aa |
| 버튼 테두리 | 밝은 그레이 | #6a6a8a |
| 액센트 | 골드 | #ffd700 |

---

## 폰트
- **모든 텍스트**: 시스템 monospaced (`.system(.body, design: .monospaced)`)
- 픽셀 폰트 에셋 추후 적용 가능 (예: Press Start 2P)
- 크기: 타이틀 16pt, 본문 12pt, 캡션 10pt

---

## 햄피 픽셀 스프라이트 설계

### 메인 화면용 (64x64 논리 픽셀)
- SwiftUI `Path` + `Rectangle`로 픽셀 단위 드로잉
- 1픽셀 = 4pt (16x16 그리드 → 64x64pt 렌더링)

### 다이나믹 아일랜드용 (16x16 논리 픽셀)
- 1픽셀 = 2pt (16x16 그리드 → 32x32pt 렌더링)
- 밝은 색상만 사용 (검정 배경 대비)
- 외곽선 없이 채움색만

### 픽셀 그리드 정의 (16x16 기준 - happy 상태)

```
. . . . . E E . . E E . . . . .
. . . . E E E E E E E E . . . .
. . . E B B B B B B B B E . . .
. . E B B B B B B B B B B E . .
. E B B K K B B B B K K B B E .
. E B B K K B B B B K K B B E .
E B B B B B B B B B B B B B B E
E B P B B B B B B B B B B P B E
E B B B B B B W B B B B B B B E
E B B B B B B B B B B B B B B E
. E B B B B B B B B B B B B E .
. E B B B L L L L L L B B B E .
. . E B B L L L L L L B B E . .
. . . E B B B B B B B B E . . .
. . . . E E E E E E E E . . . .
. . . . . . E . . E . . . . . .
```

범례: E=외곽(#5c3a1e), B=몸통(#f5d6a0), K=눈(#1a1a1a), P=볼(#ff8fa0), W=입(#c4944a), L=배(#fff4e0)

---

## UI 컴포넌트 스타일

### 스탯 바
- 높이: 8pt (픽셀 2칸)
- 외곽: 1px 솔리드 테두리
- 배경: #2a2a3e
- 채움: 해당 색상 솔리드 (그라데이션 X)
- 모서리: 각진 직각 (cornerRadius = 0)

### 버튼
- 배경: #2a2a3e
- 테두리: 2px 솔리드 #6a6a8a
- 누름 효과: 2px 아래로 이동 (그림자 제거)
- 아이콘: 픽셀아트 아이콘 (이모지 → 픽셀 드로잉 교체)
- 모서리: 각진 직각

### 카드/패널
- 배경: 반투명 검정
- 테두리: 1px 솔리드 #6a6a8a
- 모서리: 각진 직각
- 패딩: 8pt 균일

---

## 다이나믹 아일랜드

### Compact
- 왼쪽: 16x16 픽셀 햄피 (Path로 렌더링)
- 오른쪽: 상태별 3칸 미니 바 (hunger/happiness/energy)

### Expanded
- 왼쪽: 32x32 픽셀 햄피
- 오른쪽: 스탯 바 3개 + 수치
- 하단: "탭해서 돌봐주기" 텍스트

### Lock Screen 배너
- 동일한 픽셀 스타일 유지

---

## 애니메이션 원칙
- 프레임 기반 (보간 애니메이션 최소화)
- idle: 2프레임 토글 (0.5초 간격)
- 먹기: 3프레임 순차 (0.3초 간격)
- 놀람: 1프레임 떨림 (offset ±2pt)
- 이동: 없음 (고정 위치, 제자리 애니메이션만)

---

## 적용 순서

1. [ ] PixelHamsterView 구현 (Path 기반 16x16 그리드 렌더링)
2. [ ] 감정별 픽셀 스프라이트 데이터 정의 (happy, hungry, tired, upset, eating)
3. [ ] 메인 화면 배경/레이아웃 픽셀 스타일로 변경
4. [ ] StatsBarView 픽셀 스타일 적용
5. [ ] ActionBarView 픽셀 버튼으로 변경
6. [ ] 다이나믹 아일랜드 픽셀 햄피 적용
7. [ ] WheelView 픽셀 스타일 적용
