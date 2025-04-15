# 차별을 피해라!

A new Flutter minigame module project.

### [게임 설명]
여러분은 LGBTQ+ 앨라이입니다. 중간중간 존재하는 '차별' 블럭을 피해, 퀴어 친구가 있는 세이프존에 도달하세요!
'차별' 블럭에 닿으면 성소수자 상식 O/X 퀴즈를 풀어야 해요. 걱정 마세요, 퀴즈를 맞추면 게임을 계속 진행할 수 있어요!

### [조작법]
화면의 조이스틱을 통해 위, 아래, 오른쪽으로 이동할 수 있습니다.

---

## Project Explanation
### Tech Stack
- Flutter 프레임워크
- Flame 게임 엔진
- Dart 언어
  
### Project Structure
#### Overview
```
minigame_avoid_the_bias/
├── lib/                         # 소스 코드
├── assets/                      # 게임 리소스 파일
├── pubspec.yaml                 # 의존성 관리 파일
└── README.md                    # 프로젝트 설명서
```

#### lib/ Directory: Source Codes
```
lib/
├── main.dart                    # 애플리케이션 시작점
├── game/
│   └── avoid_the_bias_game.dart # 메인 게임 클래스 (라운드 관리, 충돌 처리 등)
├── player/
│   └── player_component.dart    # 플레이어 캐릭터 구현 (이동 및 충돌)
├── component/
│   ├── discrimination_obstacle.dart # 장애물(편견) 구현
│   ├── safe_zone.dart           # 안전 지대 구현
│   └── background_component.dart # 배경 구현
├── hud/
│   ├── life_display.dart        # 생명력 표시 UI
│   └── timer_bar.dart           # 타이머 UI
└── overlay/
    └── quiz_overlay.dart        # 퀴즈 오버레이 UI (OX 퀴즈)
```
#### assets/ Directory: Game Resources
```
assets/
├── images/                      # 게임 이미지 리소스
│   ├── player.png               # 플레이어 캐릭터 스프라이트
│   ├── obstacle_1.png           # 장애물 스프라이트 1
│   ├── obstacle_2.png           # 장애물 스프라이트 2
│   ├── obstacle_3.png           # 장애물 스프라이트 3
│   ├── safe_zone.png            # 안전 지대 스프라이트
│   ├── bg_1.png                 # 배경 이미지 (라운드 1)
│   ├── bg_2.png                 # 배경 이미지 (라운드 2)
│   └── bg_3.png                 # 배경 이미지 (라운드 3)
├── quiz/                        # 퀴즈 데이터
│   └── quiz_questions_ko.json   # 한국어 퀴즈 문제 (성소수자 관련 OX 퀴즈)
└── audio/                       # 오디오 리소스 (현재 미사용)
```

### Features
#### 게임 시스템
- 3단계 라운드 시스템: 라운드마다 난이도가 증가 (라운드별 다른 배경, 장애물 수 증가, 제한 시간 감소)
- 장애물 회피 메커니즘: 플레이어는 조이스틱으로 캐릭터를 조작하여 장애물 회피
- 퀴즈 시스템: 장애물과 충돌 시 성소수자 관련 OX 퀴즈 출제
- 생명력 시스템: 오답 시 생명 감소, 3번의 기회 제공
- 타이머: 각 라운드마다 제한 시간 설정
#### 교육적 가치
- 성소수자와 관련된 편견과 차별에 대한 인식 제고
- 퀴즈를 통한 올바른 지식 전달
- 차별 없는 사회로 나아가는 메타포 표현 (안전 지대 도달)
#### 기술적 특징
- Flame 게임 엔진: 2D 게임 개발을 위한 Flutter 라이브러리 활용
- 충돌 감지 시스템: 장애물, 안전 지대와의 충돌 처리
- 조이스틱 컨트롤: 터치스크린 기기에 최적화된 컨트롤 구현
- JSON 기반 퀴즈 데이터: 확장 가능한 퀴즈 시스템

---

## Debugging
### 1. Flutter download
- VSCode에서 flutter extention 설치 및 환경변수 설정
- 혹은 https://docs.flutter.dev/get-started/install 에서 메뉴얼하게 다운로드

### 2. Run debugging with chrome command
```
flutter run -d chrome
```
이 커멘드 입력시 web으로 디버깅모드 진입, 프로젝트 확인 가능
