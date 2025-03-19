---
title:  "헥사고날 아키텍처 (Hexagonal architecture)"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - etc
---

# 헥사고날 아키텍처(Hexagonal architecture)란 무엇인가?

![헥사고날 아키텍처 구조](/imgs/hexagonal/hexagonal-architecture.png)  
<span style="font-size:90%;color:gray;">[이미지출처 : https://tech.kakaobank.com/posts/2311-hexagonal-architecture-in-messaging-hub/]</span>  
  
헥사고날 아키텍처란 `Adapter`, `Port`, `domain`으로 구성된 계층형 아키텍처다.  
> 위 이미지에서 `Use Case`는 도메인 서비스로직, `Entity`는 도메인 모델에 해당한다.  
> `Ports and Adapter` 아키텍처 라고도 한다.  
  
<br/>  
  
### 각 계층별 특징  
**어댑터 계층(Adapter)**
  - 어댑터 계층은 외부와 소통하는 계층이다.  
  - 외부에 요청을 받는 입력 어댑터(Input Adapter)와 외부시스템에 접근하는 출력 어댑터(Output Adapter)가 나뉘어 있다.  
    - Input Adapter : 외부에 요청을 받는 어뎁터 (컨트롤러 메시지 큐 리스너 등)  
    - Output Adapter : 외부 시스템과 상호작용 (DB, 외부API 등)  
    
**포트 계층(Port)**  
  - 어댑터 계층과 도메인계층 사이 중간 인터페이스 역할을 수행하는 계층이다.  
  - 포트 계층이 도메인 계층에 접근하기에 도메인 로직이 외부 환경과 완전히 분리되어 외부 시스템이 변경되어도 도메인 로직에 영향이 가지 않는다.  
  - 입력 포트(Input Port)와 출력 포트(Output Port)로 나뉘진다.  
    - Input Port : 외부요청에 대한 처리를 하는 비즈니스 로직이다.  
    - Output Port : 출력포트는 내부에서 외부 시스템을 호출할 때 사용한다.  
  
**도메인 계층(Domain)**  
  - 핵심 비즈니스 로직을 처리하는 계층이다.
  - 외부 의존성이 배제되어 외부 환경과 독립적으로 동작한다.  
   
> 헥사고날 아키텍처의 각 계층은 위와 같은 특징이 있다.  
  
<br/>  
  
### 데이터 흐름
```
컨트롤러(Input Adapter)  →  입력포트(Input Port)  →  출력포트(Output Port)  →  DB접근(Output Adapter)  
                                   ↓                      ↳ 출력포트의 구현체는 
                       도메인모델 or Servier(domain)         Output Adapter계층에 구현 
```
  
<br/>  
  
### 헥사고날 아키텍처를 사용하는 이유  
헥사고날 아키텍처를 사용하면 저수준(infra등)의 변경사항이 고수준(domain)에 영향을 주지 않게 된다.   

포트 계층에서 비즈니스 로직이 수행되지 않고 도메인 계층을 호출하여 비즈니스 로직을 처리하기 떄문에 외부 시스템과 완전히 독립되게 되기 떄문이다.  
  
그로 인해 외부 시스템의 변경이 있을 경우 비즈니스 로직은 영향을 받지 않고 어댑터 계층만 교체하면 된다.  
  
이처럼 도메인 로직을 보호하고 기술 교체가 유연해진다.  

하지만 도메인의 순수성을 유지하려고 노력하면 역으로 생산성은 떨어지게 된다.
   
예를 들어 JPA를 사용하는 경우 를 가정하자.  
  
`도메인 계층`은 독립적이기에 `도메인 모델`과 `JPA 엔티티`를 분리하여 사용하게 된다.  
  
그렇다면 `포트 계층`에서 `도메인 계층`을 호출할 떄 `JPA 엔티티`는 `도메인 모델`로 변환되는 과정을 거쳐야 한다.  
  
그로인해 매핑하는 과정등이 존재해 로직이 복잡해 진다.  
  
또한 JPA의 변경 감지를 사용하지 못하게 된다.  
  
그렇기에 도메인계층의 순수성을 너무 고집하지 않고 상황에 따라 도메인 모델과 JPA 엔티티를 분리하지 않고 사용하는 것도 방법이다.  
  