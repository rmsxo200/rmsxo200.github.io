---
title:  "[Java] ThreadLocal"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---

### ThreadLocal  
`ThreadLocal`란 각 스레드마다 독립적인 변수를 사용할 수 있게하는 기능이다.  
> 스레드마다 독립적인 변수를 제공하여 여러 스레드가 동시에 접근하더라도 서로 간섭 없이 안전하게 값을 저장하고 조회할 수 있도록 지원하는 클래스  

현재 스레드에 대한 데이터를 개별적으로 저장하고 특수 유형의 객체로 간단히 래핑할 수 있다.
멀티스레드 환경에서 전역변수를 사용하는 경우 스레드 간 경쟁 상태가 발생하여 원하는 값을 예측할 수 없게 된다.  
이때 `ThreadLocal`로 전역변수를 사용하면 스레드 간에 데이터를 공유하지 않고 독립적인 값을 유지할 수 있다.  
> 스레드별 독립성: 각 스레드는 자신만의 `ThreadLocal` 인스턴스를 가지며 다른 스레드와 값을 공유하지 않음.  
> 동시성 문제 해결: 공유 자원에 대한 동기화 없이도 스레드 안전성을 보장.  
  
`ThreadLocal`에 값을 수정할 때는 `set()`, 가져올 때는 `get()`, 삭제할 때는 `remove()`를 사용하면 된다.
 > `ThreadLocal.set(값)`  
 > `ThreadLocal.get()`  
 > `ThreadLocal.remove()`  
  

테스트 예제를 보자.
```
public class threadLocalTest {
    // ThreadLocal 변수 선언
    private static ThreadLocal<Integer> threadLocal = new ThreadLocal<>();

    @Test
    public void testThreadLocalWithMultipleThreads() throws InterruptedException {
        int threadCount = 100; // 스레드 개수
        ExecutorService executorService = Executors.newFixedThreadPool(10); // 스레드 풀
        CountDownLatch latch = new CountDownLatch(threadCount); // 모든 스레드의 작업 완료를 기다리기 위한 래치

        // 모든 스레드가 독립적인 값을 유지했는지 확인하는 플래그
        AtomicBoolean allValuesAreCorrect = new AtomicBoolean(true);

        // 100개의 작업 생성
        for (int i = 0; i < threadCount; i++) {
            final int threadValue = i; // 각 스레드 고유 값
            executorService.execute(() -> {
                try {
                    // ThreadLocal에 값 설정
                    threadLocal.set(threadValue);

                    // ThreadLocal 값 확인
                    if (!threadLocal.get().equals(threadValue)) {
                        allValuesAreCorrect.set(false); // 값이 잘못되었으면 플래그 변경
                    }
                } finally {
                    threadLocal.remove(); // 메모리 누수 방지
                    latch.countDown(); // 작업 완료
                }
            });
        }

        // 모든 스레드의 작업이 끝날 때까지 대기
        latch.await();

        // 스레드 풀 종료
        executorService.shutdown();

        // 모든 값이 올바른지 확인
        assertTrue(allValuesAreCorrect.get(), "ThreadLocal 값이 올바르지 않습니다!");
    }
}
```
위 테스트코드를 실행해 보면 각 스레드가 독립적으로 'ThreadLocal'값을 유지한 것을 확인할 수 있다.  
  
그리고 `Thread Pool`을 사용할 경우 `ThreadLocal.remove()`를 필수적으로 해줘야 한다!  
  
### Thread Pool  
`Thread Pool`을 사용하면 스레드를 미리 만들어 놓는다.  
그리고 필요한 작업에 할당하고 작업이 완료되면 회수한다.  
이렇게 매번 새로 생성하고 소멸하는게 아닌 만들어 놓은 스레드를 재사용 하는 기술이다.  
새 스레드를 생성하는 대신 미리 생성된 스레드를 재사용하여 리소스를 절약하고 성능을 최적화할 수 있다.  
  
그렇다면 `Thread Pool` 사용시 왜 `remove()`를 해줘야 하는 것일까.  
그 이유는 사용 후 회수된 스레드가 다시 할당될 때 이전에 사용한 `ThreadLocal`값이 그대로 존재해 문제가 될 수 있기 때문이다.  
  
### 추가
`Tomcat`이 아닌 `Netty`를 사용한다면 `ThreadLocal`을 사용이 권장되지 않는다고 한다.  
`Spring webflux`를 사용하는 경우 내부 WAS를 `Netty`를 사용하기에 조심하도록 하자.  

