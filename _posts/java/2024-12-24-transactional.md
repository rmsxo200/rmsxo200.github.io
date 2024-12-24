---
title:  "[Spring] 동일 클래스 호출 @Transactional 동작"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

### 문제상황  
개발중 인텔리제이 내 아래와 같은 경고 문구가 떳다.  
```
@Transactional self-invocation (in effect, a method within the target object calling another method of the target object) does not lead to an actual transaction at runtime 
```
위 내용을 확인해 보았다.  
같은 클래스 내에 있는 메서드 호출시 @Transactional 어노테이션이 있어도 트랜잭션이 적용되지 않는고 한다.  
아래와 같은 코드가 있을 경우 `testB`의 메서드 호출시 트랜잭션이 적용되지 않는다.  

```
@Service
public class testService {
    public void testA() {
        testB(); // testB 메서드 호출
    }

    @Transactional
    public void testB() {
        ...
    }
}
```  
  
### @Transactional  
@Transactional은 스프링 AOP를 기반으로 만들어진 어노테이션이다.  
그리고 AOP는 프록시 객체를 사용하는 기술이다.  
  
Spring은 메서드 또는 클래스에 @Transactional이 적용된 클래스에 대한 proxy를 생성한다.  
트랜잭션 적용을 위해서 프록시를 통해 호출하는 메서드만 인터셉트한다.  
  
`testA`에서  `testB`를 호출할때 메서드의 주체는 그 메서드를 갖고 있는 객체가 된다.  
그래서 동일 클래스에서 호출할 경우 프록시를 통해 호출하지 않는다.  
이런 이유로 트랜잭션이 적용되지 않는 문제가 발생한다.  
  
### 문제해결  
이 문제를 해결하기 위한 여러 방법이 있지만 간단하고 확실한 방법으로는 다른 클래스에서 호출하면돤다.  
`testA`와 `testB`를 별도의 클래스로 나누고 호출하도록 변경하면 이를 통해 프록시를 거칠 수 있다.  
