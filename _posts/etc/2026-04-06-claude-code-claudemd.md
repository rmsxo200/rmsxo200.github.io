---
title:  "클로드 코드 CLAUDE.md"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---

### CLAUDE.md 란?  
`CLAUDE.md`는 `Claude Code`가 세션을 시작할 때마다 가장 먼저 읽는 프로젝트 가이드북이다.  
프로젝트의 코딩 표준, 빌드 명령, 아키텍처 결정, 워크플로우 규칙 등을 적어두면 Claude는 매 세션마다 이 파일을 읽고 프로젝트의 맥락을 이해한 채로 작업을 시작한다.  
그렇기에 새 세션에서 시작해도 매번 반복하여 같은 정보를 전달할 필요가 없다.  
  
---
  
### 자동 메모리와 비교  
`Claude Code`에는 두 가지 상호 보완적인 메모리 시스템이 있다.  
둘 다 모든 대화의 시작 시 로드됩니다.  
  
`CLAUDE.md`는 내가 직접 쓰는 프로젝트 매뉴얼이고 `자동 메모리`는 Claude가 일하면서 스스로 적는 메모장이다.  
둘 다 강제 규칙이 아닌 컨텍스트로 취급되기 때문에 구체적이고 간결할수록 Claude가 더 일관되게 따른다.  
  
| 구분       | CLAUDE.md 파일                    | 자동 메모리                                  |
|------------|----------------------------------|---------------------------------------------|
| 작성자     | 사용자                           | Claude                                      |
| 포함 내용  | 지침 및 규칙                     | 학습 및 패턴                                |
| 범위       | 프로젝트, 사용자 또는 조직        | 작업 트리당                                  |
| 로드 대상  | 모든 세션                        | 모든 세션 (처음 200줄 또는 25KB)             |
| 사용 목적  | 코딩 표준, 워크플로우, 프로젝트 아키텍처 | 빌드 명령, 디버깅 인사이트, Claude가 발견한 선호도 |
  
---
  
### CLAUDE.md 파일의 위치  
`CLAUDE.md` 파일은 여러 위치에 있을 수 있으며 각각 다른 범위를 가진다.  
더 구체적인 위치가 더 광범위한 위치보다 우선돤다.  
  
| 범위         | 위치                                                                 | 목적                              | 사용 사례                                  | 공유 대상                |
|--------------|----------------------------------------------------------------------|-----------------------------------|-------------------------------------------|--------------------------|
| 관리 정책     | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux 및 WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | IT/DevOps에서 관리하는 조직 전체 지침 | 회사 코딩 표준, 보안 정책, 규정 준수 요구사항 | 조직의 모든 사용자        |
| 프로젝트 지침 | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md`                              | 프로젝트에 대한 팀 공유 지침       | 프로젝트 아키텍처, 코딩 표준, 일반적인 워크플로우 | 소스 제어를 통한 팀 멤버 |
| 사용자 지침   | `~/.claude/CLAUDE.md`                                                 | 모든 프로젝트에 대한 개인 선호도   | 코드 스타일 선호도, 개인 도구 단축키         | 본인만 (모든 프로젝트)    |
  
> 작업 디렉토리 상위에 있는 CLAUDE.md 파일은 시작 시 모두 로드된다.  
> 하위 디렉토리의 CLAUDE.md는 Claude가 해당 디렉토리의 파일을 읽을 때 필요에 따라 로드된다.  
  
---
  
### 프로젝트 CLAUDE.md 생성  
프로젝트 CLAUDE.md는 `./CLAUDE.md` 또는 `./.claude/CLAUDE.md`에 저장할 수 있다.  
`/init` 명령을 실행하여 자동생성하는 방법과 직접 경로안에 CLAUDE.md 파일을 생성하는 방법이 있다.  
```
# 기본 초기화
# /init 명령어 실행 → 코드베이스 분석 → CLAUDE.md 생성
/init
```  
  
### CLAUDE.md 작성  
CLAUDE.md는 새로운 세션이 시작될 때마다 컨텍스트 윈도우에 로드되어 대화 토큰을 소비한다.  
따라서 짧고 구체적이며 잘 구조화된 지침이 가장 효과적이다.  

* 크기 : `200줄 이하`를 목표로 작성.  
  * 파일이 길수록 토큰 소비가 늘고 Claude의 준수율이 떨어진다.  
  * 지침이 많아지면 `@path/to/import`로 가져오기나 `.claude/rules/`로 분리.  

* 구조 : 마크다운 제목과 글머리 기호를 사용하여 관련된 지침을 그룹화.  
  * 클로드는 독자와 마찬가지로 구조를 훑어본다.  
  * 잘 정리된 섹션이 빽빽한 단락보다 이해하기 쉽다.  

* 구체성 : 검증이 가능할 만큼 구체적인 지침을 작성.
  
    | 나쁜 예                      | 좋은 예                          |
    |---------------------------|-------------------------------|
    | 코드를 제대로 포맷합니다   | 2칸 들여쓰기 사용     |
    | 변경 사항을 테스트합니다   | 커밋하기 전에 `npm test` 실행 |
    | 파일을 정리된 상태로 유지합니다 | API 핸들러는 src/api/handlers/에 있습니다   |  
  
* 구체성 : 충돌하는 규칙 제거  
  * 두 규칙이 서로 모순되면 Claude가 임의로 하나를 선택할 수 있다.  
  * 여러 `CLAUDE.md` 파일과 `.claude/rules/` 전체를 정기적으로 검토하여 오래되었거나 충돌하는 지침을 제거.  

<br/>  

작성예제
```markdown
## 기술 스택
- Java 21 + Spring Boot 3.4
- Gradle (Kotlin DSL)
- PostgreSQL 16 + Spring Data JPA + QueryDSL

