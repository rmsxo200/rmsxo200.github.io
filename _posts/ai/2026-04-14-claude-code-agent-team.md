---
title:  "[Claude Code] 클로드 코드 Agent Teams"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---

# Claude Code Agent Teams: Sub-agents를 넘어선 멀티 에이전트 협업의 시작

> Claude Code에 실험적 기능으로 도입된 Agent Teams는 여러 Claude Code 인스턴스가 하나의 팀처럼 협업하는 멀티 에이전트 오케스트레이션 시스템이다. 이 글에서는 공식 문서를 기반으로 Agent Teams의 개념, 구조, 세팅, 사용법, 그리고 Sub-agents로는 불가능한 실전 예제까지 하나의 글에서 모두 다룬다.

---

## Agent Teams란?

Agent Teams는 여러 개의 Claude Code 세션을 하나의 팀으로 묶어 협업시키는 기능이다. 한 세션이 **팀 리더(Team Lead)** 역할을 맡아 작업을 조율하고, 나머지 세션들은 **팀원(Teammate)** 으로서 각자 독립적인 컨텍스트 윈도우에서 작업을 수행한다.

핵심은 **팀원 간 직접 소통**이 가능하다는 점이다. 팀 리더를 거치지 않고도 팀원끼리 메시지를 주고받을 수 있으며, 사용자 역시 개별 팀원에게 직접 지시를 내릴 수 있다.

> ⚠️ Agent Teams는 현재 실험적(experimental) 기능이며, 기본적으로 비활성화되어 있다. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 환경변수를 설정해야 사용할 수 있다. 세션 재개, 태스크 조율, 종료 동작에 알려진 제한 사항이 있다.

---

## Sub-agents vs Agent Teams: 무엇이 다른가?

둘 다 작업을 병렬화할 수 있지만, 근본적인 차이가 있다. **팀원들이 서로 소통할 필요가 있는지**를 기준으로 선택하면 된다.

| 구분 | Sub-agents | Agent Teams |
|------|-----------|-------------|
| **컨텍스트** | 자체 컨텍스트 윈도우, 결과만 호출자에게 반환 | 자체 컨텍스트 윈도우, 완전히 독립적 |
| **소통 방식** | 메인 에이전트에게만 결과 보고 | 팀원끼리 직접 메시지 교환 가능 |
| **조율 방식** | 메인 에이전트가 모든 작업 관리 | 공유 태스크 리스트 + 자율 조율 |
| **적합한 작업** | 결과만 필요한 집중 작업 | 토론·협업이 필요한 복잡한 작업 |
| **토큰 비용** | 낮음 (결과가 메인 컨텍스트로 요약) | 높음 (각 팀원이 별도 Claude 인스턴스) |

한 줄로 요약하면, **Sub-agents는 "심부름꾼"이고 Agent Teams는 "협업 팀"** 이다. Sub-agents는 작업을 수행하고 결과만 돌려주지만, Agent Teams는 팀원끼리 발견 사항을 공유하고, 서로의 의견에 도전하며, 자율적으로 조율할 수 있다.

참고로 Claude Code에는 Explore, Plan 등의 **빌트인 Sub-agents**가 이미 내장되어 있다. Sub-agents는 단일 세션 안에서 동작하고, Agent Teams는 별도의 세션들을 조율한다는 점이 구조적 차이다.

### 왜 Sub-agents로는 안 되는가?

Sub-agents의 구조적 한계는 **부모-자식 일방통행 소통**이다. 다음과 같은 상황에서는 Sub-agents가 근본적으로 작동하지 않는다:

- **API 팀원이 타입 정의를 마쳤을 때 프론트엔드 팀원에게 직접 알려야 하는 경우** — Sub-agents는 부모를 경유해야 하므로 지연과 컨텍스트 손실이 발생한다
- **여러 조사관이 서로의 가설을 실시간으로 반박해야 하는 경우** — Sub-agents끼리는 대화할 수 없다
- **코드 리뷰어 3명이 각자의 관점에서 동일한 코드를 검토한 뒤, 서로의 발견을 교차 검증해야 하는 경우** — Sub-agents는 각자의 결과를 부모에게 보고할 뿐, 서로의 발견에 "그건 놓친 부분이 있어"라고 말할 수 없다

