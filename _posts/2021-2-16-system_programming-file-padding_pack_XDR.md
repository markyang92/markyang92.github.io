---
#```
title: "패딩(padding)/팩(pack)/XDR"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 패딩
- CPU Alignment 때문에, **특정 바이트** <span style="color:red">**짝수 배수**</span> **정렬**
	- 구조체처럼 다양한 멤버 변수가 모이는 경우, 각 멤버 변수의 **시작하는 주소**를 **특정한** <span style="color:red">**짝수 바이트**</span>의 <span style="color:red">**배수**</span>로 주소 경계 맞춤

```c
struct my_st a{
	char str[9];
	char cnt[4];
}
// 9 + 4 = 13Byte

struct my_st b{
	char str[9];
	int cnt;
}
// 9 + (3) + 4 = 16Byte
```
- 이러한 주소 경계를 특정 단위의 배수로 정렬하는 규칙이 **XDR**(External Data Representation)
	- Sun Microsystems에서 요구하여 RFC로 제출되었다. (RFC 1014 -> RFC 1832)
	- 서로 다른 아키텍처 간에 데이터 교환 시, 버스 오류나 성능 저하 최소화

## XDR, RFC 1832

- 서로 다른 아키텍처 간에 데이터 교환 시, 버스 오류나 성능 저하 최소화위한 데이터 표현 방식
	- intel은 2000년 부터 정렬되지 않은 메모리(misaligned memory) 접근에 대한 패널티 개선<br>현재는 intel 프로세서에 패널티가 없다. 그러나 다른 벤더의 프로세서들은 작동에 실패하거나 패널티가 클 경우가 있으니 주의

1. **통신 데이터**는 `빅 엔디안`이 디폴트
2. 메모리 정렬(memory alignment) XDR은 **기본 유닛의 크기**를 <span style="color:red">**4Byte**</span>로 경계한다.

정렬되지 않은 메모리 출력해본다.
```c
int main(){
	char *p_buf;
	if ((p_buf = (char *)malloc(sizeof(char) * 65536)) == NULL)
		return EXIT_FAILURE;
	memcpy(p_buf, "1234567890abc", 13); // 문자열 13바이트
	p_buf += 13; // p_buf를 p_buf에서 13바이트 이동
	*((long *)p_buf)=123456; // long형 데이터 하나 저장
	
	return EXIT_SUCCESS;
}
```


