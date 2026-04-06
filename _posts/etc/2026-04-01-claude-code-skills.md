---
title:  "클로드 코드 Skills"
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
   * "우리 회사 API는 이런 규칙을 따라" 같은 지식을 담는 용도.  
   * Claude가 코드를 작성할 때 자동으로 참고.  
   * Java 상식같은 Claude가 추측할 수 있는 정보는 빼고 팀내 규칙같은 추측할 수 없는 정보는 넣는것이 좋다.  
   * 예: API URL은 kebab-case, JSON은 camelCase, 목록 API는 반드시 페이지네이션 포함.  

2. 작업 콘텐츠 (Action Skill)  
   * "배포해줘"처럼 특정 작업의 단계별 절차를 담는 용도.  
   * /deploy처럼 슬래시 명령어로 직접 실행합니다.  
   * 예: 테스트 실행 → 빌드 → 배포 서버에 푸시.  
  
---
  
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
  
---
  
### Skills 파일 작성  
SKILL.md 파일은 Markdown 형식으로 작성한다.  
```markdown
---
name: 실행코드
description: 코드 설명을 도와줌
---
... 실제 설명 내용과 규칙 ...
```  
name: 스킬 이름  
description: 스킬이 무엇을 하는지, 언제 사용해야 하는지 아래에는 Claude가 따라야 할 구체적인 지침을 작성한다.  
  
> `Claude`는 `description`을 보고 자동으로 사용할지 판단한다.  
> 그렇기에 언제 쓰고 언제 안 쓸지 명확히 작성하는게 중요하다.  
  
* 추가 설정 옵션  
  * `context: fork` : 
    * 스킬이 별도의 서브에이전트(기존 대화 흐름과 분리해서 독립된 컨텍스트)에서 실행됩니다. 본 대화의 맥락을 아끼고 싶거나 이전 대화 영향 받으면 안 될 때 사용.  
  * `disable-model-invocation: true` : 
    *  Claude가 자동으로 이 스킬을 쓰지 못함. 배포처럼 위험한 작업에 권장.  
  
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
  
---
  
### 참조 콘텐츠 (Reference Skill) 작성 예제  
````markdown
<!-- 예제1 : Java 코드를 작성 및 리뷰 -->
<!-- ~/.claude/skills/java-conventions/SKILL.md -->
---
name: java-conventions
description: 우리 팀 Java 프로젝트의 고유한 코딩 규칙. Java 코드 작성 및 리뷰 시 자동 참조.
---

# 우리 팀 Java 컨벤션

## 패키지 구조
com.mycompany.project 아래에 다음 구조를 따른다:
controller → service → repository → domain 순서.
dto는 dto/request, dto/response로 분리한다.

## 핵심 규칙 (일반 관례와 다른 점)
- DTO는 class가 아닌 Java record를 사용한다.
- 응답 DTO에 반드시 `from(Entity)` 정적 팩토리 메서드를 둔다.
- API 응답은 모두 `ApiResponse<T>`로 감싼다. ResponseEntity를 직접 쓰지 않는다.
- `@Data`, `@Setter` 사용 금지. `@Getter`만 허용.
- 엔티티 상태 변경은 setter가 아닌 도메인 메서드로 한다.
  예: `order.setStatus("X")` 금지 → `order.cancel("사유")` 사용.

## 예외 처리
- ErrorCode enum을 정의하고 BusinessException에 전달한다.
- 예외 메시지를 하드코딩하지 않는다.

## 테스트
- 메서드명: should_기대결과_when_조건
- given/when/then 구조 필수
- BDDMockito의 given()/then() 사용 (when() 대신)

## 금지 목록
- @Autowired 필드 주입
- @Data
- @Setter
- System.out.println
- Optional을 파라미터로 받는 것
- 문자열 비교에 ==
````
  
````markdown
<!-- 예제2 : 테스트 코드 생성 -->
<!-- ~/.claude/skills/java-test-sync/SKILL.md -->
---
name: java-test-sync
description: Java 코드에 기능이 추가되거나 수정될 때 반드시 대응하는 테스트 코드도 함께 생성하거나 수정한다. 기능 코드 변경 시 테스트 누락을 방지한다.
---

# 테스트 코드 동기화 규칙

기능 코드를 생성하거나 수정할 때, 반드시 대응하는 테스트 코드도 함께 생성하거나 수정한다.
테스트 없이 기능 코드만 변경하는 것은 허용되지 않는다.

## 핵심 원칙

- 기능 코드 1개 변경 = 테스트 코드 1개 이상 변경. 예외 없음.
- 새 클래스를 만들면 테스트 클래스도 만든다.
- 기존 메서드를 수정하면 해당 메서드의 테스트도 수정한다.
- 메서드를 삭제하면 해당 테스트도 삭제한다.
- 작업 완료 후 반드시 테스트를 실행하여 전부 통과하는지 확인한다.

## 계층별 테스트 전략

### Controller → @WebMvcTest + MockMvc
- Service는 `@MockBean`으로 모킹
- 검증: HTTP 상태 코드, 응답 JSON 구조, `@Valid` 동작

