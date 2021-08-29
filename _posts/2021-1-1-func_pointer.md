---
# <span style="color:steelblue">
title: "함수 포인터"
excerpt: "함수 포인터"
comments: true
toc: true
toc_sticky: true
category:
- c
---
## 함수 포인터
- 자주 사용되지만 헷갈리는 *function pointer*
아래의 선언을 살펴본다.
	- __int \*n__: 포인터 변수 n은 int형(4Byte?) 메모리 주소를 가리킨다.
	- __char \*str__: 포인터 변수 str은 char 타입을 담고 있는 메모리 주소를 가리킨다. 
	- __void (\*f)(int)__: **포인터 변수 f**는 .. 함수도 **주소**와 심볼을 가지고 call 하는 것이다!

```c
#include <stdio.h>

int plus(int n){
	return n+1;
}

int main(){
	int (*f)(int);
	int result;

	f = plus; /* match func pointer to function */
	result = f(5);
	printf("%d\n",result);
	exit(0);
}
```

- **반환 type**, **인풋 type 등을 맞추면 됨**

## char\*와 char[　]의 차이
1. __char \*buf__: *buf* 라는 포인터 **변수만 선언**
2. __char buf[64]__: <span style="color:steelblue">**메모리 확보**</span> + 포인터 **변수 선언**
  
