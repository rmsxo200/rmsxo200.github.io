---
title:  "[Junit] jackson - com.fasterxml.jackson.databind.exc.InvalidDefinitionException 오류"
toc: true
toc_sticky: true
toc_label: "목차"
categories:
  - java
---
### 문제상황  
Junit으로 테스트코드를 작성하여 테스트중 아래와 같은 오류가 발생하였다.  
```
Java 8 date/time type `java.time.LocalDate` not supported by default: add Module "com.fasterxml.jackson.datatype:jackson-datatype-jsr310" to enable handling (through reference chain: com.toy.truffle.travel.dto.TravelDto["startDate"])
com.fasterxml.jackson.databind.exc.InvalidDefinitionException: Java 8 date/time type `java.time.LocalDate` not supported by default: add Module "com.fasterxml.jackson.datatype:jackson-datatype-jsr310" to enable handling (through reference chain: com.toy.truffle.travel.dto.TravelDto["startDate"])
	at com.fasterxml.jackson.databind.exc.InvalidDefinitionException.from(InvalidDefinitionException.java:77)
	at com.fasterxml.jackson.databind.SerializerProvider.reportBadDefinition(SerializerProvider.java:1330)
	at com.fasterxml.jackson.databind.ser.impl.UnsupportedTypeSerializer.serialize(UnsupportedTypeSerializer.java:35)
	at com.fasterxml.jackson.databind.ser.BeanPropertyWriter.serializeAsField(BeanPropertyWriter.java:732)
	at com.fasterxml.jackson.databind.ser.std.BeanSerializerBase.serializeFields(BeanSerializerBase.java:770)
	at com.fasterxml.jackson.databind.ser.BeanSerializer.serialize(BeanSerializer.java:183)
	at com.fasterxml.jackson.databind.ser.DefaultSerializerProvider._serialize(DefaultSerializerProvider.java:502)
	at com.fasterxml.jackson.databind.ser.DefaultSerializerProvider.serializeValue(DefaultSerializerProvider.java:341)
	at com.fasterxml.jackson.databind.ObjectMapper._writeValueAndClose(ObjectMapper.java:4799)
	at com.fasterxml.jackson.databind.ObjectMapper.writeValueAsString(ObjectMapper.java:4040)
	at com.toy.truffle.travel.TravelControllerTest.testSaveTravel(TravelControllerTest.java:78)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
```  
문제 부분의 소스를 보았다.  
```
ResultActions resultActions = mockMvc.perform(post(saveTravelUrl)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(travelDto)));
```  

오류나는 부분의 소스를보니 `ResultActions`을 사용하여 컨트롤러를 호출하는 부분이었다.  
저 부분에서 `json`문자열을 `java`객체로 변환하다 문제가 생긴듯 보였다.    
  
오류를 보아하니 `Java8`에서 추가된 `LocalDate`이 지원되지 않는다고 한다.  
`TravelDto`를 보자.  
```
private LocalDate startDate;
```  
문제가 되는 `startDate`의 데이터타입은 `LocalDate`이다.  
그래서 이 부분을 제대로 매핑하지 못하는 걸로 보인다.  
로그에선 `jackson-datatype-jsr310`모듈을 추가해야 한다고 한다.  
하지만 해당 프로젝트의 `SpringBoot` 버전은 `3.3.3`으로 최근 버전이라 `jsr310`의 의존성을 추가하지 않아도 기본으로 추가되어 있기에 이해할 수 없었다.  
심지어 테스트코드가 아닌 실제 저 컨트롤러를 호출했을때는 정상적으로 동작했다.   
  
알고보니`Junit`을 사용할때 `objectMapper`를 생성하여 사용하고 있엇는데 이럴경우 `objectMapper.registerModule(new JavaTimeModule());`를 따로 추가해 줘야한다.  
```
@BeforeEach
public void setUp() {
    objectMapper = new ObjectMapper();
    objectMapper.registerModule(new JavaTimeModule()); // 추가
    mockMvc = MockMvcBuilders.standaloneSetup(travelController).build();
}
```  
테스트 코드를 위처럼 수정한 뒤 정상적으로 동작한다.  
