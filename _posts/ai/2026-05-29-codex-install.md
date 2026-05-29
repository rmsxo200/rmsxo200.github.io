---
title:  "[Codex] 코덱스 설치하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - ai
---

### codex란?
ChatGPT 기반 AI 코딩 에이전트로 개발부터 배포까지 모든 과정을 지원한다.  
Claude Code와 비슷하다고 보면 된다.

<br/>

### 설치
`npm`을 사용하여 설치한다.  
    * `PowerShell`를 사용해도 되지만 나는 `npm`을 사용했다.  
```bash
$ npm install -g @openai/codex
```

<br/>

### 실행
`codex` 명령어를 입력해 실행한다.  
```bash
$ codex
```

<br/>

아래와 같이 로그인 하라는 메시지가 나오게 되면 로그인을 하면 된다.
```bash
  Welcome to Codex, OpenAI's command-line coding agent

  Sign in with ChatGPT to use Codex as part of your paid plan
  or connect an API key for usage-based billing

> 1. Sign in with ChatGPT
     Usage included with Plus, Pro, Business, and Enterprise plans

  2. Sign in with Device Code
     Sign in from another device with a one-time code

  3. Provide your own API key
     Pay for what you use

  Press enter to continue
```
나의 경우 위 로그인 방법 선택 화면에서  화면에서 멈추고 아무키도 눌리지 않는 문제가 발생했엇다.  
`git bash`버전을 올려주는 방법으로 해결했다.

<br/>

로그인 후 아래처럼 설명이 나오는데 그냥 엔터누르고 진행.
```bash
  Before you start:

  Decide how much autonomy you want to grant Codex
  For more details see the                                                      Codex docs                                                                                                                                                        Codex can make mistakes                                                         Review the code it writes and commands it runs                                
  Powered by your ChatGPT account
  Uses your plan's rate limits and training
data preferences

  Press enter to continue

```

<br/>

해당 경로 신뢰할건지 묻는 화면이 나오는데 신뢰한다면 `Yes`  
```bash
✓ Signed in with your ChatGPT account

> You are in C:\workspace

  Do you trust the contents of this directory? Working with untrusted contents
  comes with higher risk of prompt injection. Trusting the directory allows       project-local config, hooks, and exec policies to load.                                                                           
  
  › 1. Yes, continue
    2. No, quit

```

<br/>

코드 실행을 얼마나 격리(sandbox)해서 할지 선택  
1번 기본으로 선택  
```bash
 Tip: GPT-5.5 is now available in Codex. It's our strongest agentic coding       model yet, built to reason through large codebases, check assumptions with      tools, and keep going until the work is done.

  Learn more: https://openai.com/index/introducing-gpt-5-5/


  Set up the Codex agent sandbox to protect your files and control network
  access. Learn more <https://developers.openai.com/codex/windows>

› 1. Set up default sandbox (requires Administrator permissions)
  2. Use non-admin sandbox (higher risk if prompt injected)
  3. Quit                                                                                                                                                         Press enter to confirm or esc to go back           
```

<br/>

추가로 `codex`는 기본적으로 `sandbox`가 활성화 되어있다.  

<br/>

공식문서 : [https://developers.openai.com/codex/cli](https://developers.openai.com/codex/cli)  
사용량 보는곳 : [https://chatgpt.com/codex/cloud/settings/analytics#usage](https://chatgpt.com/codex/cloud/settings/analytics#usage)