### Service → @ExtendWith(MockitoExtension.class)
- Repository, 외부 의존성은 `@Mock`, 대상 서비스는 `@InjectMocks`
- 검증: 비즈니스 로직 분기, 예외 발생 조건, 메서드 호출 여부
- BDDMockito의 `given()` / `then()` 스타일 사용 (`when()` 대신)

### Repository → @DataJpaTest
- 커스텀 쿼리 메서드가 있을 때만 작성 (기본 CRUD는 생략)

### Domain (엔티티/VO) → 순수 단위 테스트
- 프레임워크 없이 생성 규칙, 상태 변경 메서드, 비즈니스 규칙 검증

## 테스트 작성 규칙

- 메서드명: `should_기대결과_when_조건` (예: `should_throwException_when_userNotFound`)
- 구조: given / when / then 패턴 필수
- Assertion: AssertJ (`assertThat()`, `assertThatThrownBy()`) 사용

## 수정 시 체크리스트

기능 코드를 수정한 뒤, 아래 항목을 반드시 확인한다.

1. 변경한 메서드에 대응하는 테스트가 존재하는가?
   - 없으면 → 테스트 새로 작성
   - 있으면 → 변경 사항을 반영하여 테스트 수정
2. 메서드 시그니처가 변경되었는가? (파라미터, 리턴 타입)
   - 그렇다면 → 호출하는 모든 테스트 업데이트
3. 새로운 예외 케이스가 추가되었는가?
   - 그렇다면 → 예외 발생 테스트 추가
4. 분기(if/else, switch)가 추가되었는가?
   - 그렇다면 → 각 분기에 대한 테스트 추가
5. 모든 테스트가 통과하는가?
   - `./gradlew test` 실행하여 확인
   - 실패하면 즉시 수정

## 우리 팀 고유 규칙

- 테스트 커버리지 80% 이상 유지 필수
- 빌드 도구: Gradle (`./gradlew test`로 실행)
- 테스트 데이터는 `@BeforeEach`에서 생성 (트랜잭션 롤백으로 정리 불필요)
- Testcontainers 사용 시 이미지 고정: `PostgreSQLContainer("postgres:16-alpine")`
- 테스트 실패 시 PR 머지 불가 (CI 자동 차단)

## 테스트 파일 위치

기능 코드와 동일한 패키지 구조를 `src/test/java` 아래에 유지한다.

```
src/main/java/com/mycompany/order/service/OrderService.java
src/test/java/com/mycompany/order/service/OrderServiceTest.java
```
````
  
---
  
### 작업콘텐츠(Action Skill) 작성 예제  
작업콘텐츠(Action Skill) `skill`의 경우 `disable-model-invocation: true` 옵션을 추가하여 `Claude`가 자동으로 실행하는 것을 방지해야 한다.  
````markdown
<!-- 예제1: Java 코드 리뷰 스킬 -->
<!-- ~/.claude/skills/review-java-code/SKILL.md -->
---
name: review-java-code
description: 우리 팀 Java 코딩 규칙 기준으로 코드를 리뷰한다.
disable-model-invocation: true
context: fork
---

# Java 코드 리뷰

$ARGUMENTS 에서 리뷰 대상 파일 또는 범위를 파악한다.
지정이 없으면 git 스테이징된 변경 파일을 대상으로 한다.

## 리뷰 체크리스트

아래 항목을 순서대로 검사하고, 위반 사항만 보고한다.
문제 없는 항목은 출력하지 않는다.

### 엔티티 규칙
- @Setter, @Data 사용 여부 → 사용했으면 위반
- @Builder가 클래스에 붙어 있는지 → 생성자에 붙어야 함
- @NoArgsConstructor가 PROTECTED인지
- setter 대신 도메인 메서드로 상태 변경하는지

### DTO 규칙
- class 대신 record를 사용했는지
- 응답 DTO에 from(Entity) 정적 팩토리 메서드가 있는지
- 요청 DTO에 Bean Validation이 있는지

### Service 규칙
- @Autowired 필드 주입 사용 여부 → 생성자 주입만 허용
- 조회 메서드에 @Transactional(readOnly = true) 있는지
- 컨트롤러에 비즈니스 로직이 들어있지 않은지

### 예외 처리
- ErrorCode enum 기반 BusinessException을 사용하는지
- 빈 catch 블록이 없는지
- System.out.println 사용 여부 → @Slf4j 로거만 허용

### 테스트
- 변경된 기능 코드에 대응하는 테스트가 존재하는지
- 테스트 메서드명이 should_기대결과_when_조건 형식인지

### 일반
- Optional을 파라미터로 받고 있지 않은지 (리턴 타입에만 허용)
- 문자열 비교에 == 사용 여부 → equals() 또는 Objects.equals() 사용
- 메서드 depth가 3 이상이면 리팩토링 권고

## 출력 형식

위반 항목만 아래 형식으로 보고한다:

**[파일명:라인] 위반 항목**
- 현재: 위반 코드
- 수정: 올바른 코드
- 이유: 한 줄 설명

