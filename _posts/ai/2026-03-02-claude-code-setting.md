---
title:  "[Claude Code] 클로드 코드 보안 설정"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---
<br/>  
  
> Claude Code 설치 경로 : `C:\Users\사용자명\.local\bin\claude.exe`  
> 전역 settings.json 경로 : `C:\Users\사용자명\.claude`  
> 프로젝트 settings.json 경로 : `C:\workspace\프로젝트명\.claude`  
  
<br/>  
`settings.json`를 사용해 Claude Code를 설정할 수 있다.  
Claude Code는 스코프 시스템을 사용해서 설정이 어디에 적용되고 누구와 공유되는지를 결정한다.  
자세한건 클로드한테 물어본 결과를 적어본다.  
<br/>  
  
### Claude Code 설정 범위  
  
| 범위 | 위치 | 영향을 받는 대상 | 팀과 공유 |  
| :--- | :--- | :--- | :--- |  
| **Managed** | 서버 관리 설정, `plist` / 레지스트리 또는 시스템 수준 `managed-settings.json` | 머신의 모든 사용자 | 예 (IT에서 배포) |  
| **User** | `~/.claude/` 디렉토리 | 모든 프로젝트에서 사용자 | 아니오 |  
| **Project** | 저장소의 `.claude/` | 이 저장소의 모든 협업자 | 예 (git에 커밋됨) |  
| **Local** | `.claude/settings.local.json` | 이 저장소에서만 사용자 | 아니오 (gitignored) |  

---
  
### Managed (최상위 / 기업용)  
IT팀이 배포하는 최상위 정책으로, 보안 정책이나 컴플라이언스 규칙처럼 모든 개발자와 프로젝트에 예외 없이 적용.  
아무도 이 설정을 오버라이드할 수 없음.  
```
파일: managed-settings.json
```
  
---

### User (전역 / 개인용)
모든 프로젝트에 적용되는 개인 전역 설정.  
```
파일: ~/.claude/settings.json 
```
  
---

### Project Shared (프로젝트 / 팀 공유)
프로젝트 디렉토리 안의 .claude/settings.json으로, git에 커밋해서 팀원과 공유하는 설정.  
```
파일: 프로젝트폴더/.claude/settings.json
```
  
---

### Project Local (프로젝트 / 개인 전용)
git에 커밋하지 않는 개인 실험용 설정.  
```
파일: 프로젝트폴더/.claude/settings.local.json
```
  
---

### 우선순위
```
Managed > User > Project Shared > Project Local
```
높은 레벨의 설정이 항상 낮은 레벨을 오버라이드.  
단, 배열 값(permissions.allow 등)은 오버라이드가 아니라 모든 레벨이 합쳐짐(merge).  
  
> 모든 프로젝트에 공통 보안 규칙 : `~/.claude/settings.json`   
> 프로젝트 규칙 : `프로젝트/.claude/settings.json`  
> 나만 쓰는 설정 : `프로젝트/.claude/settings.local.json`  
  
위 처럼 각 단계별로 나뉜다.
  
---
  
### 파일 설정  
이제 파일을 설정해보자.  
`settings.json`에 `permissions.deny`도구와 `Sandbox`, `Hooks`을 사용해 다층방어를 할거다.  
설정 파일의 대부분은 claude와 ChatGPT를 사용해 만들었다.  
     
| 방어 계층 | 역할 | 한계 |  
| :--- | :--- | :--- |  
| **permissions.deny** | 도구 사용 전 규칙 평가 | 버그로 우회되는 사례 보고됨 |  
| **Sandbox** | OS 레벨 파일시스템/네트워크 격리 | Bash 명령에만 적용 |  
| **Hooks (PreToolUse)** | 도구 실행 직전 스크립트로 차단 | 직접 스크립트 작성 필요 |  
  
* 위는 claude가 만들어준 표다.

**Windows는 sandbox를 아직 지원하지 않는다.**  
그래서 Windows 사용자는 WSL2를 사용해야 sendbox를 쓸 수 있다.  
> WSL2는 Linux 커널을 그대로 사용하므로 bubblewrap 샌드박스가 정상 동작한다.

