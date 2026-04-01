---
title:  "클로드 코드 보안 설정"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---

### Skills란  
`Skills`는 `Claude Code`가 어떤 상황에 어떤식으로 작업할지 미리 적어둔 매뉴얼이라고 생각하면 된다.  
`SKILL.md`라는 파일에만 정의해 두면 `Claude`가 필요할 때 자동으로 읽고 활용한다.  
  
보통 AI를 사용할때 "보고서는 이런 형식으로 써줘", "코드는 이런 규칙을 지켜줘"라고 길게 설명한다.  
이런 반복적인 프롬프트를 하나의 파일(`SKILL.md`)로 저장해두고 `Claude`가 필요할 때마다 그 매뉴얼을 꺼내 읽게 만들게 함으로써 매번 똑같은 프롬프트를 복사, 붙여 넣기를 할 필요가 없다.  
  
`Skills`에는 두 가지 유형이 있다.  
자동으로 실행될 수도 있고 `/explain-code`처럼 슬래시 명령어로 직접 호출하는 것도 가능하다.  
  
1. 참조 콘텐츠 (Reference Skill)  
   * "우리 회사 API는 이런 규칙을 따라" 같은 지식을 담는 용도  
   * Claude가 코드를 작성할 때 자동으로 참고  
   * 예: API URL은 kebab-case, JSON은 camelCase, 목록 API는 반드시 페이지네이션 포함  

2. 작업 콘텐츠 (Action Skill)  
   * "배포해줘"처럼 특정 작업의 단계별 절차를 담는 용도  
   * /deploy처럼 슬래시 명령어로 직접 실행합니다  
   * 예: 테스트 실행 → 빌드 → 배포 서버에 푸시  
  
<br/>  
  
### Skills 파일 우선순위  
`skill`을 저장하는 위치에 따라 누가 사용할 수 있는지가 결정돤다.  
  
| 수준 | 파일 경로 | 적용 대상 |
|------|------|----------|
| Enterprise | 관리 설정 참조 | 조직의 모든 사용자 |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | 모든 프로젝트 |
| Project | `.claude/skills/<skill-name>/SKILL.md` | 이 프로젝트만 |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | 플러그인이 활성된 위치 |
  
동일한 이름의 스킬이 있을 경우 `Enterprise > Personal > Project` 순서로 우선된다.  
  
`Claude Code`에는 `.claude/commands/` 폴더에 만드는 커스텀 명령어(commands) 기능도 있는데 `Skills`와 비슷하게 슬래시 명령어로 실행할 수 있다.  
`Skill`과 동일한 `Command`가 있으면 `Skill`이 우선된다.  
    
* Plugin : 일반 Skill은 내가 직접 `SKILL.md`를 작성하지만 `Plugin`은 다른 사람(또는 Anthropic)이  미리 만들어둔 `Skills`, 설정, 도구 등을 한 번에 설치하여 사용한다.  
  * `dev-tools`라는 플러그인에 `review`라는 스킬이 있으면 `/acme-tools:review` 아렇게 사용한다.  
  * 그렇기에 내가 만든 `skill`과 이름이 겹쳐도 충돌이 일어나지 않는다.  
  
<br/>  
  
### Skills 파일 작성  
SKILL.md 파일은 Markdown 형식으로 작성한다.  
```
---
name: 실행코드
description: 코드 설명을 도와줌
---
... 실제 설명 내용과 규칙 ...
```  
name: 스킬 이름  
description: 스킬이 무엇을 하는지, 언제 사용해야 하는지 아래에는 Claude가 따라야 할 구체적인 지침을 작성한다.  
  
* 추가 설정 옵션  
  * `context: fork` : 
    * 스킬이 별도의 서브에이전트(기존 대화 흐름과 분리해서 독립된 컨텍스트)에서 실행됩니다. 본 대화의 맥락을 아끼고 싶거나 이전 대화 영향 받으면 안 될 때 사용.  
  * `disable-model-invocation: true` : 
    *  Claude가 자동으로 이 스킬을 쓰지 못함. 배포처럼 위험한 작업에 권장.  
  * `allowed-tools: Read, Grep` : 
    *  `allowed-tools`를 정의하는 `Skills`는 `skill`이 활성화되었을 때 사용자별 승인 없이 `Claude`에게 이러한 도구에 대한 액세스를 부여.  
    *  Read, Grep 권한을 부여하겠다는 의미.  
  
여러개의 `skills`를 생성하는 경우 아래 구조처럼 생성하면 된다.  
```
.claude/
└── skills/
    ├── excel-master/          (skills 1번 폴더)
    │   └── SKILL.md           (파일 이름은 반드시 SKILL.md)
    ├── code-reviewer/         (skills 2번 폴더)
    │   └── SKILL.md           (파일 이름은 반드시 SKILL.md)
    └── translator/            (skills 3번 폴더)
        └── SKILL.md           (파일 이름은 반드시 SKILL.md)
```
  
