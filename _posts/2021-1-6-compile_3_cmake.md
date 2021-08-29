---
#<span style="color:magenta">
#<span style="color:steelblue">
#<img src="img" width="%" height="%">
title: "컴파일 <3> CMake"
excerpt: "CMake"
comments: true
toc: true
toc_sticky: true
category:
- linux-compile
---
## 1. CMake 기본
- <span style="color:steelblue">**CMakeLists.txt**</span>: CMake는 이  파일을 처리해 네이티브 빌드 시스템을 생성, 빌드 도구 사용해 SW를 실제로 컴파일
	- 사용자가 작성할 파일
- **Makefile**: 생성된 Makefile  
- **CMakeCache.txt**: 텍스트 기반 설정 파일. 해당 빌드 머신을 위해 자동으로 생성된 기본 설정이 저장되어 있다.  
- **CMakeFiles/**: 자동으로 생성된 프레임워크 파일들이 있다. 생성된 파일들은 메인 makefile에서 사용된다.  
<br>


- 모든 명령은 <span style="color:steelblue">**스페이스**</span>로 **argument** **구분**
	- **command** ( `arg1` `arg2` ... )
- **스페이스바**가 포함된 *argument*가 <span style="color:red">**한 개** *arg*</span>라면 <span style="color:green">**\" \"**</span> 사용
	- **command** ( `"`<U>Helloˇworld</U>`"` )
- **command**에 따라 어떤 **argument**가 쓰일지 결정
<br><br>
<img src="ex1.png" width="70%" height="70%">
  
### project: 빌드 이름, 사용할 언어
---
<span style="color:magenta">**project**</span>(basic-syntax C)  
- **빌드 시스템**을 **식별**할 수 있는 **고유한 이름**
	- 여기서 정의된 이름은 이클립스와 같은 프로젝트 이름이 필요한 네이티브 빌드 도구에서 그대로 사용
	- ***basic-syntax C***: 사용할 프로그래밍 언어 지정

### cmake_minimum_required: CMake 버전
---
<span style="color:magenta">**cmake_minimum_required**</span>(<span style="color:steelblue">**VERSION**</span> 버전)

### set: 변수 정의
---
- 변수 **정의**:　<span style="color:magenta">**set**</span>(<span style="color:steelblue">**변수**</span> **값**)  
- 변수 **사용**:　<span style="color:green">**${**</span><span style="color:steelblue">**변수**</span><span style="color:green">**}**</span>

### set_property: 속성 값 설정
---
 <span style="color:magenta">**set\_property**</span> (<span style="color:steelblue">**SROURCE**</span> 소스 <span style="color:steelblue">**PROPERTY**</span> **속성** 값)
- 소스 파일에 **속성 값을 저장**
	- 설정된 속성은 파일 내용에 영향 X
	- 속성 값은 다른 명령에서 접근 가능
- <span style="color:magenta">**set\_property**</span> (<span style="color:steelblue">**SROURCE**</span> add.c <span style="color:steelblue">**PROPERTY**</span> **Author** Peter)
	- **add.c** 소스 파일의 **Author** 속성에 **Peter** 값 할당

### get_property: 속성 값 얻기
---
 <span style="color:magenta">**get\_property**</span> (**할당할 변수** <span style="color:steelblue">**SROURCE**</span> 소스 <span style="color:steelblue">**PROPERTY**</span> 속성)  
- 소스 파일에 **속성 값**을 **가져와** <U>할당할 변수에 저장</U>
- <span style="color:magenta">**get\_property**</span> (__author\_name__ <span style="color:steelblue">**SROURCE**</span> add.c <span style="color:steelblue">**PROPERTY**</span> **Author**)
	- **add.c** 소스 파일의 **Author** 속성의 **값**의 내용을 __author\_name__ 에 할당

### add_executable: 실행 프로그램 생성
---
<img src="ex2.png" width="40%" height="40%">  
<span style="color:magenta">**add\_executable**</span> (<span style="color:green">**실행파일 이름**</span> **src1** **src2** **src3** **...**)  \".c\", \".cpp\"는 붙여도 되고 안해도 됨
<br>
- 소스 파일들을 **빌드**해  <U>실행파일 생성</U>
- <span style="color:magenta">**add\_executable**</span> (**calculator** add sub mult calc)
	- add.c sub.c mult.c calc.c **소스 파일**을 이용해
	- <span style="color:green">**실행파일 \"calculator\"**</span> 생성

### example 1
---
- 현재 ***main.c print.h*** 소스 코드가 있고 간단하게 빌드하는 **CMakeLists.txt**만들어 본다.  
<img src="ex3.png" width="30%" height="30%">  

```cmake
cmake_minimum_required(VERSION 2.6)

set(author "Dong-Hyeon Yang")	# author 변수에 "Dong-Hyeon Yang" 문자열 넣어봄

message(${author})		# author 변수를 message 함수를 통해 변수 내용을 출력해봄
add_executable(main main)	# 실행 파일 명: main
				# 소스 파일 명: main.c (.c 생략 가능)
```

```bash
$ cmake PATH
```
- **PATH**에 CMakeLists.txt 파일의 위치 경로 지정
- 지정한 위치의 CMakeLists.txt를 읽어 **현재 내 위치에 빌드**

<img src="ex4.png">

### add_library: 라이브러리 생성
---
<img src="ex5.png" width="40%" height="40%">  
<span style="color:magenta">**add\_library**</span> (<span style="color:green">**라이브러리 이름**</span> <span style="color:steelblue">**[STATIC \| SHARED \| MODULE\]**</span> **src1** **src2** **src3** **...**)  \".c\", \".cpp\"는 붙여도 되고 안해도 됨
<br>
- 소스 파일들을 **빌드**해  <U>라이브러리 생성</U>
- <span style="color:magenta">**add\_library**</span> (**math** <span style="color:steelblue">**STATIC**</span> add sub mul)
	- add.c sub.c mult.c **소스 파일**을 이용해
	- <span style="color:steelblue">**STATIC**</span> 라이브러리(정적 라이브러리)
	- <span style="color:green">**라이브러리 \"math\"**</span> 생성 => **결과물:** <span style="color:red">lib**clsched**.a</span>
<br>
  
```cmake
add_libary(clsched STATIC clsched.c clsched_interceptor.c)
```
- <span style="color:red">lib**clsched**.a</span> 생성
  
```cmake
add_libary(clsched SHARED clsched.c clsched_interceptor.c)
```
- <span style="color:steelblue">lib**clsched**.so</span> 생성

## 2. sub디렉터리, -L, -I, -l 플래그
  
<img src="ex6.png" width="80%" height="80%">

### add_subdirectory: 하위 디렉터리 CMakeLists.txt
---
<span style="color:magenta">**add\_subdirectory**</span> (**<U>sub dir1</U>**　**<U>sub dir2</U>**)
<br>
- 하위 디렉터리의 ***CMakeLists.txt***를 **선행 빌드**
  
### include_directories: `-I` 참조 include 디렉터리 지정
---
- **참조할 include 디렉터리 지정**  <span style="color:blue">**`-I`**</span> **옵션**
```bash
$ gcc -I./include foo.c -o bar
# gcc -I 옵션
```
  
<span style="color:magenta">**include\_directories**</span> (**<U>include dir1</U>**　**<U>include dir2</U>**)
<br>
  
### link_directories: -L 참조 라이브러리 디렉터리 지정 
---
- **링크할 라이브러리가 있는 디렉터리 지정**  <span style="color:blue">**`-L`**</span> **옵션**  
```bash
$ gcc -L./lib main.c -lclsched
# gcc -L 옵션
```
  
<span style="color:magenta">**link\_directories**</span> (**<U>link dir 1</U>**　**<U>link dir 2</U>**)
  
### target_link_libraries: -l 라이브러리 링크 걸기
---
- **링크할 라이브러리 지정**  <span style="color:blue">**`-l`**</span> **옵션**  
```bash
$ gcc main.c -lclsched
# gcc -l 옵션
```
  
<span style="color:magenta">**target_link_libraries**</span> (**<U>library 1</U>**　**<U>library 2</U>**)

## set
- <span style="color:green">**CMAKE\_BUILD\_TYPE**</span>: **빌드 형상**  
<img src="ex7.png" width="40%" height="40%">
	- Debug: 디버깅 목적 빌드 `-g` 플래그
	- Release: 배포 목적 빌드
	- RelWithDebInfo: 배포 목적 빌드 + 디버깅 정보 포함
	- MinSizeRel: 최소 크기로 최적화한 배포 목적 빌드

## set_property
- <span style="color:green">**COMPILE\_DEFINITIONS**</span>: **심볼 정의**  
<img src="ex8.png" width="80%" height="80%">  
- <span style="color:magenta">**set\_property**</span>(***DIRECTORY***  PROPERTY <U>COMPILE_DEFINITIONS TEST=1</U>)
	- 현재 **DIRECTORY**의 **모든 C파일**을 컴파일할 때 **TEST 심볼 정의**
- <span style="color:magenta">**set\_property**</span>(***SOURCE***  add.c PROPERTY <U>COMPILE_DEFINITIONS QUICKADD=1</U>)
	- 특정 **SOURCE**인 add.c에 **QUICKADD 심볼 정의**

## if/elseif/endif
<img src="ex9.png" width="30%" height="30%">
- **<span style="color:magenta">if()　elseif()　 else()　 endif()</span>**
<br>
- **EQUAL**, **NOT**, **AND**, **OR**
  
<br>
<img src="ex10.png" width="30%" height="30%">
- **<span style="color:magenta">EXISTS</span>**: 파일 존재 유무
	- <span style="color:red">**주의**</span>: 파일 확인하는 시점은 빌드가 실행되는 시점이 아닌 **생성되는 시점**
  
<br>
<img src="ex11.png" width="60%" height="60%">
- **<span style="color:magenta">MATCHES</span>**: 정규식 사용

## 크로스플랫폼 지원
- _Cross Platform_ 을 지원하려면 CMake의 빌드 기술은 플랫폼 중립적이어야한다.
	- 빌드 프로세스에서 사용되는 도구와 파일 위치를 상세히 기술하지 않는다.
	- CMake에 의해 찾게한다.
<br><br>
- **`ls`**프로그램, **stdio.h** 헤더파일, **math**라이브러리를 찾는 예제이다.
  
```cmake
find_program(LS_PATH ls)	# ls 프로그램을 찾아 LS_PATH 변수에 담는다.
message("ls path: ${LS_PATH}")

find_file(STDIO_H_PATH stdio.h)	# stdio.h 파일을 찾아서 STDIO_H_PATH 변수에 담는다.
message("stdio path: ${STDIO_H_PATH}")

find_library(LIB_MATH_PATH m /usr/local/lib /usr/lib64)	# lib'm'.so 를 찾기 위해 /usr/local/lib /usr/lib64를 찾아봐라
message("math lib path: ${LIB_MATH_PATH}")
```
```bash
ls path: /bin/ls
stdio path: /usr/include/stdio.h
math lib path: /usr/lib/libm.so
```

### 매크로 입력

- `-G`: 기본 생성 빌드 시스템 변경
   
```bash
$ cmake -G "Visual Studio 10" ../src
```

## ccmake
- **ccmake** 명령으로 네이티브 빌드 시스템을 더욱 자세히 설정할 수 있다.
- 패키지 이름: cmake-curses-gui

- 캐시 변수들은 오브젝트 디렉터리에 있는 <span style="color:blue">**CMakeCache.txt**</span>에 저장되어 있다.
- 다음은 일반적으로 사용되는 캐시 변수
  
***Cache Variable***|***Description***
:===|:===
__CMAKE\_AR__|라이브러리를 묶는 아카이버 도구
__CMAKE\_C\_COMPILER__|C 컴파일러
__CMAKE\_LINKER__|오브젝트 링커
__CMAKE\_MAKE\_PROGRAM__|**/usr/bin/gmake**와 같은 네이티브 빌드 도구의 절대 경로
__CMAKE\_BUILD\_TYPE__|생성하고 싶은 빌드 트리의 타입 지정, 다음과 같이 설정할 수 있다.<br>**Debug**, **Release**, **RelWithDebInfo**, **MinSizeRel**
__CMAKE\_C\_FLAGS\_\*__|C 컴파일 옵션, **위** CMAKE\_BUILD\_TYPE에 따라 CMake는 캐시 변수에 저장된 C 컴파일 옵션을 사용하게 된다.
__CMAKE\_EXE\_LINKER\_FLAGS\_\*__|링커 옵션, **위** CMAKE\_BUILD\_TYPE에 따라 타입에 따른 링커 옵션을 나타낸다.

- 새로운 캐시 변수를 정의할 수 있다.
- CMakeLists.txt 빌드 기술 내부에서 캐시 변수는 일반 변수와 같이 사용될 수 있다.
  
<img src="ex12.png">

각 옵션에 대한 설명과 들어가는 옵션 값들을 잘 설명해주고 교체할 수 있다.