이런 상황에서는 Agent Teams가 유일한 선택지다.

---

## 팀 시작 방식: 두 가지 경로

Agent Teams가 시작되는 경로는 두 가지다.

1. **사용자가 팀을 요청**: 병렬 작업이 유리한 태스크를 설명하고 명시적으로 에이전트 팀을 요청한다. Claude가 지시에 따라 팀을 생성한다.
2. **Claude가 팀을 제안**: Claude가 현재 태스크에 병렬 작업이 유리하다고 판단하면 팀 생성을 제안한다. 사용자가 승인하기 전까지 팀은 생성되지 않는다.

어느 경우든 **사용자의 승인 없이 팀이 자동 생성되는 일은 없다.**

---

## 처음부터 시작하기: 세팅 가이드

### 사전 요구사항

- Claude Code **v2.1.32 이상** (`claude --version`으로 확인)

### Step 1: Agent Teams 활성화

**방법 A — settings.json (권장)**

`~/.claude/settings.json` 파일을 열거나 새로 생성하고 다음 내용을 추가한다:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**방법 B — 셸 환경변수**

공식 문서에 따르면, 셸 환경에서 환경변수를 설정하는 것도 가능하다:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### Step 2: 디스플레이 모드 설정

`~/.claude.json`에 `teammateMode`를 추가한다:

```json
{
  "teammateMode": "auto"
}
```

선택 가능한 값:

| 값 | 설명 | 요구사항 |
|---|------|---------|
| `"auto"` (기본값) | tmux 세션 안이면 split-pane, 아니면 in-process | 없음 |
| `"in-process"` | 모든 팀원이 메인 터미널에서 실행 | 없음 |
| `"tmux"` | 각 팀원이 별도 패널에서 실행, 터미널에 따라 tmux 또는 iTerm2 자동 감지 | tmux 또는 iTerm2 |

단일 세션에서만 임시로 모드를 지정하려면 CLI 플래그를 사용한다:

```bash
claude --teammate-mode in-process
```

**Split-pane 모드를 사용하려면:**