<br/>  
  
### 참조 콘텐츠 (Reference Skill) 작성 예제  
```
<!-- 예제1: Java 코드 스타일 & 아키텍처 가이드 -->
---
name: java-reference-guide
description: Java 코드 작성 및 리뷰 시 참고하는 스타일 및 아키텍처 가이드
---

# Java 코드 스타일 가이드

## 1. 네이밍 규칙
- 클래스: PascalCase (예: UserService)
- 메서드: camelCase (예: getUserById)
- 변수: camelCase
- 상수: UPPER_SNAKE_CASE

## 2. 계층 구조
- controller: 요청/응답 처리
- service: 비즈니스 로직
- repository: DB 접근

## 3. DTO 규칙
- Request / Response 명확히 분리
- Entity 직접 반환 금지

## 4. 예외 처리
- RuntimeException 상속한 커스텀 예외 사용
- GlobalExceptionHandler에서 처리

## 5. 트랜잭션
- Service 계층에서 @Transactional 사용

## 6. 코드 스타일
- 메서드는 한 가지 책임만 가지도록 작성
- 3 depth 이상 지양

## 사용 방법
이 가이드는 코드 작성, 리뷰, 리팩토링 시 참고 기준으로 사용한다.
```
  
```
<!-- 예제2 : 테스트 코드 생성 -->
---
name: generate-test-code
description: Java 코드 변경 시 테스트 코드를 생성하거나 기존 테스트를 보완한다
---

사용자가 Java 코드 또는 변경 내용을 제공하면 테스트 코드를 작성하세요.

## 목표
- 기능 추가/수정에 따른 테스트 코드 생성
- 기존 테스트 누락 케이스 보완

## 기준
- JUnit 5 사용
- Mockito 사용 가능
- given-when-then 패턴 적용

## 작업 순서

1. 변경 내용 분석
- 어떤 기능이 추가/수정되었는지 파악

2. 테스트 케이스 도출
- 정상 케이스
- 예외 케이스
- 경계값 케이스

3. 테스트 코드 작성
- @DisplayName 사용
- 테스트 메서드 명은 의미 있게 작성

4. 기존 테스트 보완 (필요 시)
- 누락된 케이스 추가

## 출력 형식

1. 테스트 전략 요약
2. 테스트 케이스 목록
3. 전체 테스트 코드

## 예시 스타일

@Test
@DisplayName("좌석 예매 성공")
void reserveSeat_success() {
    // given
    // when
    // then
}

## 추가 규칙
- Mock 사용 최소화
- 실제 로직 중심 테스트 우선
- 가독성 최우선
```
  
<br/>  
  
### 작업콘텐츠(Action Skill) 작성 예제  
작업콘텐츠(Action Skill) `skill`의 경우 `disable-model-invocation: true` 옵션을 추가하여 `Claude`가 자동으로 실행하는 것을 방지해야 한다.  
```
<!-- 예제1: Java 코드 리뷰 스킬 -->
---
name: review-java-code
description: Java 코드를 분석하여 문제점과 개선사항을 리뷰한다
disable-model-invocation: true
allowed-tools: Read, Grep
---

사용자가 Java 코드를 제공하면 아래 순서로 리뷰하세요:

## 1. 전체 요약
- 코드의 역할을 한 줄로 설명

## 2. 문제점 분석
- 버그 가능성
- 성능 문제
- 가독성 문제

## 3. 개선 제안
- 구체적인 수정 코드 포함

## 4. 아키텍처 관점
- 계층 분리 문제
- 책임 분리 문제

## 5. 출력 형식
다음 구조로 답변:
- 요약
- 문제점
- 개선 코드
- 추가 의견

코드는 Java 기준으로 작성한다.
```
  
```
<!-- 예제 2: 서비스 코드 생성 스킬 -->
---
name: generate-java-service
description: 요청 기반으로 Java Service 코드를 생성한다
context: fork
disable-model-invocation: true
---

사용자의 요구사항을 기반으로 Java Service 코드를 작성하세요.

## 요구사항
- Spring Boot 기반
- Service 클래스 생성
- 인터페이스 + 구현체 분리
- @Transactional 적용

## 포함 내용
- Service 인터페이스
- ServiceImpl 클래스
- 필요한 메서드 구현

## 코드 스타일
- 명확한 메서드 이름
- 예외 처리 포함

## 출력 형식
1. 인터페이스
2. 구현체
3. 설명
```
  
  
참고 [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
