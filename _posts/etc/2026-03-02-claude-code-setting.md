---
title:  "클로드 코드 settings.json 설정"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---
<br/>  
  
> Claude Code 설치 경로 : `C:\Users\사용자명\.local\bin\claude.exe`  
> 전역 settings.json 경로 : `C:\Users\사용자명\.claude`  
  
<br/>  
`settings.json`를 사용해 Claude Code를 설정할 수 있다.  
Claude Code는 스코프 시스템을 사용해서 설정이 어디에 적용되고 누구와 공유되는지를 결정한다.  
자세한건 클로드한테 물어본 결과를 적어본다.  
<br/>  
  
### Managed (최상위 / 기업용)  
IT팀이 배포하는 최상위 정책으로, 보안 정책이나 컴플라이언스 규칙처럼 모든 개발자와 프로젝트에 예외 없이 적용.  
아무도 이 설정을 오버라이드할 수 없음.  
```
파일: managed-settings.json
```
<br/>  

### User (전역 / 개인용)
모든 프로젝트에 적용되는 개인 전역 설정.  
```
파일: ~/.claude/settings.json 
```
<br/>  

### Project Shared (프로젝트 / 팀 공유)
프로젝트 디렉토리 안의 .claude/settings.json으로, git에 커밋해서 팀원과 공유하는 설정.  
```
파일: 프로젝트폴더/.claude/settings.json
```
<br/>  

### Project Local (프로젝트 / 개인 전용)
git에 커밋하지 않는 개인 실험용 설정.  
```
파일: 프로젝트폴더/.claude/settings.local.json
```
<br/>  

### 우선순위
```
Managed > User > Project Shared > Project Local
```
높은 레벨의 설정이 항상 낮은 레벨을 오버라이드.  
단, 배열 값(permissions.allow 등)은 오버라이드가 아니라 모든 레벨이 합쳐짐(merge).  
  
> 모든 프로젝트에 공통 보안 규칙 : `~/.claude/settings.json`   
> 프로젝트 규칙 : `프로젝트/.claude/settings.json`  
> 나만 쓰는 설정 : `프로젝트/.claude/settings.local.json`  
  
<br/>  
  
위 처럼 각 단계별로 나뉜다.
내가 수정할 파일은 내 모든 프로젝트에 적용시킬 전역 설정이다.  
`C:\Users\사용자명\.claude\settings.json` 파일을 수정해보자
<br/>  
  