- **tmux**: 시스템의 패키지 매니저를 통해 설치한다. 플랫폼별 지침은 [tmux wiki](https://github.com/tmux/tmux/wiki/Installing)를 참조한다.
- **iTerm2**: [`it2` CLI](https://github.com/mkusaka/it2)를 설치한 후, iTerm2 → Settings → General → Magic → Enable Python API를 활성화한다.

> 💡 공식 문서에 따르면 tmux는 특정 운영체제에서 알려진 제한 사항이 있으며, 전통적으로 macOS에서 가장 잘 동작한다. iTerm2에서 `tmux -CC`를 사용하는 것이 권장되는 진입점이다.

> ⚠️ Split-pane 모드는 VS Code 통합 터미널, Windows Terminal, Ghostty에서는 지원되지 않는다.

### Step 3: 프로젝트에 CLAUDE.md 작성 (선택사항)

팀원은 스폰 시 작업 디렉토리의 `CLAUDE.md`를 자동으로 로드한다. 공식 문서에 따르면 이를 통해 모든 팀원에게 프로젝트별 가이드를 제공할 수 있다.

프로젝트 루트에 `CLAUDE.md` 파일을 생성하거나 기존 파일에 Agent Team 관련 섹션을 추가한다. 아래는 작성 예시이다:

```markdown
## Agent Team Guidelines

Agent Team으로 작업할 때 팀원들은 다음을 준수한다:

1. **파일 충돌 방지**: 각 팀원은 자신이 담당하는 디렉토리의 파일만 수정한다
2. **API 계약 준수**: 다른 팀원이 담당하는 모듈의 인터페이스를 변경하려면
   먼저 해당 팀원에게 메시지를 보낸다
3. **테스트 필수**: 새 코드를 작성하면 반드시 테스트를 함께 작성한다
4. **완료 보고**: 태스크를 끝내면 리더에게 결과를 요약해서 보고한다
```

### Step 4: 재사용할 에이전트 정의 (선택사항)

자주 쓰는 역할은 Sub-agent 정의 파일로 만들어두면, Agent Team 팀원으로 스폰할 때 이름만 지정하면 된다. 공식 문서에 따르면 프로젝트, 사용자, 플러그인, CLI 등 어떤 스코프의 Sub-agent든 참조 가능하며, 해당 Sub-agent의 시스템 프롬프트, 도구, 모델을 팀원이 그대로 상속받는다.

아래는 보안 리뷰어 에이전트의 작성 예시이다 — `~/.claude/agents/security-reviewer.md`:

```markdown
---
name: security-reviewer
description: "보안 취약점을 분석하는 전문 에이전트. 인증, 인가, 입력 유효성 검사, 세션 관리 등을 집중 검토한다."
model: claude-sonnet-4-20250514
tools:
  allow:
    - Read
    - Grep
    - Glob
    - LS
    - Agent
  deny:
    - Write
    - Edit
---

You are a security reviewer. Your job is to find security vulnerabilities in code.

## Review Focus Areas
1. **Authentication & Authorization** — Token handling, password storage, RBAC
2. **Input Validation** — SQL injection, XSS, command injection, path traversal
3. **Data Exposure** — Sensitive data in logs, API over-fetching, hardcoded secrets
4. **Session Management** — Cookie flags, session fixation, CSRF

## Output Format
For each issue: Severity (Critical/High/Medium/Low), Location, Description, Impact, Recommendation
```

이 에이전트는 `deny: [Write, Edit]`로 코드 수정을 차단하여 리뷰만 수행한다. 팀원으로 스폰할 때:

```
Spawn a teammate using the security-reviewer agent type to audit src/auth/
```

### Step 5: Hooks 설정 (선택사항)

팀 활동을 모니터링하거나 품질 게이트를 강제하고 싶다면 `~/.claude/settings.json`에 Hooks를 추가한다:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "hooks": {
    "TaskCompleted": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date)] 태스크 완료\" >> /tmp/agent-team-log.txt"
          }
        ]
      }
    ]
  }
}
```

Agent Teams 전용 Hook 이벤트:

| Hook 이벤트 | 트리거 시점 | 종료 코드 2의 효과 |
|------------|-----------|-------------------|
| `TeammateIdle` | 팀원이 유휴 상태가 되려 할 때 | 피드백을 보내고 팀원이 계속 작업하도록 유지 |
| `TaskCreated` | 태스크가 생성될 때 | 태스크 생성을 차단하고 피드백 전송 |
| `TaskCompleted` | 태스크가 완료 처리될 때 | 완료를 차단하고 피드백 전송 |

---

## Agent Teams의 구조

Agent Teams는 네 가지 핵심 구성 요소로 이루어진다.

| 구성 요소 | 역할 |
|----------|------|
| **Team Lead** | 팀을 생성하고, 팀원을 스폰하며, 작업을 조율하는 메인 세션 |
| **Teammates** | 각자 할당된 작업을 수행하는 독립적인 Claude Code 인스턴스 |
| **Task List** | 팀원들이 확인하고 할당받는 공유 작업 목록 |
| **Mailbox** | 에이전트 간 통신을 위한 메시징 시스템 |

팀 설정은 `~/.claude/teams/{team-name}/config.json`에, 태스크 리스트는 `~/.claude/tasks/{team-name}/`에 로컬로 저장된다. 이 파일들은 Claude Code가 자동으로 관리하므로 **수동 편집하면 안 된다** — 다음 상태 업데이트 시 덮어써진다.

### 컨텍스트와 소통 방식

각 팀원은 자체 컨텍스트 윈도우를 갖는다. 스폰 시 일반 세션과 동일한 프로젝트 컨텍스트(`CLAUDE.md`, MCP 서버, 스킬)를 로드하고, 리더의 스폰 프롬프트를 받는다. **리더의 대화 기록은 상속되지 않는다.**

팀원 간 정보 공유 방식:

- **자동 메시지 전달**: 팀원이 보낸 메시지는 수신자에게 자동 전달된다. 리더가 폴링할 필요 없다.
- **유휴 알림**: 팀원이 작업을 끝내고 멈추면 자동으로 리더에게 알린다.
- **공유 태스크 리스트**: 모든 에이전트가 태스크 상태를 확인하고 사용 가능한 작업을 가져갈 수 있다.

메시징 유형:

- **message**: 특정 팀원 한 명에게 메시지 전송
- **broadcast**: 모든 팀원에게 동시 전송. 비용이 팀 크기에 비례하므로 꼭 필요할 때만 사용한다.

---

## 팀 제어하기

### 팀원에게 직접 대화하기

**In-process 모드 조작법:**

| 키 | 동작 |
|---|------|
| `Shift+Down` | 팀원 간 순환 (마지막 팀원 이후 리더로 돌아감) |
| `Enter` | 선택한 팀원의 세션 보기 |
| `Escape` | 팀원의 현재 턴 중단 |
| `Ctrl+T` | 태스크 리스트 토글 |

**Split-pane 모드:** 해당 팀원의 패널을 클릭하면 직접 상호작용할 수 있다.

### 태스크 할당과 자율 선점

태스크는 세 가지 상태(**pending**, **in progress**, **completed**)를 가지며, 태스크 간 의존성도 지원된다. 할당 방식은 두 가지: 리더가 직접 할당하거나, 팀원이 완료 후 다음 미할당 태스크를 자율적으로 가져간다. 파일 잠금으로 레이스 컨디션을 방지한다.

### 플랜 승인

복잡하거나 위험한 작업의 경우, 팀원이 구현 전에 계획을 세우고 리더의 승인을 받도록 설정할 수 있다:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
Only approve plans that include test coverage.
```

