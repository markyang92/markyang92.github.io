---
title: "후킹(Hooking)"
excerpt: "후킹"
comments: true
toc: true
toc_sticky: true
category:
- linux-system
---
## Hooking
- **후킹**: OS나 App등에서 함수 호출, 메시지, 이벤트 등을 중간에서 바꾸거나 가로챔. 이때 간섭된 함수 호출, 이벤트, 메시지를 처리하는 코드를 후크라고 한다.
	- <span style="color:green">__shared library__</span>을 사용하여, 기존 바이너리에서 __API__ 를 호출할 때 가로채, **내가 정의한대로 사용케함**

- <span style="color:red">**주의점**</span>  
	- ***LD_PRELOAD***는 <span style="color:red">**SU**</span>가 Set 되어 있으면 무시된다. 보안상 이유
	- init constructor, destructor에서 system, fork, popen으로 <span style="color:red">**프로세스를 실행**</span>시키면 그 프로세스도 constructor, destructor 명령을 실행하기 때문에 <span style="color:red">**정말 주의 무한 실행**</span>된다.

- **속성**
1. ***LD_PRELOAD***에 설정된 shared library는 모든 shared library보다 먼저 로딩
2. 타인 소유 파일에도 동작
3. secure-execution mode로 실행되면 제약이 걸린다.
4. overloading을 따지지 않고 <span style="color:red">**함수 이름 일치**</span>만하면 후킹된다.
5. main은 후킹 안된다.
6. ***LD_PRELOAD***에 등록한 library가 위치한 path가 ***LD_LIBRARY_PATH*** 나 ***/etc/ld.so.conf***에 등록되어 있을 필요는 없다.
7. ***LD_PRELOAD***나 ***/etc/ld.so.conf*** 에 등록된 디렉터리에 위치한 라이브러리는 라이브러리 파일 이름만 적어도 인식한다.
8. *wrapper function*가 실행 시, 원래 함수가 실행되어야 하면 ***dlsym***을 사용해 원래 함수 포인터를 얻은 뒤 <span style="color:magenta">***return origin_function***</span>
9. <span style="color:green">***dlsym***</span>을 이용하기 위해 <span style="color:red">***#include \<dlfcn.h\>***</span> 사용 및 <span style="color:red">***-ldl***</span> 링크 옵션
10. <span style="color:red">**RTLD_NEXT**</span>는 <span style="color:red">**#define _GNU_SOURCE**</span>해야 정의된다.

### 실행 커맨드
---
- 후킹코드를 담아 제작한 **shared library**를 **LD\_PRELOAD**로 실행해야한다.
  
  
1. 특정 바이너리 실행  
```bash
$ LD_PRELOAD=/where/library/path [binary path]
```  
2. 쉘에 등록한 다음 사용 (어떤 바이너리든 실행히 LD_PRELOAD 동작)  
```bash
$ export LD_PRELOAD=/where/library/path
```
3. **etc/ld.so.preload**에 등록해 계정 상관없이 시스템 전역으로 후킹

4. 2개 이상 PreLoad 하는 법
```bash
$ LD_PRELOAD="lib1.so lib2.so" ./app
```

## 구현

- 후킹을 구현하는 **shared library** 본체와 **header file**로 나뉜다.

- **header file**
- **shared library**
	- **constructor**
	- **Define hooked function**
	- **destructor**

### header
---
**clGetPlatformInfo()** 함수를 후킹해 사용하고자 한다!

<img src="img1.png">
- **`clGetPlatformInfo`**라는 API를 후킹해서 여러 파일에 사용하고 싶다면, 위와 같이 헤더파일에 정의
  
**Hook\_API.h**
  
```c
cl_int (*clGetPlatformInfo_real)(cl_platform_id, cl_platform_info, size_t, void *, size_t *);
```
  

### constructor
---
- 후킹을 하는 **shared library** 본체의 constructor

**Hook\_Library.c**
  
```c
#include <stdio.h>
#include ...some system headerfiles
#include "Hook_API.h"
#define _GNU_SOURCE_
#include <dlfcn.h>

void __attribute__((constructor)) init_hooking(){
	clGetPlatformInfo_real = (cl_int (*)(cl_platform_id, cl_platform_info, \
				size_t, void*, size_t *))dlsym(RTLD_NEXT, "clGetPlatformInfo");
}
```


