---
title: "인라인 어셈블리(inline assembly)"
excerpt: "인라인 어셈블리"
comments: true
toc: true
toc_sticky: true
category:
- c
---
## Inline Assembly
## Feature
- 인라인 어셈블리: C 소스 내에서 어셈블리 코드를 사용하는 방법
	- 해당 CPU에서만 동작하게 되므로, 주의!
  
```c
#include <stdio.h>

int main(void){
	__asm__ __volatile__("nop");
	
	return 0;
}
```

- **`__asm__`**: 인라인 어셈블리 시작의 필수
- **`__volatile__`**: 변수 앞 volatile은 해당 변수를 컴파일러가 최적화를 수해앟지 않도록 함(쓰고 싶을 때만 씀)
- **`("nop")`**: "nop"이라는 CPU instruction. no operation이라는 뜻으로 아무것도 하지마라는 명령어
  
```c
#include <stdio.h>

int main(void){
	__asm__ __volatile__(
		"mov1 $3, %eax\n"
	);
	
	return 0;
}
```
  
- **`$3`**: 어셈블리 언어에서, 상수를 표현시 **`$`**
- 위 커맨드의 뜻은, **eax 레지스터에 3을 넣어라!**