## 빌드 & 실행
- `./gradlew build` — 전체 빌드
- `./gradlew :api:bootRun` — API 서버 (포트 8080)
- `./gradlew test` — 전체 테스트
- 커밋 전 반드시 `./gradlew spotlessCheck test` 실행

## 모듈 구조
- `api/` — Controller, DTO (외부 노출 계층)
- `core/` — Service, Domain, Repository 인터페이스
- `infra/` — JPA 구현체, Redis/Kafka 설정

## 패키지 구조
com.mycompany.project 아래:
controller → service → repository → domain 순서.
dto는 dto/request, dto/response로 분리.

## 핵심 규칙
- DTO는 class가 아닌 Java record 사용.
- 응답 DTO에 반드시 from(Entity) 정적 팩토리 메서드.
- API 응답은 모두 ApiResponse<T>로 감싼다.
- 생성자 주입 + @RequiredArgsConstructor만 허용.
- 조회 메서드에 @Transactional(readOnly = true) 필수.
- 컨트롤러에 비즈니스 로직 금지. 서비스에 위임.
- ErrorCode enum 기반 BusinessException 사용.
- 기능 코드 변경 시 테스트도 반드시 함께 변경.
- 빌드: ./gradlew test

## 예외 처리
- ErrorCode enum 정의 → BusinessException에 전달
- 예외 메시지 하드코딩 금지

## 금지 목록
- @Autowired 필드 주입, @Data, @Setter
- System.out.println
- Optional을 파라미터로 받기
- 문자열 비교에 ==
```
  
---
  
### 파일 가져오기와 규칙 분리
`CLAUDE.md`가 길어지면 모든 내용을 한 파일에 담기보다 외부 파일을 가져오는 방식으로 분리하는 것이 좋다.  
`@path/to/import` 구문을 사용하면 가져온 파일이 확장되어 `CLAUDE.md`와 함께 컨텍스트에 로드된다.  
  
<br/>  
  
#### 기본 사용법    
```markdown
# CLAUDE.md
 
프로젝트 개요는 @README.md를 참조합니다.
빌드 설정은 @build.gradle을 참조합니다.
 
