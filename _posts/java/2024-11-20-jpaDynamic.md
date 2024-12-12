---
title:  "[JPA] @DynamicInsert, @DynamicUpdate 변경 항목만 수정하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

JPA의 구현체인 Hibernate는 엔티티를 수정할 때 모든 컬럼의 값을 수정한다.  
하지만 @DynamicInsert와 @DynamicUpdate를 사용하면 null값이 등록된 항목에 대해 sql이 실행하지 않도록 한다.  
예를들어 A와 B컬럼이 있을 경우 update시 엔티티에 A값이 `"test"` B값이 `null`이면 update 문 set 부분에 B에 대한 부분이 생략된다.  
```
UPDATET TEST_TABLE 
    SET A = 'TEST' 
WHERE ...
```
  
이처럼 변화가 없는 컬럼에 대해서는 실행하지 않는 기능을 제공한다.

사용 방법으로는 상단 클레스명이 선언된 윗쪽에 작성해 준다.
```
@Entity
@Getter
@DynamicInsert
@DynamicUpdate
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member {

```
<br/>

### @DynamicInsert
    - JPA에서 insert시 엔티티의 변화가 있는 컬럼에 대해서만 SQL을 실행  
<br/>

### @DynamicUpdate
    - JPA에서 update시 엔티티의 변화가 있는 컬럼에 대해서만 SQL을 실행  
<br/>
  
### JPA 사용시 모든 필드를 수정하는 이유  
    - 모든 필드를 사용 시 INSERT,UPDATE 쿼리가 항상 같기 때문에 쿼리를 미리 생성해두고 재사용 할 수 있음  
    - 따라서 @DynamicInsert와 @DynamicUpdate 사용 시 쿼리가 실행 될때 마다 변경된 필드를 동적으로 결정하기 때문에 쿼리 실행 속도를 저하 시킬 수 있음  

따라서 상황에 맞게 @DynamicInsert와 @DynamicUpdate를 사용하는게 좋다고 한다. (몇개의 필드만 자주 수정하는 경우, 필드가 많을 경우 등등) 