### 파일 설정  
```
{
  "autoUpdatesChannel": "latest", // 현재 공식적으로 배포된 가장 최신 안정화 버전 자동 업데이트
  // "model": "claude-sonnet-4-5-20250929",  // 사용하고 싶은 모델을 설정가능하다.
  "language": "korean",
  "permissions": {
    "allow": [ // allow에 설정한 항목은 묻지 않고 살행한다. 아닐 걍우 실행하기 전에 사용자에게 물어보고 실행한다.
      // "Read(./**)",
      // "Edit(./**)",            // Claude Code 실행 경로 기준 모든 파일 수정을 허용 (자동 승인)
      // "Grep(./**)",            // Claude Code 실행 경로 기준 파일 내용 검색 허용
      // "Glob(./**)",            // Claude Code 실행 경로 기준 파일 패턴 매칭(파일 찾기) 허용
      // "LS(./**)",              // Claude Code 실행 경로 기준 파일 목록 확인 허용
      "Read(C:/workspace/**)",
      "Edit(C:/workspace/**)", // workspace 폴더 내 모든 파일 수정을 허용 (자동 승인)
      "Grep(C:/workspace/**)", // workspace 폴더 내 파일 내용 검색 허용
      "Glob(C:/workspace/**)", // workspace 폴더 내 파일 패턴 매칭(파일 찾기) 허용
      "LS(C:/workspace/**)",   // workspace 폴더 내 파일 목록 확인 허용
      "WebSearch(**)",         // 필요한 경우 인터넷 검색 허용

      "Bash(git add:*)",       // git 스테이징
      "Bash(git mv:*)",        // 파일 이동/이름 변경
      "Bash(git rm:*)",        // 파일 삭제 (git 관리 하에)
      "Bash(git stash:*)",     // 작업 임시 저장
      "Bash(git status:*)",     // 수정된 파일 내역 확인
      "Bash(git diff:*)",      // 변경 사항 비교
      "Bash(git log:*)",      // 커밋 이력 확인
      "Bash(git show:*)",    // 커밋 정보 확인
      
      "Bash(ls:*)",            // 파일 목록 출력
      "Bash(tree:*)",          // 디렉토리 구조 출력
      "Bash(pwd:*)",           // 현재 작업 경로 확인
      "Bash(which:*)",         // 프로그램 설치 경로 확인

      "mcp__ide__getDiagnostics" // IDE(VS Code 등)로부터 에러/경고 정보를 가져옴
    ],
    "deny": [ // 물어보고 실행하는 것도 허용하지 않고 완전히 차단하고 싶은 작업 목록
      //유닉스, 리눅스, macOS
      // "Read(~/.*)",            // 홈 디렉토리의 숨김 파일(설정 파일 등) 읽기 금지
      // "Edit(~/.*)",            // 홈 디렉토리의 숨김 파일 수정 금지
      // "Read(~/Library/**)",    // macOS 시스템 라이브러리 접근 금지
      // "Edit(~/Library/**)",    // macOS 시스템 라이브러리 수정 금지
      // "Read(~/Dropbox/**)",    // 드롭박스 동기화 폴더 접근 금지
      // "Edit(~/Dropbox/**)",    // 드롭박스 폴더 수정 금지
      // "Read(/etc/**)",        // 시스템 설정 디렉토리 접근 차단
      // "Edit(/etc/**)",        // 시스템 설정 디렉토리 접근 차단

      // window
      "Read(C:/Users/**)",
      "Edit(C:/Users/**)",
      "Read(C:/Windows/**)",
      "Edit(C:/Windows/**)",
      
      // 보안상 위험한 명령어 실행을 원천 차단
      "Bash(su:*)",            // 계정 전환 금지
      "Bash(sudo:*)",          // 관리자 권한 실행 금지
      "Bash(env:*)",           // 환경 변수 조회 금지
      "Bash(printenv:*)",      // 환경 변수 출력 금지
      "Bash(passwd:*)",        // 비밀번호 변경 금지
      "Bash(history:*)",       // 명령어 기록 조회 금지
      
      // 네트워크를 통한 데이터 유출/유입 차단
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(rsync:*)",
      "Bash(scp:*)",
      "Bash(sftp:*)",
      "Bash(socat:*)",
      "Bash(ssh:*)",
      "Bash(nc:*)",
      "Bash(ncat:*)",
      "Bash(netcat:*)",
      "Bash(nmap:*)",
      
      "Bash(git push:*)",     // 푸쉬 금지
      "Bash(git commit:*)"    // 커밋 금지
    ]
  },
  "env": {
    "DISABLE_BUG_COMMAND": "1",          // 'bug' 명령어를 비활성화함
    "DISABLE_ERROR_REPORTING": "1",      // 에러 발생 시 Anthropic에 리포트 보내지 않음
    "DISABLE_TELEMETRY": "1",            // 사용 통계(분석 데이터) 전송을 끔 (개인정보 보호)
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1" // AI가 터미널 작업 시 항상 프로젝트 루트 경로를 유지하도록 강제
  }
}

```
위 작성한 거처럼 나의 동의 없이 실행할 수 있는 항목과 절대 실행하지 않도록 설정할 수 있다.  
아래는 내가 실제 적용한 파일이다.  
> ❗모든 주석은 삭제하고 사용하자❗  
  
```
{
  "autoUpdatesChannel": "latest",
  "language": "korean",
  "permissions": {
    "allow": [
      "Read(C:/workspace/**)",
      "Edit(C:/workspace/**)",
      "Grep(C:/workspace/**)",
      "Glob(C:/workspace/**)", 
      "LS(C:/workspace/**)", 
      "WebSearch(**)",
      "Bash(git add:*)",
      "Bash(git mv:*)",
      "Bash(git rm:*)",
      "Bash(git stash:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(ls:*)",
      "Bash(tree:*)",
      "Bash(pwd:*)",
      "Bash(which:*)",
      "mcp__ide__getDiagnostics"
    ],
    "deny": [
      "Read(C:/Users/**)",
      "Edit(C:/Users/**)",
      "Read(C:/Windows/**)",
      "Edit(C:/Windows/**)",
      "Bash(su:*)",
      "Bash(sudo:*)",
      "Bash(env:*)",
      "Bash(printenv:*)",
      "Bash(passwd:*)",
      "Bash(history:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(rsync:*)",
      "Bash(scp:*)",
      "Bash(sftp:*)",
      "Bash(socat:*)",
      "Bash(ssh:*)",
      "Bash(nc:*)",
      "Bash(ncat:*)",
      "Bash(netcat:*)",
      "Bash(nmap:*)",
      "Bash(git push:*)",
      "Bash(git commit:*)"
    ]
  },
  "env": {
    "DISABLE_BUG_COMMAND": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "DISABLE_TELEMETRY": "1",
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1"
  }
}
```
<br/>  
- 끝 -  
<br/>  
<br/> 
<br/> 
  
> 참고1 : https://www.daleseo.com/claude-code-settings/  
> 참고2 : https://gist.github.com/iannuttall/a7570cee412cc05d32d7a039830f28c7  