## 추가 지침
- git 워크플로우 @docs/git-instructions.md
```
 
위 예시에서 Claude는 세션 시작 시 `README.md`, `build.gradle`, `docs/git-instructions.md`의 내용을 모두 읽어들인다.  
상대 경로는 CLAUDE.md 파일 위치를 기준으로 해석되며, 절대 경로도 사용할 수 있다.  
  
<br/>  
  
#### 실전 예제: Spring Boot 멀티 모듈 프로젝트  
실제 프로젝트에서 CLAUDE.md와 가져오기를 어떻게 구성하는지 살펴보자.  
```
order-service/
├── CLAUDE.md                          ← 메인 지침 (간결하게 유지)
├── docs/
│   ├── architecture.md                ← 아키텍처 상세 설명
│   ├── api-conventions.md             ← API 설계 규칙
│   └── git-workflow.md                ← Git 브랜치/커밋 규칙
├── .claude/
│   └── CLAUDE.md                      ← 대안 위치 (둘 중 하나만 사용)
├── api/                               ← API 모듈
├── core/                              ← 도메인/비즈니스 로직 모듈
├── infra/                             ← 인프라 모듈
└── ...
```
  
<br/>  
  
`CLAUDE.md (메인 파일 — 핵심만 담고 상세 내용은 가져오기로 분리)`:  
```markdown
# Order Service
 
## 기술 스택
- Java 21 + Spring Boot 3.4
- Gradle (Kotlin DSL)
- PostgreSQL + Spring Data JPA
- Redis (캐싱)
- Kafka (이벤트 발행)
 
## 빌드 & 실행
- `./gradlew build` — 전체 빌드
- `./gradlew :api:bootRun` — API 서버 실행 (포트 8080)
- `./gradlew test` — 전체 테스트 실행
- `./gradlew :core:test` — core 모듈 테스트만 실행
- `./gradlew spotlessApply` — 코드 포맷팅
 
## 핵심 규칙
- Java 21 기능 적극 활용 (record, sealed class, pattern matching)
- 필드 주입 금지 — 생성자 주입만 사용
- 커밋 전 반드시 `./gradlew spotlessCheck test` 실행
 
## 상세 문서
- 아키텍처: @docs/architecture.md
- API 규칙: @docs/api-conventions.md
- Git 워크플로우: @docs/git-workflow.md
```
  
<br/>  
  
`docs/architecture.md (가져와지는 파일)`:  
```markdown
# 아키텍처
 
## 멀티 모듈 구조
- `api/` — Controller, DTO, 요청/응답 매핑 (외부 노출 계층)
- `core/` — 도메인 엔티티, 서비스, 리포지토리 인터페이스 (비즈니스 로직)
- `infra/` — JPA 구현체, Redis 설정, Kafka Producer/Consumer (기술 구현)
- `common/` — 공통 예외, 유틸리티, 상수
 
## 패키지 구조 (core 모듈)
- `com.example.order.domain` — 엔티티, VO, Enum
- `com.example.order.service` — 비즈니스 서비스
- `com.example.order.repository` — 리포지토리 인터페이스
- `com.example.order.event` — 도메인 이벤트
 
## 의존성 규칙
- core 모듈은 infra에 의존하지 않는다 (DIP 원칙)
- api 모듈은 core에만 의존한다
- infra 모듈은 core의 인터페이스를 구현한다
 
## 데이터베이스
- PostgreSQL 16 + Spring Data JPA
- Flyway로 마이그레이션 관리
- 마이그레이션 파일: `infra/src/main/resources/db/migration/`
- 네이밍: `V{버전}__{설명}.sql` (e.g. `V3__add_order_status_index.sql`)
```
  
<br/>  
   
`docs/api-conventions.md (가져와지는 파일)`:  
```markdown
# API 규칙
 
## 응답 형식
모든 API는 `ApiResponse<T>` 래퍼를 사용합니다:
- 성공: `{ "success": true, "data": { ... } }`
- 실패: `{ "success": false, "error": { "code": "ORDER_NOT_FOUND", "message": "..." } }`
 
## REST 규칙
- URL은 복수형 명사: `/api/v1/orders`, `/api/v1/members`
- 상태 변경은 동사 하위경로: `POST /api/v1/orders/{id}/cancel`
- 페이징: `?page=0&size=20&sort=createdAt,desc`
 
