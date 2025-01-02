---
title:  "[VSCode] The type java.lang.invoke.StringConcatFactory cannot be resolved 오류"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---
### vscode 오류
> The type java.lang.invoke.StringConcatFactory cannot be resolved. It is indirectly referenced from required .class filesJava(16777540)  
vscode에서 위와 같은 오류가 발생했다.  
  
`java.lang.invoke.StringConcatFactory` 클래스는 `jdk 9`에서 도입된 클래스로 현재 java버전이 낮아서 발생하는 문제다.  
VS Code에서 커맨드 팔레트(Ctrl + Shift + P)를 열어 `Java: Configure Java Runtime`에서 jdk버전을 바꿔 주면된다.  
