---
title:  "[JPA] JpaRepository 사용하기"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

> JPA를 사용하여 간단한 쿼리를 실행하려면 너무 많은 보일러플레이트 코드를 작성해야 한다.  
> Spring Data JPA는 JPA를 추상화하여 간편하게 사용하게끔 해준다.  
> 또 네이밍 규칙을 통해 JPQL작성을 자동으로 해준다.  
  
### JpaRepository 란  
Spring Data JPA에서 제공하는 인터페이스로 JPA를 사용하여 데이터베이스를 조작하기 위한 메서드들을 제공합니다.  
  
  
🍀 Spring Data JPA 사용없이 EntityManager를 사용할 경우  
```
@PersistneceContext
private EntityManager entityManager;

entityManager.createQuery("select m from Member as m where m.id = :id", Member.class)
  .setParameter("id", 1L);
```

🍀 Spring Data JPA 를 사용할 경우  
```
memberRepository.findById(1L);
```
  
`Spring Data JPA`를 사용하면 코드가 단순해 지는걸 볼 수 있다.  
  
`Spring Data JPA`에서 해당 과정을 추상화한 핵심 인터페이스는 `Repository`인터페이스다.  
  
`Repository`인터페이스는 아무런 메서드가 정의되있지 않은 마커 인터페이스로 모든 Repository는 이 인터페이스를 기반으로 확장된다.  

보통 `Spring Data JPA`를 사용할 때는 `Repository`인터페이스를 다시 상속한 인터페이스를 정의해서 사용한다.  
  
1. CrudRepository  
   * `Repository`를 상속받는 CRUD 기능을 제공하는 인터페이스  
2. PagingAndSortingRepository  
   * `CrudRepository`를 상속받는 페이징 및 정렬 기능이 추가된 인터페이스  
3. JpaRepository  
   * `PagingAndSortingRepository`를 상속받는 JPA의 특화된 여러 기능(flush(), deleteInBatch() 등)이 추가된 인터페이스  
  
위에 3개 외에도 여러 인터페이스가 있지만 세개만 정리해 보았다.  
  
이 중 가장 많이 사용하는 건 `JpaRepository`다.  
  
  
### JpaRepository 사용법

JpaRepository를 상속받는 인터페이스를 만들기만 해주면 된다.  
이떄 JpaRepository의 제네릭 타입에 엔티티의 타입과, PK 속성타입을 넣어주면 된다.
   * <`엔티티타입`, `PK타입`>  
  
```
// Member엔티티의 Repository 예시

public interface MemberRepository extends JpaRepository<Member, Long> {
}
```
  
JpaRepository를 상속받은 인터페이스는 Spring Data JPA가 자동으로 빈으로 등록한다.  
그래서 따로 @Component나 @Repository 어노테이션을 붙일 필요가 없다.  
  
### 쿼리 메소드  
  
JPA는 규칙에 맞는 이름으로 메소드를 만들어주면 쿼리를 생성할 수 있다.  

 > 기본키워드 + 엔티티 이름 + By + 조건키워드  
  
기본키워드 : findBy, existsBy, readBy, queryBy, countBy, deleteBy, getBy 등  
조건키워드 : Distinct, And, Or, Between, Like, IsNull, OrderBy 등  
  
위 규칙에서 엔티티의 이름은 생략해도 된다.  
  
-사용 예제-  
```
public interface MemberRepository extends JpaRepository<Member, Long> {
   // name으로 member조회
   List<Member> findByName(String name);

   // name과 phone으로 member조회
   List<Member> findByNameAndPhone(String name, String phone);

   // phone이 null인 member조회
   List<Member> findByPhoneIsNull();
}
```

아래에서 자세히 확인할 수 있다.  
https://docs.spring.io/spring-data/jpa/reference/jpa/query-methods.html  
  

### JPQL을 사용한 직접 쿼리 생성  
  
쿼리 메소드로 해결되지 않는 복잡한 쿼리(join등)에 대해서는 직접 쿼리를 작성하여 해결할 수 있다.  
  
@Query 어노테이션 안에 JPQL을 작성하여 간단하게 사용 가능하다.  
> JPQL: JPA에서 제공하는 쿼리로 DB테이블이 아닌 엔티티 객체와 속성을 대상으로 작성하는 쿼리  
  
-사용 예제-  
```
public interface MemberRepository extends JpaRepository<Member, Long> {
   @Query(value= "SELECT m FROM Member m WHERE m.name = :name" )
   List<Member> findMemberByName(@Param("name") String name);
}
```
`:name`은 `@Param("name")`로 인해 메서드 인자값인 `String name`와 매핑된다.

이 외에도 직접 쿼리를 작성하여 실행하는 다양한 방법들이 있다.  
<br/>
<br/>
  
참고한 글 :  
https://ksh-coding.tistory.com/153  
