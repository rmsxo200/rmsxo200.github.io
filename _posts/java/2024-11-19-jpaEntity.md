---
title:  "[JPA] 엔티티(Entity) 생성"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

JPA에서 엔티티(Entity)는 관계형 데이터베이스의 테이블과 대응하며 JPA가 관리하는 클래스를 말한다.  
  
엔티티는 하나의 테이블과 매핑이 되며 클래스내 변수는 각 컬럼과 매핑된다.  
  
Java클래스로 선언하며 아래와 같이 작성한다.  

```
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long memberId;

    @Column
    private String name;

    @Builder
    public TravelMain(long memberId, String name) {
        this.memberId = memberId;
        this.name = name;
    }
}
```

## @Entity
    - @Entity를 붙인 클래스는 테이블과 매핑된다.  
    - 기본생성자가 필수적으로 있어야 한다.  
    - final, enum, interface, inner 클래스에는 사용 불가하다.  
    - 테이블에 저장할 필드는 final 키워드 사용 불가하다.  
  
<br/>

## @Table  
    - 클래스명과 테이블명이 일치하지 않을 경우 사용한다.  
    - 사용하지 않을 경우 클래스명으로 테이블이 생성된다.  
  
<br/>

## @Id
    - 해당 컬럼이 키(PK)라는 것을 의미한다.  
    - 모든 엔티티에는 반드시 @Id를 지정해야한다.  

<br/>

## @GeneratedValue
    - 기본 키를 자동으로 생성해주는 어노테이션이다. (MySQL:Auto Increment, Oracle:Sequence)  
    - strategy 속성을 사용하여 DB별 자동생성 방식과 유사하게 자동생성 전략을 지정해줄 수 있다.  
<br/>

## @Column
    - 변수명과 컬럼명이 다를 경우 혹은 컬럼의 사이즈등 제약조건들을 추가하기 위해 사용한다.  
    - 사용하지 않을 경우 변수명과 동일한 컬럼에 매핑을 시도한다.  

