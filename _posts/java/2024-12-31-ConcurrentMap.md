---
title:  "[Java] ConcurrentMap"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---
`ConcurrentMap`은 Java의 Map 인터페이스를 확장한 것으로 멀티스레드 환경에서 안전하게 사용할 수 있는 맵 구조를 제공한다.  
이를 통해 여러 스레드가 동시에 맵에 접근하더라도 데이터의 무결성을 유지할 수 있다.  
> 동시성 이슈 해결  (`Thread-safe`한 환경)  
  
주요 특징
> 원자적 연산 지원: `putIfAbsent()`, `compute()`, `merge()`, `remove(key, value)`, `replace(key, oldValue, newValue)` 등의 원자적 메서드를 통해 동기화 없이도 원자적 연산을 수행할 수 있다.
> null값 허용 안 함: `ConcurrentMap` 구현체들은 일반적으로 `null`을 허용하지 않는다.
  
### ConcurrentHashMap
주요 구현체로는 `ConcurrentHashMap`가 있다.  
`ConcurrentHashMap`은 내부적으로 `CAS(Compare And Swap)`연산을 사용하며 스레드가 락을 획득하거나 해제하는 과정 없이 원자적(atomic)으로 값을 변경하기 때문에 전통적인 락 메커니즘에 비해 성능이 우수하다.  
또한 `Hashtable`이나 `Collections.synchronizedMap`보다 우수한 성능을 발휘한다.  
>  `Java 8` 이전에는 Map 전체 단위로 락을 걸지 않고 Map을 여러 세그먼트로 쪼개서 세그먼트 단위로 락을 걸어 사용  
>  `Java 8` 이후에는 세그먼트 구조를 제거하고 `CAS(Compare And Swap)`와 `synchronized` 블록을 조합하여 사용  
  
주요 메서드는 아래와 같다.  
  
computeIfAbsent()
* 지정된 키에 해당하는 값이 없거나 null인 경우 주어진 함수(mappingFunction)를 사용하여 값을 계산하고 맵에 저장  
* 이미 키가 존재하면 람다식은 실행되지 않고 현재 값을 반환  
```
map.computeIfAbsent("Apple", k -> 3);
```
  
computeIfPresent()
* 지정된 키가 맵에 존재하고 그 값이 null이 아닌 경우 주어진 함수(mappingFunction)를 사용하여 새로운 값을 계산하고 저장  
* mappingFunction 람다식이 null을 반환하면 해당 맵에서 제거  
* 주어진 키에 값이 없으면 아무 일도 하지 않음  
```
map.computeIfPresent("Apple", (k, v) -> 5);
```
  
compute
* 지정된 키에 대해 주어진 함수(mappingFunction)를 적용하여 새로운 값을 계산하고 저장  
* 키가 존재하지 않으면 새로운 키-값 쌍을 추가  
* 키가 존재하든 존재하지 않은 모두 처리 가능  
* mappingFunction 람다식에서 null이 반환되는 경우 해당 맵에서 제거된다.  
```
map.compute("Apple", (k, v) -> (v == null) ? 1 : v + 1); // 현재값이 null이면 1, 아닐경우 현재값 + 1
```
  
merge
* 키가 존재하면 주어진 함수로 값을 병합, 없으면 새로 삽입 (신규일땐 람다식이 호출되지 않음)  
* 키가 존재하면 기존 값과 새로운 값을 람다식을 사용하여 현재 값과 주어진 값을 병합한 결과를 저장  
* mappingFunction 람다식이 null을 반환하면 해당 맵에서 제거  
```
map.merge("Apple", 1, Integer::sum);
```
  
putIfAbsent
* 키가 없을 때만 값을 저장  
* 키가 이미 존재하는 경우 새 값으로 덮어쓰지 않고 기존값을 그대로 유지  
* 키가 존재하지 않는 경우 null을 리턴하며 키가 존재하는 경우 기존 값을 리턴  
```
map.putIfAbsent("Apple", 1);
```
  
remove(key, value)
* 키가 특정 값과 매핑된 경우에만 해당 키-값 쌍을 제거  
* remove(key) 이렇게 사용시 일치하는 키가 있는 경우 제거  
```
map.remove("Apple", 0); // 제거되지 않음
map.remove("Apple", 1); // 제거됨
```
  
replace
* 키와 값이 특정 조건을 만족하면 값을 교체  
* replace(key, value) 이렇게 사용시 일치하는 키가 있을 경우 변경  
```
map.replace("Apple", 1, 10);
```
    
### 추가
`synchronized` 는 성능이 좋지 않다고 알려져 있다.  
내부적으로 [**모니터 락(Monitor Lock)**](https://www.geeksforgeeks.org/monitors-in-process-synchronization/)이라는 것을 사용하여 스레드 간 **상호 배제(**https://en.wikipedia.org/wiki/Mutual_exclusion**)**를 보장한다.  
모니터 락이란 특정 객체에 대해 락을 획득하고 해제하는 JVM의 메커니즘이다.  
`synchronized` 블록에 진입할 때 락을 획득해야 하고 블록을 빠져나갈 때 락을 해제한다.  
이 과정에서 JVM은 다음 작업을 수행해야 한다.  
- 락을 얻기 위한 경쟁 처리.  
- 락 상태 업데이트.  
- 락 소유자가 해제될 때 다른 대기 중인 스레드에게 락을 전달.  
  
락 경합이 심할 경우 이러한 작업이 지연 되면서 성능 저하로 이어진다.  
    
성능 외에도 분산 애플리케이션 환경에서 `synchronized`를 사용하면 안되는 이유가 있다.  
`synchronized`는 단일 JVM 의 Java 프로세스 내부의 스레드 동기화만 보장한다.  
그렇기에 서버가 2대 이상인 경우에는 문제가 발생할 수 있다.  

