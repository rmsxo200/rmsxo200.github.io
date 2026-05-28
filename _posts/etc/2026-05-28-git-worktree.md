---
title: "[git] 워크트리(worktree)"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---
  
최근 AI를 많이 활용하며 `git worktree`가 다시 주목받고 있다.  
`worktree`에 대해 알아보자.  
  
<br/>
   
### 1. 워크트리(worktree)란?
 
> 하나의 저장소에서 여러 브랜치를 동시에 작업할 수 있게하는 기능이다.  

기본적으로 Git은 하나의 저장소에 하나의 작업 공간만 가진다.   
그래서 브랜치를 바꿀 때마다 폴더 내 파일들이 실시간으로 변경된다.  
하지만 `git worktree` 기능을 사용하면 동일한 저장소를 공유하면서 여러 개의 독립된 작업 공간을 생성해 사용할 수 있다.  

* 기존 방식: 하나의 폴더에서 브랜치를 왔다 갔다 전환함 (`git checkout` or `git switch`)  
* Worktree 방식: 브랜치 A는 project-alpha 폴더에 브랜치 B는 project-hotfix 폴더에 동시에 열어두고 작업 가능  

`Worktree`를 하면 지정한 경로에 신규 폴더가 생기고 `clone`한 것처럼 소스가 똑같이 복사된다.  
하지만 생성한 워크트리에는`.git 폴더`가 없고 `.git 파일`만 존재한다.  
그리거 해당 파일 안에는 원래 저장소의 `.git 폴더`를 가리키는 경로만 들어있다.  
    
저런 기능이 왜 필요한가를 생각해 보면 아래와 같은 상황에 유용하게 사용할 수 있다.  
기능 개발(Feature Branch)을 열심히 하던 중 갑자기 운영 서버에 오류가 발생해 급하게 수정(Hotfix)해서 배포해야 하는 상황을 겪어봤을 것이다.  
보통 이럴 때 우리는 하던 작업을 `git stash`로 임시 저장하고 브랜치를 전환(`git checkout`)해서 버그를 수정한 뒤 다시 돌아와 `git stash pop`을 실행하곤 한다.  
하지만 작업 중이던 환경(빌드 파일, 의존성 패키지, IDE 캐시 등)이 흐트러지거나 Stash가 꼬여서 곤란한 상황이 발생할 수 있다.  
`git worktree`를 사용하면 하나의 레포지토리에서 여러 브랜치를 서로 다른 폴더에 동시에 작업하기에 깔끔하게 작업할 수 있다.  
  
만약 두 개의 AI 에이전트 세션이 같은 디렉토리에서 동시에 파일을 고친다면 문제가 생길 것이다.
한쪽이 다른 쪽의 변경을 덮어쓰거나 반쯤 수정된 파일을 읽어서 엉뚱한 결과를 낼 수 있다.  
워크트리로 격리하면 이런 충돌이 원천적으로 차단된다.  
  
<br/>
  
### 2. 명령어

**- 새로운 워크트리 추가**
```bash
# 기본 문법
$ git worktree add <새로운_폴더_경로> <브랜치명>

# 예시 1: main 브랜치를 기준으로 /temp-hotfix 경로에 워크트리 생성
$ git worktree add ../temp-hotfix main

# 예시 2: 새 브랜치(feat/login)를 만들면서 동시에 /project-login 경로에 워크트리를 추가하고 싶을 때 (현재 브랜치 기준으로 생성)
$ git worktree add -b feat/login ../project-login

# 예시 3: 새 브랜치(feat/login)를 만들면서 동시에 /project-login 경로에 워크트리를 추가하고 싶을 때 (main 브랜치 기준으로 생성)
$ git worktree add -b feat/login ../project-login main
```
<br/>

**- 워크트리 목록 확인하기**
```bash
$ git worktree list
```
<br/>

**- 워크트리 삭제**
```bash
# 기본 문법
$ git worktree remove <폴더_경로>

# 예시 : 워크트리 경로를 지정하여 삭제
$ git worktree remove ../temp-hotfix
```
<br/>

**- 수동 삭제 폴더 흔적 지우기**  
만약 remove 명령어를 쓰지 않고 그냥 탐색기에서 폴더를 수동으로 지웠다면 Git 저장소 내부에 메타데이터 찌꺼기가 남을 수 있다.  
그래서 `git worktree list` 명령어를 사용하면 이미 삭제되었지만 표시될 수 있다.  
이때 아래 명령어를 치면 깔끔하게 정리된다.  
```bash
$ git worktree prune
```
<br/>

### 3. 실사용 예제
```bash
# 버그 수정을 위한 워크트리 생성 (main 브랜치 기준)
$ git worktree add -b hotfix/fix-login-error ../test-project-hotfix-login main

# 생성한 워크트리로 이동 (project-hotfix-login)
$ cd ../test-project-hotfix-login

# 버그 수정 후 커밋
$ git add -A
$ git commit -m "로그인 오류 수정"

# 원래 디렉터리로 이동해 머지
$ cd ../test-project
$ git checkout main
$ git merge hotfix/fix-login-error

# 핫픽스 작업 완료 후 워크트리 삭제
$ git worktree remove ../test-project-hotfix-login
$ git branch -d hotfix/fix-login-error
```
  
<br/>
  
### 주의
동일한 브랜치를 기준으로 여러개의 워크트리를 생성하고 싶은 경우 오류가 나게된다.  
같은 브랜치를 두 워크트리에서 동시에 체크아웃할 수 없다는 규칙이 있기 때문이다.  
그래서 해당 브랜치 기준으로 새 브랜치를 만들어서 워크트리를 생성해야한다.  
```bash
# main 브랜치 기준으로 워크트리 생성
$ git worktree add ./temp-hotfix1 main

# main 브랜치 기준으로 워크트리 추가 생성
$ git worktree add ./temp-hotfix2 main

# 오류 발생
Preparing worktree (checking out 'main')
fatal: 'main' is already used by worktree at 'C:/workspace/test-project/temp-hotfix'
```
  
<br/>
  
**참고 자료**  

- [Git 공식 문서 - git-worktree](https://git-scm.com/docs/git-worktree)
- [Dale Seo - git worktree 사용법](https://daleseo.com/git-worktree/)