## 검증
- 요청 DTO에 Jakarta Validation 어노테이션 사용 (@NotBlank, @Size 등)
- 커스텀 검증이 필요하면 `@Valid` + 커스텀 Validator 구현
 
## 에러 코드 (ErrorCode enum 관리)
- `AUTH_REQUIRED` — 인증 필요
- `FORBIDDEN` — 권한 없음
- `ORDER_NOT_FOUND` — 주문 없음
- `INVALID_ORDER_STATUS` — 주문 상태 변경 불가
```
  
이렇게 하면 메인 `CLAUDE.md`는 40줄 이내로 간결하게 유지하면서 Claude가 필요한 상세 정보에는 모두 접근할 수 있다.  
  
<br/>  
   
#### 개인 선호도 가져오기
팀에 공유하지 않을 개인 선호도는 홈 디렉토리에서 가져온다.  
가져오기 구문은 공유 `CLAUDE.md`에 있지만 실제 파일은 본인 컴퓨터에만 존재한다.  
```markdown
# CLAUDE.md (Git에 커밋되는 파일)
 
## 프로젝트 규칙
- Google Java Style Guide 준수
- ...
 
## 개인 선호도
- @~/.claude/my-preferences.md
```
 
`~/.claude/my-preferences.md (본인 컴퓨터에만 존재)`:  
```markdown
# 내 선호도
- 한국어로 커밋 메시지 작성
- 변수명에 약어 사용 금지 (e.g. `ord` → `order`, `qty` → `quantity`)
- System.out.println 대신 항상 SLF4J Logger 사용
- 새 클래스 생성 시 Javadoc 클래스 주석 포함
- 테스트 메서드명은 한국어로 작성 (`void 주문_생성_시_재고가_차감된다()`)
```
  
> `Claude Code`가 프로젝트에서 외부 가져오기를 처음 만나면 승인 대화를 표시한다.  
> 거부하면 해당 가져오기가 비활성화된다.  
  
<br/>  
   
#### 가져오기의 기술적 세부사항  
- 상대 경로는 **작업 디렉토리가 아닌, 가져오기를 포함하는 파일 기준**으로 해석됩니다.
- 가져온 파일이 다시 다른 파일을 가져올 수 있습니다 (최대 **5단계 깊이**까지).
- `@README.md`처럼 파일명만 쓰면 CLAUDE.md와 같은 디렉토리에서 찾습니다.
- `@~/`로 시작하면 홈 디렉토리를 기준으로 합니다.
  
<br/>  
   
#### AGENTS.md와 공존하기  
다른 코딩 에이전트(Cursor, Windsurf 등)를 위한 `AGENTS.md`가 이미 있다면, CLAUDE.md에서 가져오기만 하면 된다.  
```markdown
# CLAUDE.md
 
@AGENTS.md
 
## Claude Code 전용 지침
- `core/src/main/java/**/payment/` 하위 변경 시 plan mode 사용
- PR 생성 시 자동으로 라벨 추가
```  
이렇게 하면 두 도구가 중복 없이 동일한 기본 지침을 공유하면서, Claude 전용 규칙을 추가로 지정할 수 있다.
  
---
  
### 경로별 규칙으로 정밀 제어하기

프로젝트가 커지면 "모든 파일에 동일한 규칙"을 적용하는 것이 비효율적이다.  
Controller에는 API 규칙, Service에는 트랜잭션 규칙, 테스트 코드에는 테스트 규칙이 필요하다.  
`.claude/rules/` 디렉토리와 YAML frontmatter의 `paths` 필드를 사용하면 **특정 파일 패턴에만 적용되는 규칙**을 만들 수 있다.  
  
<br/>  
   
#### 디렉토리 구조
```
order-service/
├── .claude/
│   ├── CLAUDE.md                    ← 주 프로젝트 지침
│   └── rules/
│       ├── code-style.md            ← 전체 코드 스타일 (paths 없음 → 항상 로드)
│       ├── controller.md            ← Controller 계층 전용
│       ├── service.md               ← Service 계층 전용
│       ├── entity.md                ← JPA 엔티티 전용
│       ├── testing.md               ← 테스트 파일 전용
│       ├── migration.md             ← DB 마이그레이션 전용
│       └── config/
│           └── security.md          ← Security 설정 전용
├── api/src/main/java/...
├── core/src/main/java/...
├── infra/src/main/java/...
└── ...
```  
`rules/` 하위의 모든 `.md` 파일은 재귀적으로 발견되므로 `config/`처럼 하위 디렉토리로 추가 정리도 가능하다.  
  
<br/>  
   
#### 무조건 로드되는 규칙 (paths 없음)  
`paths` frontmatter가 없는 규칙 파일은 **모든 세션에서 항상 로드**된다.  
프로젝트 전체에 적용되는 기본 규칙에 사용한다.  
  
`.claude/rules/code-style.md`:  
```markdown
# 코드 스타일
 
