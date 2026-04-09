---
title: "[Claude Code] 클로드 코드 펫 buddy🦜"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---

`claude code`의 소소한 재미 펫기능 `buddy`를 대충 알아보자.  
  
![buddy](/imgs/claude/claude_code_buddy.png)  
> 위는 내가 뽑은 buddy🐉
  
<br/>  
  
Buddy는 Claude Code 안에 숨겨진 가상 펫 기능이다.  
2026년 4월 1일에 이스터에그로 출시됐다.  
  
buddy는 18종, 5가지의 희귀도가 존재한다.  
`Common→Uncommon→Rare→Epic→Legendary` 순으로 희귀도가 높다.  
종류는 `오리, 거위, 고양이, 부엉이, 펭귄, 거북이, 토끼, 용, 유령, 아홀로틀, 버섯, 달팽이, 카피바라, 문어, 블롭, 선인장, 로봇, 뚱냥이`가 있다.  
  
5가지 능력치도 존재한다.  
`디버깅(DEBUGGING), 인내심(PATIENCE), 혼돈(CHAOS), 지혜(WISDOM), 비꼬기(SNARK)` 항목 각각의 능력치가 있으며 능력치에 따라 대화 스타일이 달라진다.  
AI 성능과는 관련이 없다.  
  
`/buddy` 명령어로 소환 가능하다.  
관련 명령어는 아래와 같다.  
  
```
# 버디 소환
/buddy

# 버디 쓰다듬기
/buddy pet

# 스탯 카드 표시
/buddy card

# 말풍선 제거
/buddy mute

# 말풍선 복원
/buddy unmute

# 버디 끄기
/buddy off
```
  
  
Buddy 시스템은 Bones, Soul 두 레이어로 나뉘어 있다.  

> Bones (외형/스펙) : 
> * 계정 ID를 `FNV-1a` 해시로 돌려서 결정론적으로 생성 (계정 생성과 동시에 Buddy 운명이 결정된다고 보면됨).  
> * 같은 계정이면 종족, 레어리티, 스탯, 모자 등 항상 같은 buddy가 나온다고 한다.  
> * 즉 어떤 PC에서든 같은 Anthropic 계정으로 로그인하면 종족과 레어리티는 동일하게 나온다고 한다.  

> Soul (이름/성격) : 
> * 로컬 `.claude.json` 파일에 저장된다.  
> * 경로 : `C:\Users\{사용자이름}\.claude.json`  
> * `.claude.json`파일 안에 `companion` 내용에 저장된다.  

```json
{
  ...

  "companion": {
    "name": "Inkwell",
    "personality": "A ancient dragon who calmly watches your chaos unfold with the weary wisdom of someone who's debugged civilization itself, and will only offer brutally elegant solutions wrapped in withering sarcasm.",
    "hatchedAt": 1775697486515
  }
}
```

PC의 `~/.claude.json`에서 `companion`항목을 다른 PC에 복사하면  buddy 관련 데이터(이름, 성격 등)를 완전히 똑같이 설정할 수 있다.  
  
***⚠️ 무료 사용자는 이용 불가하다 ❌ ⚠️***
