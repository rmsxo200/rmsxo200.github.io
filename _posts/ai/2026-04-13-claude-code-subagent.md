---
title:  "[Claude Code] 클로드 코드 Sub-agent"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---
  
### Sub-agent란  
`Sub-agent`는 `Claude Code` 안에서 특정 작업을 전담하여 처리하는데 특화된 AI 어시스턴트다.  
`Claude Code`에서는 하나의 AI가 모든 일을 처리하는 대신 작업을 여러 전문 에이전트에게 위임 하는 구조를 사용한다.  
각 `Sub-agent`는 **자기만의 독립된 컨텍스트 윈도우**에서 실행되며, 커스텀 시스템 프롬프트, 도구 접근 권한을 따로 갖는다.  
  
1. 특정 목적과 전문 영역을 가진 AI  
2. 메인 대화와 분리된 컨텍스트 사용  
3. 도구와 프롬프트를 개별적으로 설정 가능  
  
단순히 AI를 쓰는 게 아니라 AI 팀을 구성해서 협업시키는 구조다.  
  
왜 필요한가?  
Claude Code로 복잡한 작업을 하다 보면 테스트 돌리고, 코드 탐색하고, 리팩토링하면서 중간 결과물이 컨텍스트 윈도우에 쌓인다.  
그러면 금방 컨텍스트가 가득 차서 Claude가 앞의 내용을 잊기 시작한다.  
하지만 Sub-agent는 독립된 컨텍스트에서 동작한다.  
그렇기에 메인 대화가 깨끗하게 관리되고 긴 작업에서도 성능 유지될 수 있게 된다.  

---  

### 동작 구조
```
사용자
  ↓ 
메인 Claude (관리자 역할 = 오케스트레이터)
  │
  │  각 Sub-agent의 description을 보고 누구에게 위임할지 판단
  │
  ├──► Sub-agent A: 탐색 전담 (Explore)
  │       ├── 도구: Read, Grep, Glob (읽기 전용)
  │       ├── 모델: Haiku (빠르고 저렴)
  │       └── 독립 컨텍스트에서 파일 탐색, 코드 검색
  │
  ├──► Sub-agent B: 구현 전담 (General-purpose)
  │       ├── 도구: Read, Edit, Write, Bash (전체)
  │       ├── 모델: 메인 대화 상속
  │       └── 독립 컨텍스트에서 코드 수정, 멀티스텝 작업
  │
  └──► Sub-agent C: 테스트 전담 (커스텀)
          ├── 도구: Bash (실행만)
          ├── 모델: Sonnet
          └── 독립 컨텍스트에서 테스트 실행, 결과 분석

각 Sub-agent가 요약 결과만 반환
  ↓
메인 Claude가 결과 취합
  ↓
사용자에게 최종 응답 반환
```
- 각 Sub-agent는 **독립된 컨텍스트 윈도우**에서 작업한다. 내부에서 파일을 아무리 많이 읽어도 메인 대화에 쌓이지 않는다.  
- A, B, C가 **동시에 병렬 실행**될 수도 있고, A → B → C **순차 실행(체이닝)**도 가능하다.  
- Sub-agent는 **다른 Sub-agent를 생성할 수 없다.** 항상 1단계 깊이로만 동작한다.    
 
