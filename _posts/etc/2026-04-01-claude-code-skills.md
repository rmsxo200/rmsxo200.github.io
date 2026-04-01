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
````
<!-- 예제1: Java 코드 스타일 & 아키텍처 가이드 -->
<!-- ~/.claude/skills/java-reference-guide/SKILL.md -->
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
````
  
````
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

### Controller → 슬라이스 테스트
- `@WebMvcTest(대상Controller.class)` 사용
- `MockMvc`로 HTTP 요청/응답 검증
- Service는 `@MockBean`으로 모킹
- 검증 항목: HTTP 상태 코드, 응답 JSON 구조, 요청 유효성 검증(@Valid) 동작
```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private OrderService orderService;

    @Test
    void should_returnCreated_when_validRequest() throws Exception {
        // given
        var request = new OrderCreateRequest("상품A", 3);
        given(orderService.create(any())).willReturn(1L);

        // when & then
        mockMvc.perform(post("/api/v1/orders")
                .contentType(APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated());
    }

    @Test
    void should_returnBadRequest_when_productNameBlank() throws Exception {
        // given
        var request = new OrderCreateRequest("", 3);

        // when & then
        mockMvc.perform(post("/api/v1/orders")
                .contentType(APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }
}
```

### Service → 단위 테스트
- JUnit 5 + Mockito (`@ExtendWith(MockitoExtension.class)`)
- Repository, 외부 의존성은 `@Mock`으로 모킹
- 대상 서비스는 `@InjectMocks`
- 검증 항목: 비즈니스 로직 분기, 예외 발생 조건, 메서드 호출 여부
```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderService orderService;

    @Test
    void should_createOrder_when_validInput() {
        // given
        var request = new OrderCreateRequest("상품A", 3);
        var savedOrder = Order.builder().id(1L).productName("상품A").quantity(3).build();
        given(orderRepository.save(any())).willReturn(savedOrder);

        // when
        Long id = orderService.create(request);

        // then
        assertThat(id).isEqualTo(1L);
        then(orderRepository).should().save(any(Order.class));
    }

    @Test
    void should_throwException_when_orderNotFound() {
        // given
        given(orderRepository.findById(999L)).willReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> orderService.findById(999L))
            .isInstanceOf(BusinessException.class);
    }
}
```

### Repository → 통합 테스트
- `@DataJpaTest` 사용
- 커스텀 쿼리 메서드가 있을 때만 작성 (기본 CRUD는 생략 가능)
- `@TestMethodOrder(OrderAnnotation.class)`로 테스트 순서 보장이 필요하면 사용
```java
@DataJpaTest
class OrderRepositoryTest {

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void should_findOrders_when_filterByProductName() {
        // given
        orderRepository.save(Order.builder().productName("상품A").quantity(1).build());
        orderRepository.save(Order.builder().productName("상품B").quantity(2).build());

        // when
        List<Order> result = orderRepository.findByProductName("상품A");

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getProductName()).isEqualTo("상품A");
    }
}
```

### Domain (엔티티/VO) → 순수 단위 테스트
- 프레임워크 의존 없이 순수 Java 테스트
- 검증 항목: 생성 규칙, 상태 변경 메서드, 비즈니스 규칙 검증
```java
class OrderTest {

    @Test
    void should_createOrder_when_validParameters() {
        Order order = Order.builder()
            .productName("상품A")
            .quantity(3)
            .build();

        assertThat(order.getProductName()).isEqualTo("상품A");
        assertThat(order.getQuantity()).isEqualTo(3);
    }

    @Test
    void should_throwException_when_quantityNegative() {
        assertThatThrownBy(() -> Order.builder()
                .productName("상품A")
                .quantity(-1)
                .build())
            .isInstanceOf(IllegalArgumentException.class);
    }
}
```

## 테스트 메서드 네이밍 규칙

`should_기대결과_when_조건` 형식을 따른다.

좋은 예:
- `should_returnOrder_when_validId`
- `should_throwException_when_duplicateEmail`
- `should_returnEmptyList_when_noMatchingResults`
- `should_updateQuantity_when_validAmount`

## 테스트 구조

모든 테스트는 given / when / then 패턴을 따른다.
```java
@Test
void should_기대결과_when_조건() {
    // given - 테스트 데이터 준비, 모킹 설정

    // when - 테스트 대상 실행

    // then - 결과 검증
}
```

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
   - `./gradlew test` 또는 `mvn test` 실행하여 확인
   - 실패하면 즉시 수정

## 테스트 파일 위치

기능 코드와 동일한 패키지 구조를 `src/test/java` 아래에 유지한다.
```
src/main/java/com/mycompany/order/service/OrderService.java
src/test/java/com/mycompany/order/service/OrderServiceTest.java

src/main/java/com/mycompany/order/controller/OrderController.java
src/test/java/com/mycompany/order/controller/OrderControllerTest.java
```

## 사용하는 라이브러리

- JUnit 5: `@Test`, `@ExtendWith`, `@DisplayName`
- AssertJ: `assertThat()`, `assertThatThrownBy()`
- Mockito: `@Mock`, `@InjectMocks`, `given()`, `then().should()`
- MockMvc: 컨트롤러 슬라이스 테스트
- BDDMockito: `given()` / `then()` 스타일 사용 (when() 대신)
````
  
````
<!-- 예제3 : Java 코드를 작성 및 리뷰 -->
<!-- ~/.claude/skills/java-conventions/SKILL.md -->
---
name: java-conventions
description: Java 프로젝트의 코딩 컨벤션 및 아키텍처 가이드. Java 코드를 작성하거나 리뷰할 때 자동으로 참조한다.
---

