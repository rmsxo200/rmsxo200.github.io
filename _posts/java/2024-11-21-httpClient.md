---
title:  "[JAVA] 서버간 통신을 위한 HttpClient 종류"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---
> **HttpClient** : HTTP를 사용하여 통신을 담당하는 라이브러리  
<br/>

### RestTemplate : 동기
  * 오래된 라이브러리로서 사용법이 매우 익숙하고 안정적
  * `WebClient`의 등장 이후 `RestTemplate`는 유지관리(`maintenance`) 모드에 들어가게 됨
  
### WebClient : 비동기
  * 스프링 5에서 새롭게 도입된 비동기 네트워크 통신 클라이언트
  * 싱글 스레드 방식을 사용하고 `Non-Blocking` 방식을 사용
  * 사용을 위해서는 `spring-webflux` 라이브러리를 추가해주어야함 (단점)
  
### RestClient : 동기
  * `HTTP Client`이며 `WebClient`의 `fluent API`와 `RestTemplate`의 인프라를 결합한 것
  * Spring 6 버전부터 `RestClient`으로 사용 권고

### Feign Client : 동기
  * 넷플릭스에서 개발한 라이브러리
  * `@Async` 어노테이션을 붙여 비동기식으로도 사용할 수 있음
  * `Spring MVC`에서 제공되는 어노테이션을 그대로 사용할 수 있음
  * 기존에 사용되던 `HttpClient` 보다 더 간편하게 사용될 수 있으며 가독성 측면에서 뛰어남
  * 통합 테스트가 비교적 간편함
  * 사용자 의도대로 커스텀이 간편함


### 공식 문서상 설명
	https://docs.spring.io/spring-framework/reference/integration/rest-clients.html

	RestClient - synchronous client with a fluent API.
	WebClient - non-blocking, reactive client with fluent API.
	RestTemplate - synchronous client with template method API.
	HTTP Interface - annotated interface with generated, dynamic proxy implementation.
  
### GPT의 설명
	간단한 동기 요청은 RestTemplate이 적합하지만, 비동기 요청이나 확장성이 필요한 경우에는 WebClient를 사용하는 것이 좋습니다.
	간결하고 선언적인 방법을 원한다면 Feign Client가 좋은 선택입니다.
	
	단순한 배치 작업이나 API 호출이 많지 않은 배치에서는 RestTemplate이 여전히 유용할 수 있습니다.
	대규모의 외부 API 호출을 병렬로 처리하고, 비동기 성능 최적화가 필요한 경우라면 WebClient가 적합합니다.
	마이크로서비스 아키텍처에서 여러 서비스와 통신하는 배치 작업이나 간단한 설정을 원한다면 Feign Client가 좋습니다.