> 여러 에이전트가 병렬로 작업하면서 **서로 통신까지** 해야 한다면 Sub-agent가 아닌 [Agent Teams](https://code.claude.com/docs/ko/agent-teams)를 사용한다.    
> Sub-agent는 단일 세션 내 동작, Agent Teams는 별도 세션 간 조율이 가능하다.  
   
---
 
### 내장 Sub-agent
 
별도 설정 없이 Claude가 상황에 맞게 알아서 위임하는 내장 Sub-agent들이 있다.
 
| Sub-agent | 모델 | 역할 |
|---|---|---|
| **Explore** | Haiku | 읽기 전용 코드베이스 탐색. `quick` / `medium` / `very thorough` 세 단계. |
| **Plan** | 메인 대화 상속 | Plan 모드에서 계획 수립 전 코드베이스 리서치. |
| **General-purpose** | 메인 대화 상속 | 탐색 + 수정이 모두 필요한 복잡한 멀티스텝 작업. |
 
---
 
### 나만의 Sub-agent 만들기
 
1. Claude Code에서 `/agents` 실행
2. **Create new agent** 선택 → **Personal** 선택 
   * (`subagent`가 `~/.claude/agents/`에 저장되어 모든 프로젝트에서 사용)
3. **Generate with Claude** 선택 → 원하는 Sub-agent를 자연어로 설명하면 Claude가 자동 생성
4. 도구, 모델, 색상, 메모리 설정
5. `s` 또는 `Enter`를 눌러 저장하거나 `e`를 눌러 편집기에서 저장 및 편집하면 바로 사용 가능
 
```
code-improver agent를 사용해 이 프로젝트의 개선점을 분석해줘
```
 
---
 
### Sub-agent 파일 구조
 
`Skills`의 `SKILL.md`와 비슷한 구조다.  
YAML 프론트매터로 설정을 정의하고, 본문이 시스템 프롬프트가 된다.  
 
```markdown
---
name: code-reviewer
description: 코드 품질과 보안을 리뷰하는 전문가. 코드 변경 후 즉시 사용.
tools: Read, Grep, Glob, Bash
model: sonnet
---
 
당신은 시니어 코드 리뷰어입니다.
 
호출되면:
1. git diff로 최근 변경사항 확인
2. 수정된 파일에 집중
3. 즉시 리뷰 시작
 
리뷰 체크리스트:
- 코드 가독성과 명확성
- 중복 코드 여부
- 적절한 에러 핸들링
- 보안 취약점 (노출된 시크릿, API 키)
- 테스트 커버리지
```
 
> Claude는 `description`을 보고 자동으로 어떤 Sub-agent에 위임할지 판단한다.   
> Skills와 마찬가지로 **언제 쓰고 언제 안 쓸지** 명확히 작성하는 게 중요하다.  
   
  
### 지원되는 frontmatter 필드  
다음 필드를 YAML frontmatter에서 사용할 수 있다.  
name과 description만 필수.  
 
| 필드 | 필수 | 설명 |
|---|---|---|
| `name` | ✅ | 소문자와 하이픈으로 구성된 고유 식별자 |
| `description` | ✅ | Claude가 위임 시점을 판단하는 설명 |
| `tools` | | 허용할 도구 목록. 생략하면 모든 도구 상속 |
| `disallowedTools` | | 거부할 도구 목록 |
| `model` | | `sonnet`, `opus`, `haiku`, `inherit`(기본값) |
| `permissionMode` | | 권한 모드: `default`, `acceptEdits`, `auto`, `plan` 등 |
| `memory` | | 영속 메모리 범위: `user`, `project`, `local` |
| `background` | | `true`면 항상 백그라운드에서 실행 |
| `hooks` | | 라이프사이클 훅 정의 |
| `skills` | | 시작 시 로드할 스킬 목록 |
| `mcpServers` | | 이 Sub-agent 전용 MCP 서버 목록 |
 
---
 
### 저장 위치와 우선순위
 
| 위치 | 범위 | 우선순위 |
|---|---|---|
| Managed settings | 조직 전체 | 1 (최고) |
| `--agents` CLI 플래그 | 현재 세션 | 2 |
| `.claude/agents/` | 현재 프로젝트 | 3 |
| `~/.claude/agents/` | 모든 프로젝트 | 4 |
| Plugin의 `agents/` | 플러그인 활성화 시 | 5 (최저) |
 
- **프로젝트** Sub-agent(`.claude/agents/`)는 Git에 체크인하면 팀원과 공유할 수 있다.  
- **유저** Sub-agent(`~/.claude/agents/`)는 개인용으로 모든 프로젝트에서 사용.  
- **CLI** Sub-agent(`--agents`)는 디스크에 저장되지 않아 일회성 테스트에 유용하다.  
 
---
 
### 호출 방법
 
**1. 자연어** — Claude가 판단해서 위임
 
```
test-runner Sub-agent로 실패하는 테스트를 수정해줘
```
 
**2. @멘션** — 해당 Sub-agent 실행이 보장됨
 
```
@"code-reviewer (agent)" 인증 모듈 변경사항을 봐줘
```
 
**3. 세션 전체 적용** — 세션 전체를 해당 Sub-agent 모드로
 
```bash
claude --agent code-reviewer
```
 
---
 
### 영속 메모리
 
`memory` 필드를 설정하면 Sub-agent가 대화를 넘어 지식을 축적한다.  
코드베이스 패턴, 디버깅 인사이트, 반복되는 이슈 등을 기억하게 되는 것이다.
 
```markdown
---
name: code-reviewer
description: 코드 품질과 보안을 리뷰합니다
memory: project
---
 
코드를 리뷰하면서 발견한 패턴, 컨벤션, 
반복되는 이슈를 에이전트 메모리에 업데이트하세요.
```
 
| 범위 | 경로 | 용도 |
|---|---|---|
| `user` | `~/.claude/agent-memory/<agent-name>/` | 모든 프로젝트에 걸친 학습 |
| `project` | `.claude/agent-memory/<agent-name>/` | 프로젝트별 지식 (Git 공유 가능) |
| `local` | `.claude/agent-memory-local/<agent-name>/` | 프로젝트별 지식 (Git 제외) |
 
메모리가 활성화되면 `MEMORY.md`의 처음 200줄 또는 25KB가 자동으로 시스템 프롬프트에 포함된다.
 
> `project` 범위가 기본 추천이다. 버전 관리로 팀원과 공유할 수 있기 때문이다.
 
---
 
### 실전 활용 패턴
 
**패턴 1: 대량 출력 격리**
 
테스트 실행, 로그 처리 같은 대량 출력 작업을 위임하면 메인 대화에는 요약만 돌아온다.
 
```
Sub-agent를 사용해서 전체 테스트를 실행하고, 실패한 테스트와 에러 메시지만 보고해줘
```
 
**패턴 2: 병렬 리서치**
 
독립적인 조사를 여러 Sub-agent로 동시에 돌릴 수 있다.
 
```
인증, 데이터베이스, API 모듈을 각각 별도의 Sub-agent로 병렬 리서치해줘
```
 
**패턴 3: 체이닝**
 
A의 결과를 받아서 B에 넘기는 순차 실행.
 
```
code-reviewer Sub-agent로 성능 이슈를 찾고, 그 다음 optimizer Sub-agent로 수정해줘
```
 
---
 
### 언제 뭘 쓸까?
 
| 상황 | 사용할 것 |
|---|---|
| 대량 출력이 발생하는 작업 | Sub-agent |
| 특정 도구만 허용해야 할 때 | Sub-agent |
| 자체 완결적이고 요약만 반환하면 될 때 | Sub-agent |
| 빈번한 대화 왕복이 필요할 때 | 메인 대화 |
| 여러 단계가 컨텍스트를 공유해야 할 때 | 메인 대화 |
| 빠른 수정이 필요할 때 | 메인 대화 |
 
Sub-agent는 시작할 때 컨텍스트가 깨끗하기 때문에 정보를 다시 수집하느라 **지연이 생길 수 있다.**  
이미 맥락이 충분한 경우라면 메인 대화에서 바로 처리하는 게 빠르다.
 
---
 
### 예제
 
**코드 리뷰어** — 읽기 전용. Edit, Write가 없어 안전하다.
 
```markdown
---
name: code-reviewer
description: 코드 품질, 보안, 유지보수성을 리뷰하는 전문가. 코드 작성/수정 후 즉시 사용.
tools: Read, Grep, Glob, Bash
model: inherit
---
 
당신은 시니어 코드 리뷰어입니다.
 
호출되면:
1. git diff로 최근 변경사항 확인
2. 수정된 파일에 집중하여 즉시 리뷰 시작
 
피드백은 우선순위별로 정리:
- Critical (반드시 수정)
- Warning (수정 권장)
- Suggestion (개선 제안)
 
각 이슈에 수정 방법 예시를 포함한다.
```
 
**디버거** — 분석 + 수정이 필요하므로 Edit 도구 포함.
 
```markdown
---
name: debugger
description: 에러, 테스트 실패를 디버깅하는 전문가. 이슈 발생 시 즉시 사용.
tools: Read, Edit, Bash, Grep, Glob
---
 
당신은 루트 코즈 분석 전문 디버거입니다.
 
호출되면:
1. 에러 메시지와 스택 트레이스 캡처
2. 실패 위치 격리
3. 최소한의 수정 적용
4. 수정 동작 확인
 
증상이 아닌 근본 원인을 수정한다.
```
 
---

### 모범 사례

1. **Claude로 초안을 생성하고 반복 개선** — 처음부터 직접 쓰기보다 "Generate with Claude"로 시작하고 커스터마이징하는 게 결과가 좋다.
2. **하나의 책임에 집중** — 모든 걸 하는 Sub-agent보다 단일 역할에 집중한 Sub-agent가 더 예측 가능하고 성능이 좋다.
3. **상세한 프롬프트 작성** — 구체적인 지침, 예시, 제약 조건을 넣을수록 Sub-agent가 잘 따른다.
4. **도구 접근 최소화** — 필요한 도구만 허용한다. 보안과 집중력 모두 개선된다.
5. **프로젝트 Sub-agent는 버전 관리** — `.claude/agents/`에 있는 Sub-agent를 Git에 체크인하면 팀 전체가 활용할 수 있다.
6. **description에 "PROACTIVELY"나 "MUST BE USED" 같은 표현 사용** — Claude가 더 적극적으로 위임하도록 유도한다.

---

참고 : <https://code.claude.com/docs/ko/sub-agents>