위반 없으면 "리뷰 통과. 위반 사항 없음."으로 끝낸다.
````
  
````markdown
<!-- 예제2 : API 생성 -->
<!-- ~/.claude/skills/spring-api/SKILL.md -->
<!--
    호출명령어 : /spring-api Order $ARGUMENTS
                 $ARGUMENTS는 자연어를 입력하면 된다.
-->
<!--
    호출예시 :
          /spring-api /spring-api 주문 CRUD, 도메인명 Order, 테이블명 order, 필드: productName(String), quantity(int), status(OrderStatus) 
          /spring-api Order 기존 도메인 사용, Service부터 Controller까지 CRUD API 생성
-->
---
name: spring-api
description: Spring Boot REST API 엔드포인트를 생성한다. CRUD API, 새로운 도메인 API를 만들 때 사용한다.
disable-model-invocation: true
---

# Spring Boot REST API 생성 워크플로

사용자가 요청한 도메인에 대해 아래 순서대로 파일을 생성한다.
$ARGUMENTS 에서 도메인 이름과 요구사항을 파악한다.

$ARGUMENTS 에서 아래 정보를 파악한다:
- 도메인명 (필수)
- 요구사항 (CRUD, 특정 API 등)

## 0단계: 기존 코드 확인

해당 도메인의 엔티티가 프로젝트에 이미 존재하는지 확인한다.
- 존재하면 → 기존 엔티티를 사용하고 1단계를 건너뛴다.
- 존재하지 않으면 → 1단계부터 시작한다.
- 사용자가 "기존 도메인 사용"이라고 명시한 경우 1단계를 반드시 건너뛴다.

## 1단계: 도메인 엔티티 생성

`domain/` 패키지에 JPA 엔티티를 만든다.

```java
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "테이블명")
public class 도메인명 {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 필드들...

    @Builder
    public 도메인명(파라미터들) {
        // 생성자
    }
}
```

규칙:
- `@Setter` 사용 금지. 변경은 의미 있는 도메인 메서드로 표현한다.
- `@Builder`는 클래스가 아닌 생성자에 붙인다.
- `@NoArgsConstructor`는 `PROTECTED`로 제한한다.
- `@Data` 사용 금지. `@Getter`만 허용한다.

## 2단계: DTO 생성

`dto/` 패키지에 요청/응답 DTO를 만든다.

- 요청: `도메인명CreateRequest`, `도메인명UpdateRequest`
- 응답: `도메인명Response`
- 모두 class가 아닌 Java `record`로 만든다.
- 요청 DTO에는 Bean Validation 어노테이션을 붙인다 (`@NotBlank`, `@Positive` 등).
- 응답 DTO에는 반드시 `from(Entity)` 정적 팩토리 메서드를 포함한다.

## 3단계: Repository 생성

`repository/` 패키지에 `JpaRepository<도메인명, Long>`을 상속하는 인터페이스를 만든다.

## 4단계: Service 생성

`service/` 패키지에 서비스 클래스를 만든다.

규칙:
- 생성자 주입 (`@RequiredArgsConstructor`)
- 조회 메서드에 `@Transactional(readOnly = true)`
- 변경 메서드에 `@Transactional`
- 엔티티를 찾지 못하면 `BusinessException(ErrorCode.XXX_NOT_FOUND)`를 던진다

## 5단계: Controller 생성

`controller/` 패키지에 REST 컨트롤러를 만든다.

규칙:
- `@RestController`, `@RequestMapping("/api/v1/도메인s")`
- 요청 DTO에 `@Valid` 붙이기
- HTTP 상태 코드: 생성 → `201 Created`, 조회 → `200 OK`, 삭제 → `204 No Content`
- 모든 응답은 `ApiResponse<T>`로 감싼다
- 컨트롤러에 비즈니스 로직 넣지 않기. 서비스에 위임만 한다.

## 6단계: 검증

모든 파일 생성 후:
1. 컴파일 확인: `./gradlew compileJava`
2. 컴파일 에러가 있으면 즉시 수정
3. 각 계층에 대응하는 테스트 코드를 생성한다 (java-test-sync 규칙을 따른다)
4. 테스트 실행: `./gradlew test`
5. 테스트 실패 시 즉시 수정
6. 생성한 파일 목록을 사용자에게 요약 보고
````
  
---
  
### 마치며
공식 문서에서는 Reference(참조)와 Action(실행)으로 구분하지만 실제로는 하나의 스킬 안에 규칙과 실행 절차가 함께 들어가는 경우가 많다.  
  
스킬을 만들 때 더 중요한 판단 기준은 Claude가 알아서 적용해야 하는가 내가 직접 부를 때만 실행해야 하는가이며 이에 따라 disable-model-invocation을 설정하면 된다.  

그리고 `skills`에 작성된 부분중 Claude가 절대 누락시켜서는 안된다고 생각하는 항목은 `CLAUDE.md`에 넣어주자.  

  
<br/>  
<br/>  
  
참고 [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