```
# PowerShell에서 WSL2 설치
wsl --install

# WSL2 내부에서 의존성 설치
sudo apt install bubblewrap socat

# WSL2 안에서 Claude 실행
claude

# Claude Code 세션에서 샌드박스 활성화 ("enabled": true 상태면 자동 활성화 된다.)
/sandbox
```  
> ❗프로젝트 폴더가 `Window 경로`에 있다면 `WSL2`에서 파일 시스템 간의 경계를 넘나들어야 해서 성능 저하가 발생할 수 있다.❗  
> ❗`WSL2` 내부 디렉토리(~)에 두고 작업하는 것을 권장한다고 함.❗  
> 그냥 윈도우에서 `sendbox`를 사용하지 않는 것도 괜찮을거 같다;;;  
> 난 그냥 `PowerShell`을 사용해 `Claude Code`를 쓰고 `sendbox`는 안쓰기로 했다.  
> 아래 설정파일엔 sendbox 활성화 설정을 넣어두긴 헀다.  
   
---

### 전역 settings.json  
모든 프로젝트에 적용시킬 전역 설정 : `C:\Users\사용자명\.claude\settings.json`  
```
{
  // $schema 사용시 VS Code 같은 편집기에서 자동완성과 유효성 검사를 할 수 있게한다.
  // * 자동완성 (IntelliSense)
  // * 타입 검사 (string, number 등)
  // * 필수값 체크
  // * 오타/잘못된 키 경고
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "autoUpdatesChannel": "stable", // stable는 일반적으로 약 1주일 된 버전을 사용하여 문제가 있는 버전은 건너뛴다.
  "language": "korean",

  // ═══════════════════════════════════════
  // 🔒 Sandbox 설정 (OS 레벨 격리)
  // ═══════════════════════════════════════
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false,
    "network": {
      "allowedDomains": [
        "github.com",
        "*.githubusercontent.com",
        "*.npmjs.org",
        "registry.yarnpkg.com",
        "pypi.org",
        "files.pythonhosted.org",
        "repo.maven.apache.org",
        "search.maven.org",
        "plugins.gradle.org",
        "repo.spring.io"
      ]
    }
  },

  // ═══════════════════════════════════════
  // 🛡️ Permissions (도구 레벨 제어)
  //
  // permissions를 사용하여 Claude Code의 도구 권한을 관리
  // 규칙 순서 : deny -> ask -> allow. 
  // 첫 번째 일치하는 규칙을 우선적으로 적용한다.
  // ═══════════════════════════════════════
  "permissions": {
    "disableBypassPermissionsMode": "disable",  // --dangerously-skip-permissions 차단

    "allow": [ // Allow : Claude Code가 수동 승인 없이 지정된 도구를 사용
      // 안전한 읽기 전용 명령
      "Bash(ls:*)", "Bash(cat:*)", "Bash(head:*)", "Bash(tail:*)",
      "Bash(grep:*)", "Bash(rg:*)", "Bash(find:*)", "Bash(wc:*)",
      "Bash(echo:*)", "Bash(pwd:*)", "Bash(which:*)", "Bash(whoami:*)",

      // 개발 도구
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
      "Bash(git branch:*)",

      // 파일 빌드 도구
      "Bash(tsc:*)", "Bash(eslint:*)", "Bash(prettier:*)",

      // 파일 읽기 (프로젝트 내)
      "Read(./src/**)", "Read(./tests/**)", "Read(./docs/**)"
    ],

    "ask": [ // Ask : Claude Code가 지정된 도구를 사용하려고 할 때마다 확인 요청 후 진행
      // 확인 후 실행할 명령
      "Bash(git stash:*)",
      "Bash(docker:*)",
      "Bash(make:*)",
      "Bash(cp:*)", 
      "Bash(mv:*)",
      "Bash(mkdir:*)", 
      "Bash(touch:*)",
      "Edit(./**)",
      "Write(./**)",
      "WebFetch"
    ],

    "deny": [ // Deny : Claude Code가 지정된 도구를 사용하지 못하도록 차단
      // 권한 상승 차단
      "Bash(su:*)", "Bash(sudo:*)",

      // 환경 변수 노출 차단
      "Bash(env:*)", "Bash(printenv:*)",

      // 시스템 명령 차단
      "Bash(passwd:*)", "Bash(history:*)", "Bash(chmod 777:*)",

      // 네트워크 도구 차단 (Sandbox와 이중 방어)
      "Bash(curl:*)", "Bash(wget:*)", "Bash(rsync:*)",
      "Bash(scp:*)", "Bash(sftp:*)", "Bash(socat:*)",
      "Bash(ssh:*)", "Bash(nc:*)", "Bash(ncat:*)",
      "Bash(netcat:*)", "Bash(nmap:*)",

      // 삭제 명령 차단
      "Bash(rm:*)",

      // Git 원격 조작 차단 (프롬프트 인젝션 방어)
      "Bash(git add:*)",
      "Bash(git push:*)",
      "Bash(git commit:*)",
      "Bash(git remote:*)",
      "Bash(git fetch:*)",

      // 민감 파일 보호
      "Read(**/.env)", "Read(**/.env.*)", "Read(**/.env.local)",
      "Read(**/secrets/**)", "Read(**/*.key)", "Read(**/*.pem)",
      "Read(**/.aws/**)", "Read(**/.ssh/**)",
      "Edit(**/.env)", "Edit(**/.env.*)",
      "Edit(**/secrets/**)", "Edit(**/*.key)"
    ]
  },

  // ═══════════════════════════════════════
  // ⚙️ 환경 변수
  // ═══════════════════════════════════════
  "env": {
    "DISABLE_BUG_COMMAND": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "DISABLE_TELEMETRY": "1",
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1"
  }
}
```
> ❗모든 주석은 삭제하고 사용하자❗
  