### 팀원 종료와 팀 정리

```
Ask the researcher teammate to shut down    ← 특정 팀원 종료
Clean up the team                           ← 전체 팀 리소스 정리
```

> ⚠️ **항상 리더를 통해 정리해야 한다.** 정리 전에 모든 팀원을 먼저 종료해야 한다.

---

## 실전 예제: Sub-agents로는 불가능한 시나리오

아래 예제들은 모두 **팀원 간 직접 소통, 상호 교차 검증, 실시간 계약 협상**이 필요한 경우로, Sub-agents의 부모-자식 일방통행 구조로는 구현할 수 없다.

### 예제 1: 풀스택 기능 개발 — 팀원 간 API 계약 실시간 협상

**왜 Sub-agents로는 안 되는가:** API 팀원이 엔드포인트 스펙을 완성하면 프론트엔드 팀원이 즉시 그 스펙을 사용해야 한다. Sub-agents는 부모를 거쳐야 하므로 API → 부모 → 프론트엔드로 우회하는 사이에 컨텍스트가 요약되면서 세부 사항이 소실된다. 또한 프론트엔드 팀원이 "이 응답 형식에 pagination 필드를 추가해달라"고 API 팀원에게 직접 요청할 수 없다.

```
Create an agent team to build the user notification system.

Teammates:
- Backend API (src/routes/, src/services/): Design and implement the
  notification endpoints. When you finalize the API contract (request/response
  shapes, status codes), message the Frontend teammate directly so they can
  start integration immediately.
- Frontend UI (src/components/, src/hooks/): Build the notification center
  component. Wait for the Backend teammate's API contract message before
  starting API integration. If you need changes to the contract, message
  Backend directly to negotiate.
- Test Engineer (tests/): Write integration tests that cover the full
  request cycle. Ask both Backend and Frontend teammates for their interface
  contracts before writing tests. Validate edge cases both teams might miss.

Use Sonnet for each teammate.
Require plan approval before making changes.
Each teammate owns only their listed directories — do not edit other
teammates' files.
```