- Google Java Style Guide 준수 (4칸 들여쓰기)
- 최대 줄 길이: 120자
- import 와일드카드(*) 금지 — 명시적 import만 사용
- Lombok 사용 가능: @Getter, @Builder, @RequiredArgsConstructor
- Lombok @Data, @Setter 사용 금지 (불변성 위반)
- Optional은 반환 타입으로만 사용 — 파라미터, 필드에 사용 금지
- 불변 컬렉션 반환: `List.of()`, `Map.of()`, `Collections.unmodifiable*()`
```
조건부 규칙 예제들을 살펴보자.  
  
<br/>  
   
#### 예제 1: Controller 계층 규칙
`.claude/rules/controller.md`:  
```markdown
---
paths:
  - "**/controller/**/*.java"
  - "**/api/**/controller/**/*.java"
---
 
# Controller 규칙
 
- 클래스에 `@RestController` + `@RequestMapping("/api/v1/...")` 사용
- 메서드 반환 타입은 `ResponseEntity<ApiResponse<T>>`로 통일
- 비즈니스 로직 직접 작성 금지 — 반드시 Service에 위임
- 요청 DTO에 `@Valid` 적용, 검증 로직은 DTO 내부에 어노테이션으로
- Swagger 어노테이션 포함: `@Operation`, `@ApiResponse`
- 한 메서드에서 2개 이상의 Service를 호출하지 않음 (Facade 패턴 검토)
- 경로 변수에 `@PathVariable`, 쿼리에 `@RequestParam`, 본문에 `@RequestBody`
```
 
이 규칙은 Claude가 `OrderController.java`나 `MemberApiController.java` 같은 파일을 읽을 때만 컨텍스트에 로드됩니다. `OrderService.java`를 작업할 때는 로드되지 않아 불필요한 토큰 소비를 줄입니다.
  
<br/>  
   
#### 예제 2: Service 계층 규칙
`.claude/rules/service.md`:  
```markdown
---
paths:
  - "**/service/**/*.java"
  - "**/core/**/service/**/*.java"
---
 
# Service 규칙
 
- 클래스에 `@Service` + `@RequiredArgsConstructor` 사용
- 의존성은 `private final` 필드 + 생성자 주입 (필드 주입 `@Autowired` 금지)
- 읽기 전용 메서드: 클래스 레벨 `@Transactional(readOnly = true)` + 쓰기 메서드에만 `@Transactional`
- 비즈니스 예외는 커스텀 예외 사용 (e.g. `OrderNotFoundException extends BusinessException`)
- 외부 시스템 호출(API, 메시징)은 트랜잭션 밖에서 수행
- 하나의 public 메서드 = 하나의 유즈케이스
- 로깅: 메서드 진입/종료 시 `log.info()`, 예외 시 `log.error()`
```  
  
<br/>  
   
#### 예제 3: JPA 엔티티 규칙
`.claude/rules/entity.md`:  
```markdown
---
paths:
  - "**/domain/**/*.java"
  - "**/entity/**/*.java"
---
 
# JPA 엔티티 규칙
 
