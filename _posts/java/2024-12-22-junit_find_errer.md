---
title:  "[Junit] JPA - java.util.NoSuchElementException"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---
### 문제상황  
Github Action에서 Build중 오류가 발생했다.  
테스트코드가 실패한걸로 보였다.  
로그를 보니 아래와 같았다.  
```
java.util.NoSuchElementException at TrvlDstnMappingRepositoryTest.java:183
```  
`NoSuchElementException`오류가 발생했다.  
 컬렉션에서 존재하지 않는 요소를 가져오려 할 때 발생하는 예외다.  
 문제가 되는 부분의 소스를 보았다.  
```
TravelMain tm = travelMainRepository.findById(1L).orElseThrow();
```  
`findById()`로 id값이`1`인 데이터를 가져오는 로직이다.  
하지만 테스트코드 상단에 `TravelMain`를 저장하는 로직은 존재한다.  
그리고 로컱테스트시엔 정상적으로 동작한다.  
```
//TravelMain 저장 로직
TravelMain result = travelMainRepository.save(travelMain);
```  
`TravelMain`의 id값의 데이터 타입은 `Long`이고 자동증가하도록 되어있다.  
그렇다면 당연히 저장시 1부터 들어가기에 로컬에선 이상이 없는듯 보이지만 Github Action에서는 내가 생각이랑 다르게 값이 들어가는거 같다.  
확실치는 않지만 아래처럼 수정을 하였다.  
```
TravelMain tm = travelMainRepository.findAll().get(0);
```
위처럼 수정했더니 정상적으로 된다.  
테스트코드를 짤때 특정 PK값을 넣지 말아야 겠다.  
  
###추가  
추가로 테스트코드 실행시 sql파일을 실행시켜 pk값이 명시된 insert문을 실행하여 초기 데이터를 생성할 경우 `findById(1L)` 이런식으로 특정 id값을 입력해도 정상적으로 된다.  

```
@Sql(scripts = "/sql/travelMain/travelMainTest.sql") // SQL 파일 실행

-- travelMainTest.sql 내용
insert into travel_main
    (travel_seq, create_user_id, start_date, end_date, travel_title, create_dttm)
values
    (1, 'user1', '2024-11-01', '2024-11-02', 'test1', NOW());
```