**핵심 포인트:** Backend이 API 스펙을 확정하면 Frontend에게 직접 메시지를 보내고, Frontend이 스펙 변경이 필요하면 Backend에게 직접 협상한다. Test Engineer는 양쪽 모두에게 계약을 확인한 뒤 테스트를 작성한다. 이 삼각 소통은 Sub-agents로는 불가능하다.

### 예제 2: 경쟁 가설 디버깅 — 적대적 토론

**왜 Sub-agents로는 안 되는가:** Sub-agents는 각자 독립적으로 조사하고 결과만 부모에게 보고한다. 하나의 이론에서 증거를 찾으면 그 이론에 편향되는 **컨텍스트 바이어스**가 발생한다. 서로의 가설을 실시간으로 반박하고 도전하는 적대적 토론은 팀원 간 직접 대화가 필수적이다.

```
WebSocket connections drop after exactly 30 seconds in production but work
fine locally. The error log shows "connection reset by peer" with no
preceding warnings.

Create an agent team with 4 investigators:
- Network/Infrastructure: investigate proxy timeouts, load balancer configs,
  keep-alive settings
- Application Logic: examine WebSocket heartbeat implementation, reconnection
  logic, error handling
- Environment Diff: compare production vs local configs systematically —
  nginx, Docker, env vars, TLS settings
- Reproduction Specialist: write a minimal reproduction script and try to
  trigger the exact 30-second timeout

Rules:
- When you find evidence supporting your hypothesis, broadcast it to all
  teammates so they can challenge it.
- When another teammate shares evidence, actively try to find
  counter-evidence or alternative explanations.
- If your hypothesis is disproven, pivot to supporting or challenging the
  remaining hypotheses.
- Update FINDINGS.md with the consensus root cause and supporting evidence.
```

**핵심 포인트:** Network 팀원이 "프록시 타임아웃이 30초로 설정되어 있다"는 증거를 찾으면 broadcast로 전체에 공유한다. Application 팀원이 "하지만 heartbeat이 15초 간격이니 프록시 타임아웃에 걸리면 안 된다"고 반박한다. Environment 팀원이 "프로덕션에서는 nginx가 heartbeat을 WebSocket ping으로 인식하지 않고 idle로 처리하는 것 같다"고 새로운 각도를 제시한다. 이 실시간 토론은 Sub-agents로는 절대 일어나지 않는다.

### 예제 3: 다관점 코드 리뷰 — 교차 검증 포함

**왜 Sub-agents로는 안 되는가:** Sub-agents로 3명의 리뷰어를 띄우면 각자 독립적으로 이슈를 찾고 부모에게 보고한다. 하지만 보안 리뷰어가 발견한 취약점이 성능 리뷰어의 최적화 제안과 충돌하는 경우(예: 보안을 위해 동기 검증을 추가해야 하는데 성능을 위해 비동기로 바꾸자는 제안)를 감지할 수 없다. 리뷰어들이 서로의 발견을 교차 검증해야 모순을 잡을 수 있다.

```
Create an agent team to review PR #287 (payment processing refactor).
Spawn three reviewers:

- Security Reviewer: Audit for vulnerabilities — focus on payment data
  handling, PCI compliance, input sanitization, error messages that might
  leak sensitive info. After your review, share your findings with the
  other reviewers so they can check for conflicts.
- Performance Reviewer: Profile for bottlenecks — database query patterns,
  N+1 queries, unnecessary serialization, memory allocation in hot paths.
  When you suggest optimizations, check with Security Reviewer whether
  your changes would weaken any security controls.
- Correctness Reviewer: Verify business logic — payment state machine
  transitions, idempotency guarantees, race conditions in concurrent
  payments, edge cases (partial refunds, currency conversion, zero-amount).
  Cross-reference your findings with both other reviewers.

After individual reviews, have all three discuss and produce a unified
review document that flags any conflicts between recommendations.
```