- `@Entity` 클래스는 `@NoArgsConstructor(access = AccessLevel.PROTECTED)` 필수
- 정적 팩토리 메서드로 생성 (`public static Order create(...)`)
- Setter 금지 — 상태 변경은 의미 있는 비즈니스 메서드로 (e.g. `cancel()`, `changeStatus()`)
- `@Enumerated(EnumType.STRING)` 사용 (ORDINAL 금지)
- 양방향 관계에 연관관계 편의 메서드 작성
- `@Column(nullable = false)` 등 제약조건 명시
- `BaseEntity`를 상속하여 `createdAt`, `updatedAt` 자동 관리
- 지연 로딩 기본: `@ManyToOne(fetch = FetchType.LAZY)`
- `equals()`/`hashCode()`는 비즈니스 키 또는 ID 기반으로 구현
```  
  
<br/>  
   
#### 예제 4: 테스트 규칙
`.claude/rules/testing.md`:  
```markdown
---
paths:
  - "**/test/**/*.java"
  - "**/testFixtures/**/*.java"
---
 
# 테스트 작성 규칙
 
- 테스트 메서드명은 한국어 스네이크 케이스: `void 주문_생성_시_재고가_차감된다()`
- Given-When-Then 패턴 준수 (주석으로 섹션 구분)
- 단위 테스트: `@ExtendWith(MockitoExtension.class)` + `@Mock` / `@InjectMocks`
- 통합 테스트: `@SpringBootTest` + `@Transactional` (자동 롤백)
- 리포지토리 테스트: `@DataJpaTest`
- 테스트 픽스처는 `**/testFixtures/` 또는 테스트 클래스 내부 헬퍼 메서드로 관리
- 외부 API 호출은 WireMock으로 모킹
- 하나의 테스트에 하나의 assertion (AssertJ `assertThat` 사용)
- 커버리지 목표: 라인 80%, 브랜치 70%
```
  
<br/>  
   
#### 예제 5: DB 마이그레이션 규칙
`.claude/rules/migration.md`:  
```markdown
---
paths:
  - "**/db/migration/**/*.sql"
  - "**/resources/db/**/*.sql"
---
 
# Flyway 마이그레이션 규칙
 
- 파일명 규칙: `V{버전}__{설명}.sql` (e.g. `V5__create_payment_table.sql`)
- 이미 적용된 마이그레이션 파일은 절대 수정 금지
- 모든 DDL에 `IF NOT EXISTS` / `IF EXISTS` 방어 구문 포함
- 인덱스 생성은 `CREATE INDEX CONCURRENTLY` 사용 (PostgreSQL)
- 대용량 테이블 변경 시 별도의 마이그레이션으로 분리
- 각 마이그레이션 파일 상단에 변경 목적 주석 작성
- 롤백 마이그레이션은 `R__` 접두사로 별도 관리
```
  
<br/>  
   
#### 예제 6: Security 설정 규칙  
`.claude/rules/config/security.md`:  
```markdown
---
paths:
  - "**/config/Security*.java"
  - "**/security/**/*.java"
  - "**/auth/**/*.java"
---
 
# Security 설정 규칙
 
- Spring Security 6.x 람다 DSL 사용 (deprecated 메서드 체이닝 금지)
- 인증: JWT 토큰 기반 (Access Token + Refresh Token)
- 비밀번호: `BCryptPasswordEncoder` 사용
- CORS 설정은 `CorsConfigurationSource` Bean으로 중앙 관리
- 공개 엔드포인트는 `requestMatchers().permitAll()`로 명시
- 권한 체크: `@PreAuthorize("hasRole('ADMIN')")` 선호
- JWT 시크릿은 환경 변수에서 주입 — 코드에 하드코딩 절대 금지
```
  
<br/>  
   
#### glob 패턴 레퍼런스
`paths` 필드에서 사용할 수 있는 주요 패턴들  
  
| 패턴 | 일치하는 대상 |
|---|---|
| `**/*.java` | 모든 디렉토리의 모든 Java 파일 |
| `**/controller/**/*.java` | 어떤 모듈이든 controller 패키지 하위 Java 파일 |
| `**/test/**/*.java` | 모든 테스트 소스 Java 파일 |
| `**/resources/**/*.yml` | 모든 리소스 YAML 파일 |
| `**/db/migration/**/*.sql` | Flyway 마이그레이션 SQL 파일 |
| `**/*.{java,kt}` | 중괄호 확장 — Java와 Kotlin 모두 |
| `api/src/main/**/*.java` | api 모듈의 메인 소스만 |
  
<br/>  
   
#### 심볼릭 링크로 프로젝트 간 규칙 공유
여러 마이크로서비스에서 동일한 규칙을 사용하려면 심볼릭 링크를 활용한다.  
```bash
# 공유 규칙 디렉토리 전체를 링크
ln -s ~/shared-claude-rules .claude/rules/shared
 
