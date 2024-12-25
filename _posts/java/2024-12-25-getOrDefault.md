---
title:  "[Java] Map.getOrDefault()"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---
`Map`에서 `get()`을 사용할때 일치하는 키가 존재하지 않는다면 `null`을 반환한다.  
하지만 `getOrDefault()`을 사용하게 되면 `null`이 아닌 기본값을 반환한다.  
예제 코드를 보자.  
```
Map<String, Integer> testMap = new HashMap<>();
testMap.put("apple", 1);
testMap.put("banana", 2);
testMap.put("orange", 3);

testMap.get("apple"); // 결과 : 1
testMap.get("orange"); // 결과 : 3
testMap.get("strawberry"); // 결과 : null
```
`testMap.get("strawberry");`에서 일치하는 키가 없어 null을 반환했다.  
하지만 null이 반환되었을때 문제가 생길 수 있는 코드가 있다고 생각해보자.  
이럴때 굳이 `null`체크를 하지 않아도 설정한 기본값을 반환 받을수 있는게 `getOrDefault()`다.  
  
사용법은 아래와 같다.  
> getOrDefault(key, defaultValue);  
  
예제 코드를 보자.  
```
Map<String, Integer> testMap = new HashMap<>();
testMap.put("apple", 1);
testMap.put("banana", 2);
testMap.put("orange", 3);

testMap.getOrDefault("apple", 0); // 결과 : 1
testMap.getOrDefault("orange", 0); // 결과 : 3
testMap.getOrDefault("strawberry", 0); // 결과 : 0
```