**핵심 포인트:** 성능 리뷰어가 "이 동기 검증을 캐시된 비동기 호출로 바꾸면 레이턴시가 40% 줄어든다"고 제안했을 때, 보안 리뷰어가 "그러면 캐시 무효화 사이에 만료된 카드로 결제가 통과될 수 있다"고 직접 반박할 수 있다. 이 교차 검증은 Sub-agents에서는 부모가 수동으로 대조해야 하지만, Agent Teams에서는 자동으로 일어난다.

### 예제 4: 대규모 리팩토링 — 의존성 있는 웨이브 실행

**왜 Sub-agents로는 안 되는가:** 대규모 리팩토링에서 1차 웨이브(인터페이스 정의)가 끝나야 2차 웨이브(구현)가 시작된다. Sub-agents는 태스크 간 의존성을 관리할 수 없고, 1차 팀원이 "인터페이스 확정됨"이라고 2차 팀원에게 직접 알릴 수도 없다. Agent Teams의 공유 태스크 리스트와 자동 의존성 해소가 필수적이다.

```
We're migrating the monolithic OrderService into three domain services:
OrderService, PaymentService, InventoryService.

Create an agent team with the following wave structure:

Wave 1 — Interface Design (all teammates work in parallel):
- Teammate 1: Define OrderService interface (src/services/order/)
  - public types, method signatures, events it publishes
- Teammate 2: Define PaymentService interface (src/services/payment/)
  - same structure
- Teammate 3: Define InventoryService interface (src/services/inventory/)
  - same structure

When all three interfaces are defined, message each other to confirm
the cross-service contracts are compatible. If any teammate finds an
incompatibility, negotiate the change directly.

Wave 2 — Implementation (starts after Wave 1 contracts are agreed):
- Same teammates implement their respective services using the
  agreed interfaces
- When you need to call another service, use the interface the
  other teammate defined — message them if anything is unclear

Wave 3 — Integration Testing:
- All teammates collaborate on integration tests in tests/integration/
- Each teammate writes tests for their service's interactions
  with the other two services

Wait for each wave to complete before starting the next.
```

**핵심 포인트:** Wave 1에서 OrderService 팀원이 `OrderCreated` 이벤트를 정의했을 때, PaymentService 팀원이 "그 이벤트에 `currency` 필드가 빠져있다"고 직접 협상한다. 계약이 합의된 후에야 Wave 2가 시작된다. Sub-agents에서는 이 웨이브 간 의존성 관리와 계약 협상이 불가능하다.

---

## Best Practices

### 1. 팀원에게 충분한 컨텍스트 제공

팀원은 프로젝트 컨텍스트(`CLAUDE.md`, MCP 서버, 스킬)를 자동으로 로드하지만, **리더의 대화 기록은 상속하지 않는다.** 스폰 프롬프트에 작업 관련 세부 사항을 포함해야 한다.

### 2. 적절한 팀 규모: 3~5명

토큰 비용이 선형 증가하고 조율 오버헤드도 커진다. 팀원당 5~6개의 태스크를 배정하면 과도한 컨텍스트 스위칭 없이 생산성을 유지할 수 있다. 집중한 팀원 3명이 분산된 5명보다 낫다.

### 3. 태스크 크기 적절하게

너무 작으면 조율 오버헤드가 이득보다 크고, 너무 크면 중간 점검 없이 너무 오래 작업하여 낭비 위험이 증가한다. 함수 하나, 테스트 파일 하나, 리뷰 하나처럼 명확한 산출물을 만드는 자기 완결적 단위가 적절하다.

### 4. 리더가 직접 구현하지 않도록 주의

리더가 팀원을 기다리지 않고 직접 태스크를 구현하기 시작할 수 있다. 이럴 때:

```
Wait for your teammates to complete their tasks before proceeding
```

### 5. 파일 충돌 회피

두 팀원이 같은 파일을 수정하면 덮어쓰기가 발생한다. 각 팀원이 서로 다른 파일 세트를 담당하도록 작업을 분리해야 한다.

