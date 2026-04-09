---
title:  "[Claude Code] 클로드 코드 설치하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---
    
나는 Window PC를 사용하므로 Window 설치를 기준 작성한다.  
<br/>  
    
### 설치 명령어  
Windows PowerShell:
```
irm https://claude.ai/install.ps1 | iex
```
<br/>  
  
Windows CMD:
```
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```
  
> Windows를 사용하려면 Git for Windows가 필요하다.  
> 설치되어 있지 않다면 먼저 설치해야한다!
> https://git-scm.com/install/windows
<br/>  
    
난 PowerShell을 사용해 설치했고 완료되면 아래와 같이 메시지가 표시된다.  
```
$ irm https://claude.ai/install.ps1 | iex

Setting up Claude Code...

√ Claude Code successfully installed!

  Version: 2.1.29

  Location: C:\Users\사용자명\.local\bin\claude.exe


  Next: Run claude --help to get started

‼ Setup notes:
  • Native installation exists but C:\Users\KKT\.local\bin is not in your PATH. Add it by opening: System Properties →
  Environment Variables → Edit User PATH → New → Add the path above. Then restart your terminal.


✅ Installation complete!
```  
> Claude Code 설치된 경로 : `C:\Users\사용자명\.local\bin\claude.exe`   
  
> 공식문서 : [https://code.claude.com/docs/ko/quickstart](https://code.claude.com/docs/ko/quickstart)   

---
  
### 설치 후 실행 명령어
powershell :
```
# 실행
claude

# 상세 모드
# (CLI가 내부적으로 무엇을 하고 있는지 더 자세한 로그를 출력하는 모드)
claude --verbose

# 디버그 모드
# verbose에 포함된 내용 전부 출력 + 추가 정보 출력
# 내부 정보 노출 가능, 성능 약간 느려질 수 있음
claude --debug

# 기존 세션 선택
# ID 또는 이름으로 특정 세션을 재개하거나 세션을 선택할 수 있는 대화형 선택기 표시
claude --resume
```
  
---
  
### 환경변수 등록
클로드 코드 설치 후 `PowerShell`을 통해 아무 경로에서나 `claude`명령어로 클로드 코드를 실행시킬 수 있어야 한다.  
하지만 환경변수가 자동으로 등록 안됬을 경우 실행이 되지 않는다.  
그럴땐 수동으로 환경변수를 등록해 줘야한다.  
1. 시스템 환경 변수 편집
2. 사용자 변수 → Path 선택 → 편집
3. C:\Users\사용자명\.local\bin 추가
4. powershell 재시작 후 진행
  
---
  
### 삭제 명령어  
Windows PowerShell:
```
Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force
```
<br/>  
  
Windows CMD:
```
del "%USERPROFILE%\.local\bin\claude.exe"
rmdir /s /q "%USERPROFILE%\.local\share\claude"
```
  
> 공식문서 : [https://code.claude.com/docs/ko/setup#claude-code-제거](https://code.claude.com/docs/ko/setup#claude-code-%EC%A0%9C%EA%B1%B0)  
  
---

### Claude Code 설정 및 캐시된 데이터를 제거  
Windows PowerShell:
```
# 사용자 설정 및 상태 제거
Remove-Item -Path "$env:USERPROFILE\.claude" -Recurse -Force
Remove-Item -Path "$env:USERPROFILE\.claude.json" -Force

# 프로젝트별 설정 제거 (프로젝트 디렉토리에서 실행)
Remove-Item -Path ".claude" -Recurse -Force
Remove-Item -Path ".mcp.json" -Force
```
<br/>  
  
Windows CMD:
```
REM 사용자 설정 및 상태 제거
rmdir /s /q "%USERPROFILE%\.claude"
del "%USERPROFILE%\.claude.json"

REM 프로젝트별 설정 제거 (프로젝트 디렉토리에서 실행)
rmdir /s /q ".claude"
del ".mcp.json"
```
<br/>  
<br/>  
- 끝 -  