---
  
### 프로젝트 내부 settings.json  
hook을 사용하기 위해 프로젝트 경로 밑에 `.claude'경로를 만들고 아래와 같이 파일을 생성해주자.  
```
my-project/              ← 프로젝트 루트
├── .claude/             ← .claude 폴더추가
│   ├── settings.json    ← settings.json 생성 후 hooks 등록
│   └── hooks/
│       ├── pre-bash-firewall.sh # Bash 명령 차단
│       ├── pre-edit-protect.sh  # 민감 파일 편집 차단
│       └── audit-log.sh         # Bash 명령 감사 로그
├── src/
``` 
<br/>  
  
프로젝트에 적용시킬 설정 : `프로젝트명\.claude\settings.json`  
```
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/audit-log.sh",
            "async": false
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-bash-firewall.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-edit-protect.sh"
          }
        ]
      }
    ]
  }
}
```
<br/>  

Bash 명령 차단 : `프로젝트명\.claude\hooks\pre-bash-firewall.sh`  
```
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<< "$input")

# 공백 normalize (다중 공백으로 패턴 우회 방지)
normalized=$(echo "$command" | tr -s ' ')

# ──────────────────────────────────────
# 위험 명령 차단 (regex 기반)
# ──────────────────────────────────────
if echo "$normalized" | grep -Eiq \
  '(rm\s+-rf|rm\s+-r\s+/|git\s+push\s+--force|git\s+push\s+-f|git\s+reset\s+--hard|git\s+remote\s+(add|set-url)|chmod\s+777|mkfs|dd\s+if=|:\(\)\{.*\}\s*;)' ; then
    echo "🚫 차단됨: 위험한 명령 패턴 감지" >&2
    exit 2
fi

# ──────────────────────────────────────
# 민감 파일 접근 차단
# ──────────────────────────────────────
if echo "$command" | grep -Eiq \
  '(\.env|\.ssh|\.aws|credentials|secrets/|\.key|\.pem|id_rsa)'; then
    echo "🔒 차단됨: 민감 파일 접근 감지" >&2
    exit 2