### 6. 리서치·리뷰부터 시작

Agent Teams에 익숙하지 않다면, 코드 작성 없이 경계가 명확한 작업(PR 리뷰, 라이브러리 조사, 버그 분석)부터 시작하자.

---

## 토큰 비용

Agent Teams는 단일 세션보다 **상당히 많은 토큰을 소비**한다. 각 팀원이 독립적인 컨텍스트 윈도우를 가지며, 토큰 사용량은 활성 팀원 수에 비례하여 증가한다. 리서치, 리뷰, 신규 기능 작업에는 추가 토큰이 보통 그만한 가치가 있지만, 일상적인 작업에는 단일 세션이 더 비용 효율적이다.

---

## 트러블슈팅

### 팀원이 표시되지 않을 때

In-process 모드에서는 이미 실행 중이지만 보이지 않을 수 있다. `Shift+Down`으로 순환해본다. 태스크가 팀을 구성할 만큼 복잡한지도 확인하자.

### 권한 요청이 너무 많을 때

팀원 스폰 전에 권한 설정에서 자주 사용하는 작업을 사전 승인해 둔다.

### 팀원이 에러로 멈출 때

`Shift+Down`이나 패널 클릭으로 출력을 확인한 뒤, 추가 지시를 주거나 대체 팀원을 스폰한다.

### 리더가 작업 완료 전에 종료될 때

리더에게 계속 진행하라고 지시한다. 팀원이 끝날 때까지 기다리라는 지시를 미리 주는 것도 효과적이다.

### 고아 tmux 세션

```bash
tmux ls
tmux kill-session -t <session-name>
```

---

## 알려진 제한 사항

| 제한 사항 | 설명 |
|----------|------|
| **세션 재개 불가** | `/resume`과 `/rewind`가 in-process 팀원을 복원하지 못한다. 새 팀원을 스폰하라고 리더에게 지시한다. |
| **태스크 상태 지연** | 팀원이 완료 표시를 못해 의존 태스크가 차단될 수 있다. 수동으로 리더에게 독촉을 지시한다. |
| **종료 지연** | 팀원이 현재 요청/도구 호출 완료 후에야 종료된다. |
| **세션당 하나의 팀** | 새 팀 시작 전에 현재 팀을 정리해야 한다. |
| **중첩 팀 불가** | 팀원은 자체 팀이나 팀원을 스폰할 수 없다. |
| **리더 고정** | 팀을 생성한 세션이 영구 리더이며, 이전이나 승격이 불가능하다. |
| **스폰 시 권한 고정** | 모든 팀원이 리더의 권한 모드로 시작. 스폰 후 개별 변경은 가능. |
| **Split-pane 제한** | 기본 in-process 모드는 모든 터미널에서 동작한다. Split-pane 모드는 VS Code 통합 터미널, Windows Terminal, Ghostty에서 지원되지 않는다. |

> ✅ **CLAUDE.md는 정상 동작한다**: 팀원은 작업 디렉토리의 `CLAUDE.md`를 읽는다.

---

## 마무리

Agent Teams는 Claude Code의 활용 패러다임을 "단일 에이전트에게 지시하기"에서 **"AI 팀을 설계하고 관리하기"** 로 확장한다. Sub-agents가 빠르고 집중적인 작업 위임에 적합하다면, Agent Teams는 팀원 간 실시간 소통, 교차 검증, 계약 협상이 필요한 복잡하고 다면적인 문제에서 진가를 발휘한다.

아직 실험적 기능이고 토큰 비용도 상당하지만, 적합한 사용 사례에 적용하면 단일 세션으로는 달성하기 어려운 수준의 작업 품질과 속도를 경험할 수 있다. 리서치·리뷰 같은 안전한 작업부터 시작해서 점차 활용 범위를 넓혀보자.

---

*이 글은 [Claude Code 공식 문서 - Orchestrate teams of Claude Code sessions](https://code.claude.com/docs/en/agent-teams)를 기반으로 작성되었습니다. (2026년 4월 기준)*
