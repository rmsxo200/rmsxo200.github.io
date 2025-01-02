---
title:  "[VSCode] VSCode에서 Java 사용하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---
### 플러그인 설치
1. Extension Pack for Java  
2. Lombok Annotations Support for VS Code  
> ![이미지](/imgs/vscode/vscode_java1.png)  
  
<br/>
  
### 프로젝트 생성
1. 커맨드 팔레트(Command Palette) 열기
   * Window: Ctrl + Shift + P  
   * Mac: Cmd + Shift + P  
2. `create java project` 검색  
3. 이후 빌드 도구 및 생성경로 등을 설정  
> ![이미지](/imgs/vscode/vscode_java2.png)  
    
<br/>
  
### 설정
1. 커맨드 팔레트(Command Palette) 열기
   * Window: Ctrl + Shift + P  
   * Mac: Cmd + Shift + P  
2. `Configure Java Runtime`을 검색  
> ![이미지](/imgs/vscode/vscode_java3.png)  
3. 나타나는 창에서 `Classpath`에 `JDK Runtime` 탭에서 jdk 버전을 설정  
> ![이미지](/imgs/vscode/vscode_java4.png)  
4. VSCode 재시작  
*  🧭작업공간에 Java 프로젝트가 열려있어야 설정이 가능하다🧭  
  
<br/>
    
### lombok설정 추가
1. 생성된 프로젝트에 `build.gradle` 파일 열기  
2. `dependencies` 추가
  
```
dependencies {
  ...

  compileOnly 'org.projectlombok:lombok:1.18.30' //lombok 관련 추가
  annotationProcessor 'org.projectlombok:lombok:1.18.30' //lombok 관련 추가
  testCompileOnly 'org.projectlombok:lombok:1.18.30' //lombok 관련 추가
  testAnnotationProcessor 'org.projectlombok:lombok:1.18.30' //lombok 관련 추가

  ...
}
```
  
<br/>
    
### junit
test할 class를 test 경로에 놓고 `build.gradle` 파일에 의존성 추가를 해주면 된다.  
```
dependencies {
  testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
}
```
