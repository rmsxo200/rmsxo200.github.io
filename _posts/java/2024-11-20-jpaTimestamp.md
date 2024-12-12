---
title:  "[JPA] @CreationTimestamp, @UpdateTimestamp 시간 자동 저장"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

데이터 수정시 쿼리에 자동으로 시간을 채워주기 위해 사용한다.
<br/>

### @CreationTimeStamp
`INSERT`시 현재 시간을 값으로 채워서 쿼리를 생성한다
<br/>

### @UpdateTimestamp
`UPDATE`시 현재 시간을 값으로 채워서 쿼리를 생성한다.
<br/><br/>
```
public class Member{
    
    ...

    @UpdateTimestamp
    @Column(updatable = false)
    private LocalDateTime createDttm;

    @CreationTimestamp
    @Column(insertable = false)
    private LocalDateTime updateDttm;

    ...

}
```