fi

# ──────────────────────────────────────
# 네트워크 도구 차단 (파이프·세미콜론 우회 방지)
# ──────────────────────────────────────
if echo "$command" | grep -Eiq \
  '(^|[|;&])\s*(curl|wget|nc|ncat|netcat|nmap|ssh|scp|sftp)\s|(\$\(|`)\s*(curl|wget|nc|ncat|netcat|nmap|ssh|scp|sftp)\s|(^|[^a-zA-Z0-9_])(curl|wget|nc|ncat|netcat|nmap|ssh|scp|sftp)([^a-zA-Z0-9_]|$)'; then
    echo "🌐 차단됨: 네트워크 도구 사용 금지" >&2
    exit 2
fi

exit 0
```
<br/>  

민감 파일 편집 차단 : `프로젝트명\.claude\hooks\pre-edit-protect.sh`  
```
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
file=$(jq -r '.tool_input.path // .tool_input.file_path // ""' <<< "$input")

# 차단할 파일 패턴 (핵심 보호만 유지)
deny_patterns=(
    "^\.env.*"
    ".*\.key$"
    ".*\.pem$"
    ".*\.secret$"
    "^\.git/.*"
    "^node_modules/.*"
    "^\.aws/.*"
    "^\.ssh/.*"
)

for pattern in "${deny_patterns[@]}"; do
    if echo "$file" | grep -Eq "$pattern"; then
        echo "🛡️ 차단됨: '$file' 파일은 보호 정책에 의해 편집할 수 없습니다." >&2
        exit 2
    fi
done

exit 0
```
<br/>  
  
Bash 명령 감사 로그 : `프로젝트명\.claude\hooks\audit-log.sh`  
* 도구가 실행되기 직전 기록 + 실행 실패나 중단 시에도 기록이 남음
  
```
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"

TS=$(date -Is)
TOOL=$(jq -r '.tool_name // ""' <<< "$input")

# =========================
# command + fallback
# =========================
CMD=$(jq -r '
  .tool_input.command //
  .tool_input.pattern //
  .tool_input.file_path //
  .tool_input.path //
  empty
' <<< "$input" | tr '\n' ' ' | xargs)

# =========================
# target 별도 유지
# =========================
FILE=$(jq -r '
  .tool_input.file_path //
  .tool_input.path //
  empty
' <<< "$input")

# =========================
# 로그
# =========================
jq -n \
  --arg ts "$TS" \
  --arg tool "$TOOL" \
  --arg cmd "$CMD" \
  --arg file "$FILE" \
  '{
    timestamp: $ts,
    tool: $tool,
    command: $cmd,
    target: $file
  }' \
  >> "$LOG_DIR/audit-$(date +%Y-%m-%d).jsonl"

exit 0
```  
<br/>  
  
추가로 윈도우에서 hook을 사용하기 위해서는 jq가 설치가 되어있어야 한다. (JSON을 다루는 CLI 도구)  
아래 명령어로 설치하면 된다.  
```
winget install jqlang.jq
```
  
리눅스 환경에서는 hook을 사용하기 위해서는 스크립트 실행 권한을 줘야한다.  
프로젝트 경로에 들어가 아래 명령어를 입력해주자.  
```
# 리눅스 환경 (WSL2)
chmod +x .claude/hooks/*.sh
```

<br/>  
- 끝 -  
<br/>  
<br/> 
<br/> 
  
> 참고1 : [https://www.daleseo.com/claude-code-settings](https://www.daleseo.com/claude-code-settings/)  
> 참고2 : [https://gist.github.com/iannuttall/a7570cee412cc05d32d7a039830f28c7](https://gist.github.com/iannuttall/a7570cee412cc05d32d7a039830f28c7)  
> 참고3 : [https://code.claude.com/docs/ko/settings](https://code.claude.com/docs/ko/settings)  
> 참고4 : [https://code.claude.com/docs/ko/permissions#permission-rule-syntax](https://code.claude.com/docs/ko/permissions#permission-rule-syntax)  
