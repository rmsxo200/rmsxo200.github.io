---
title:  "클로드 코드 명령어 및 단축키"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---

# 🕹️
  
### 실행 옵션  
  
| 명령어 | 설명 |
|------|------|
| `claude --resume` | 이전 세션 선택하여 시작 |
| `claude --continue` | 가장 최근 세션 이어서 시작 |
| `claude --continue --fork-session` | 다른 방향을 시도해보기 위해 가장 최근 세션 복사 (포크) |
| `claude --version` | 클로드 코드 버전 정보 확인 |
| `claude update` | 클로드 코드 버전 업데이트 |
| `claude --verbose` | 상세 모드 (CLI가 내부적으로 무엇을 하고 있는지 더 자세한 로그를 출력하는 모드) |
| `claude --debug` | 디버그 모드 (verbose에 포함된 내용 전부 출력 + 추가 정보 출력, 내부 정보 노출 가능, 성능 약간 느려질 수 있음) |
  

### 단축키  
  
| 단축키 | 설명 |
|------|------|
| `Ctrl + C` | 작업 취소 |
| `Ctrl + R` | 	이전 명령을 대화형으로 검색 |
| `Alt + V` | 클립보드 이미지 붙여넣기 |
| `Ctrl + Enter` | 줄바꿈 |
| `Esc 두 번(Esc + Esc)` | 이전 상태로 되돌리기 (또는 `/rewind` 명령) |
| `Ctrl + B` | 백그라운드로 실행 작업 (`npm run dev` 같은 개발 서버를 실행했을 때 `Ctrl + B`를 누르면 백그라운드로 전환) |
| `Ctrl+ K` | 현재 커서 마지막(end)까지 삭제 |
| `Ctrl+U` | 현재 커서에서 시작(home)까지 삭제 |
| `Ctrl+Y` | 삭제된 텍스트 붙여넣기 (`Ctrl + K`, `Ctrl + U`로 삭제한 텍스트 붙여넣기) |
  
## 명령어  
  
| 명령어 | 설명 |
|------|------|
| `/compact` | 대화 압축 (대화를 압축해 맥락을 유지하면서 컨텍스트 공간 확보) |
| `/clear` |	대화 기록을 삭제하고 컨텍스트를 확보 (완전히 새로운 대화 시작) |
| `/hooks` |	설정되어 있는 hook정보 확인 |
| `/skills` | 사용 가능한 skill 목록 보기 |
| `/stats` | 일일 사용량, 세션 기록, 연속 기록 및 모델 기본 설정을 시각화해서 보기 |
| `/status` | 버전, 모델, 계정 및 연결성을 표시. (Settings > Status 탭) |
| `/usage` | 요금제 사용 제한 및 속도 제한 상태를 표시 (Settings > usage 탭) |
| `/tasks` |	백그라운드 작업을 나열하고 관리. /bashes로도 사용 가능 |
| `/memory` | `CLAUDE.md` 파일을 편집하고, `auto-memory`를 활성화 또는 비활성화 |
| `/model` | AI 모델 변경 |
| `/permissions` | 도구 권한 규칙을 관리 |
| `/init` | 프로젝트에 `CLAUDE.md` 파일 생성 |
| `/theme` | 테마 변경 |
| `/color` | 현재 세션의 프롬프트 바 색상 설정. (사용 가능한 색상: `default, red, blue, green, yellow, purple, orange, pink, cyan`) |
| `/mcp` | `MCP`서버 연결 및 `OAuth`인증을 관리 |
| `/vim` | `Vim 모드`와 `Normal 모드` 사이를 전환 (한번 더 입력시 다시 원래대로 변경) |
| `/rename [이름]` | 세션에 이름 붙이기 (`--resume [이름]`으로 재개) |


### 빠른 명령
  
| 기호 | 설명 |
|------|------|
| `/` | 명령 또는 skill	기본 제공 명령 및 skills 참조 |
| `!` | Bash 모드	명령을 직접 실행하고 실행 출력을 세션에 추가 |
| `@` | 파일 경로 언급	파일 경로 자동 완성 트리거 |