# Java 코딩 컨벤션

## 네이밍 규칙
- 클래스명: PascalCase (예: `OrderService`, `UserRepository`)
- 메서드/변수명: camelCase (예: `findByUserId`, `orderCount`)
- 상수: UPPER_SNAKE_CASE (예: `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`)
- 패키지명: 모두 소문자, 역도메인 (예: `com.mycompany.order.domain`)

## 패키지 구조 (Layered Architecture)
```
com.mycompany.project
├── controller/     # REST API 진입점 (@RestController)
├── service/        # 비즈니스 로직 (@Service)
├── repository/     # 데이터 접근 (@Repository)
├── domain/         # 엔티티, VO, Enum
├── dto/            # 요청/응답 DTO
├── config/         # 설정 클래스 (@Configuration)
└── exception/      # 커스텀 예외 및 핸들러
```

## Spring Boot 규칙
- 생성자 주입만 사용한다. `@Autowired` 필드 주입 금지.
- `@Transactional(readOnly = true)`를 조회 메서드에 항상 붙인다.
- 컨트롤러에 비즈니스 로직을 넣지 않는다. 서비스 계층에 위임한다.
- API 응답은 `ResponseEntity<>`로 감싸고, 공통 응답 포맷(`ApiResponse<T>`)을 사용한다.

## 예외 처리
- 비즈니스 예외는 `BusinessException`을 상속하여 만든다.
- `@RestControllerAdvice`에서 전역으로 처리한다.
- 절대 빈 catch 블록을 만들지 않는다.

## 테스트
- 단위 테스트: JUnit 5 + Mockito
- 통합 테스트: `@SpringBootTest` + `@Testcontainers`
- 테스트 메서드명: `should_기대결과_when_조건` 형식
  (예: `should_throwException_when_userNotFound`)

## 로깅
- `@Slf4j` (Lombok) 사용
- DEBUG: 개발 디버깅용
- INFO: 주요 비즈니스 이벤트
- WARN/ERROR: 예외 상황, 반드시 예외 객체를 함께 출력
````
  
<br/>  
  
### 작업콘텐츠(Action Skill) 작성 예제  
작업콘텐츠(Action Skill) `skill`의 경우 `disable-model-invocation: true` 옵션을 추가하여 `Claude`가 자동으로 실행하는 것을 방지해야 한다.  
````
<!-- 예제1: Java 코드 리뷰 스킬 -->
<!-- ~/.claude/skills/review-java-code/SKILL.md -->
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
````
  
````
<!-- 예제 2: 서비스 코드 생성 스킬 -->
<!-- ~/.claude/skills/generate-java-service/SKILL.md -->
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
````

````
<!-- 예제3 : API 생성 -->
<!-- 사용명령어 : /spring-api Order $ARGUMENTS , /spring-api Order 주문 CRUD -->
<!-- ~/.claude/skills/spring-api/SKILL.md -->
---
name: spring-api
description: Spring Boot REST API 엔드포인트를 생성한다. CRUD API, 새로운 도메인 API를 만들 때 사용한다.
disable-model-invocation: true
---

# Spring Boot REST API 생성 워크플로

사용자가 요청한 도메인에 대해 아래 순서대로 파일을 생성한다.
$ARGUMENTS 에서 도메인 이름과 요구사항을 파악한다.

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
- `@Setter` 사용 금지. 변경은 의미 있는 메서드로 표현한다.
- `@Builder`는 생성자에 붙인다.
- `@NoArgsConstructor`는 `PROTECTED`로 제한한다.

## 2단계: DTO 생성

`dto/` 패키지에 요청/응답 DTO를 만든다.

- 요청: `도메인명CreateRequest`, `도메인명UpdateRequest` → Java `record` 사용
- 응답: `도메인명Response` → Java `record` 사용, 정적 팩토리 메서드 `from(Entity)` 포함
```java
public record OrderCreateRequest(
    @NotBlank String productName,
    @Positive int quantity
) {}

public record OrderResponse(
    Long id,
    String productName,
    int quantity,
    LocalDateTime createdAt
) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(
            order.getId(),
            order.getProductName(),
            order.getQuantity(),
            order.getCreatedAt()
        );
    }
}
```

## 3단계: Repository 생성

`repository/` 패키지에 Spring Data JPA 인터페이스를 만든다.
```java
public interface 도메인명Repository extends JpaRepository<도메인명, Long> {
    // 필요한 쿼리 메서드 추가
}
```

## 4단계: Service 생성

`service/` 패키지에 서비스 클래스를 만든다.

규칙:
- 생성자 주입 (`@RequiredArgsConstructor`)
- 조회 메서드에 `@Transactional(readOnly = true)`
- 변경 메서드에 `@Transactional`
- 엔티티를 찾지 못하면 커스텀 예외를 던진다

## 5단계: Controller 생성

`controller/` 패키지에 REST 컨트롤러를 만든다.

규칙:
- `@RestController`, `@RequestMapping("/api/v1/도메인s")`
- 요청 DTO에 `@Valid` 붙이기
- 생성 → `201 Created`, 조회 → `200 OK`, 삭제 → `204 No Content`
- 컨트롤러에 로직 넣지 않기

## 6단계: 검증

모든 파일 생성 후:
1. 프로젝트 컴파일 확인: `./gradlew compileJava` (또는 `mvn compile`)
2. 컴파일 에러가 있으면 즉시 수정
3. 생성한 파일 목록을 사용자에게 요약 보고
````
  
  
참고 [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