<img src="img2.png">  
- **RTLD_NEXT**사용 위해 **#define _GNU_SOURCE**정의
	- 혹시라도 **#define _GNU_SOURCE**가 안먹히면, 컴파일 때 전처리기 옵션으로<br> <span style="color:brown">**-D_GNU_SOURCE**</span> 주기
- <span style="color:red">**dlsym()**</span> 사용 위해, <span style="color:red"> **#include \<dlfcn.h\> 및 -ldl 링크 옵션**</span>
	- *Dynamic Library - runtime loaded libs*는 [여기](https://pllpokko2.github.io/linux/library/#runtime-loaded-librarydynamic-library) 참고 
<br>
<br>
- **constructor**에서 후킹하고 싶은 함수를 명시한다.
  
---  
**origin함수주소**=**(return자료형 (<span style="color:magenta">\*</span>)(*arg1자료형*..))**<span style="color:red">**dlsym**</span>**(RTLD_NEXT, <span style="color:green">"후킹 하고픈 함수"</span>);**

---


- 앞으로 <span style="color:green">**"후킹 하고픈 함수"**</span>가 **Call**되면 **내가 정의한대로 사용 가능**
- <span style="color:green">**"후킹 하고픈 함수"**</span>의 <span style="color:red">**실제 함수**</span>는 **origin함수주소가 담긴 변수**에 담겨서 사용가능

### Define hooked function
---

**Hook\_Library.c**
  
```c
#include <stdio.h>
#include ...some system headerfiles
#include "Hook_API.h"
#define _GNU_SOURCE_
#include <dlfcn.h>

void __attribute__((constructor)) init_hooking(){
	clGetPlatformInfo_real = (cl_int (*)(cl_platform_id, cl_platform_info, \
				size_t, void*, size_t *))dlsym(RTLD_NEXT, "clGetPlatformInfo");
}

cl_int
clGetPlatformInfo(cl_platform_id platform, cl_platform_info param_name, \
					size_t param_value_size, void *param_value, size_t *param_value_size_ret){

	/* Define What you want to do */

	cl_int err=clGetPlatformInfo_real(platform, param_name, param_value_size, param_value, param_value_size_ret);
									// If you want to call original API

	return err;
}
```



<img src="img3.png">

- <span style="color:green">**응용 프로그램**</span>에서 <span style="color:brown">**Hook한 함수 Call**</span>시, **우리가 정의한 Scope**가 사용된다.

- 바로 "<span style="color:magenta">***return Origin함수주소***</span>" 로 원본 함수 return 하면 그게 그거

### destructor
---

- _destructor_에서는 후킹 라이브러리가 종료할 때 취할 행동 정의

**Hook\_Library.c**
  
```c
#include <stdio.h>
#include ...some system headerfiles
#include "Hook_API.h"
#define _GNU_SOURCE_
#include <dlfcn.h>

void __attribute__((constructor)) init_hooking(){
	clGetPlatformInfo_real = (cl_int (*)(cl_platform_id, cl_platform_info, \
				size_t, void*, size_t *))dlsym(RTLD_NEXT, "clGetPlatformInfo");
}

cl_int
clGetPlatformInfo(cl_platform_id platform, cl_platform_info param_name, \
					size_t param_value_size, void *param_value, size_t *param_value_size_ret){

	/* Define What you want to do */

	cl_int err=clGetPlatformInfo_real(platform, param_name, param_value_size, param_value, param_value_size_ret);
									// If you want to call original API

	return err;
}

void __attribute__((destructor)) done_hooking(){
}
```
  

<img src="img4.png" width="70%" height="70%">


### Compile
---
- 다시 강조하지만 컴파일 때, <span style="color:red">**-ldl 링크 필수**</span> 
- **#define _GNU_SOURCE**가 안먹히면 <span style="color:brown">**-D_GNU_SOURCE**</span> 옵션 추가


```bash
$ gcc -fPIC -c -L. Hook_Library.c Hook_API.h -ldl
$ gcc -shared -L. Hook_Library.o -ldl -o Hook_Library
```

## 사용
  
```bash
$ LD_PRELOAD=./Hook_Library ./binary
```