# 개별 파일만 링크
ln -s ~/company-standards/security.md .claude/rules/security.md
```
  
<br/>  
   
#### 사용자 수준 규칙
`~/.claude/rules/`에 만든 규칙은 컴퓨터의 모든 프로젝트에 적용된다.  
```
~/.claude/rules/
├── preferences.md      ← 개인 코딩 선호도
└── workflows.md        ← 선호하는 워크플로우
```  
사용자 수준 규칙은 프로젝트 규칙보다 **먼저** 로드되어, 프로젝트 규칙에 더 높은 우선순위가 부여된다.  
  
<br/>  
   
#### 규칙 vs Skills — 언제 뭘 쓸까?  
  
|  | `.claude/rules/` | Skills |
|---|---|---|
| **로드 시점** | 세션 시작 또는 파일 매칭 시 자동 | 호출 시 또는 관련 프롬프트 감지 시 |
| **용도** | 항상 지켜야 할 규칙 | 특정 작업에 필요한 절차 |
| **예시** | "생성자 주입만 사용", "Setter 금지" | "배포 절차", "Flyway 마이그레이션 워크플로우" |
  
항상 컨텍스트에 있을 필요가 없는 작업별 지침은 rules 대신 skills를 사용하자.  
  
---
  
### 문제 해결
1. Claude가 CLAUDE.md를 따르지 않을 때  
   * `/memory`를 실행하여 파일이 실제로 로드되는지 확인한다.  
   * CLAUDE.md가 올바른 위치에 있는지 점검한다.  
   * 지침을 더 구체적으로 수정한다.  
   * 여러 파일에 걸쳐 충돌하는 규칙이 없는지 검토한다.  
   * 시스템 프롬프트 수준이 필요하다면 `--append-system-prompt`를 사용한다.  
  
2. `CLAUDE.md`가 너무 클 때  
   * 200줄을 초과하면 `@path` 가져오기로 별도 파일을 참조하거나, `.claude/rules/`로 분할한다.  
  
3. `/compact` 후 지침이 사라진 것 같을 때  
   * `CLAUDE.md`는 압축 후에도 디스크에서 다시 읽혀 완전히 유지된다.  
   * 사라진 지침이 있다면 대화에서만 전달하고 `CLAUDE.md`에 기록되지 않은 것이다.  
  
---

### 마치며
`CLAUDE.md` 파일과 `skills`를 적성하는데 정답은 없다.  
토큰 절약 vs 누락 방지 사이의 트레이드오프다.  
Claude가 절대 잊으면 안 된다고 생각하면 `CLAUDE.md`에 넣는 게 맞다.  
예를 들어 테스트 지침을 `CLAUDE.md`에 넣는다고 하면 테스트와 무관한 작업을 할때도 토큰이 낭비될 것이다.  
그리고 `Skill`은 Claude가 관련성을 판단해서 로드하는 건데 판단을 잘못하면 테스트 없이 코드만 수정하는 문제가 발생할 수 있다.  
이렇듯 정답은 없으므로 써보면서 나에가 맞게 조정해보자.  
    
<br/>  
  
참고 : [https://code.claude.com/docs/ko/memory](https://code.claude.com/docs/ko/memory)
