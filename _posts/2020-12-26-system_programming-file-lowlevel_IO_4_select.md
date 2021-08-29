---
#```
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "lowlevel I/O <4> I/O Multiplexing, select()"
excerpt: "select()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 입출력 다중화
- **입출력**관련 함수들은 기본적으로 **봉쇄/동기적**으로 작동한다.
<br><br>
- **봉쇄**
	- 데이터를 처리하는 직관적인 방식
	- <span style="color:navy">**두 개 이상의 파일**</span>을 처리할 때 문제
		- 하나의 파일에서 봉쇄 -> 다른 파일의 데이터는 영원히 읽지 못할 수도 있다.
<br><br>
- **봉쇄/동기성** 유지 + **두 개 이상 파일 처리** 방법: `멀티 프로세스`나 `멀티 스레드`를 이용한다.
	- **파일 당** <span style="color:navy">**하나의 프로세스, 스레드**</span>할당해서 **동시에** <span style="color:navy">**두 개**</span> 이상의 파일 처리  
	<img src="img1.png" width="50%">  
	- 이 방식은 단순해 보이지만, **단일** 프로세스/스레드 방식의 프로그램에 비해 다음과 같은 복잡한 프로그래밍 이슈가 있다.  
	1. 프로세스, 스레드간 통신: **IPC**를 이용해야 하는데, 이는 복잡하다.
	2. 동기화: IPC, **mutex**
	3. 프로세스와 스레드 생성: 프로세스 혹은 스레드 생성에는 **자원 소모**
 
<br><br>
<span style="color:blue">**입출력 다중화: I/O Multiplexing**</span>
- **단일 프로세스**가 **여러 파일 제어**할 수 있게 한다.  
<img src="img2.png" width="50%">
- **여러 파일**은 <span style="color:navy">**fd 배열**</span>로 관리된다.  
<img src="img3.png" width="50%">
	- **fd: 2, 4, 7**에서 **데이터 변화**가 있음을 알 수 있다.
- **제한**
	- fd table 크기
		- 1024, ulimit등으로 변경할 수 없다.
	- 배열 성능 문제
		- **배열 모든 필드 전수 검사**
	- 병렬 처리가 아니다.
		- 멀티스레드와 같은 병렬 처리가 아니다.
		- IO 발생 -> 그 fd 처리하는 동안 다른 파일은 대기해야한다.
- 하지만 매우 견고한 모델이며, 프로그래밍이 단순해 널리 사용된다.

## select(): I/O 다중화
- 입출력 관리하고자 하는 **fd**를 <span style="color:navy">___fd\_set___</span>에 넣고 **비트**가 바뀌었는지 확인하는 방식
  
```c
/* According to POSIX.1-2001, POSIX.1-2008 */
#include <sys/select.h>

/* According to earlier standards */
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int select(int nfds, fd_set *readfds, fd_set *writefds,
			 fd_set *exceptfds, struct timeval *timeout);
```
  
***return***|***value***
성공|**데이터가 변경**된 **파일 개수**: <span style="color:red">**주의**</span>:변경된 데이터의 목록이 아님. 따라서 1이상의 수가 반환 돠면 전수 검사해야함

***parameter***|***description***
_nfds_|관리하는 **파일의 갯수**, <span style="color:red">**Max fd + 1**</span>
_\*readfds_|**읽을 데이터**가 있는지 검사하기 위한 파일 목록
_\*writefds_|**쓰여진 데이터**가 있는지 검사하기 위한 파일 목록
_\*exceptfds_|**파일에 예외 사항들**이 있는지 검사하기 위한 파일 목록
_\*timeout_|**select**함수는 **fd\_set**에 등록된 파일들에 데이터 변경이 있는지 <span style="color:red">**timeout**</span>동안 기다린다. ***timeout***동안 변경이 없다면 **0** 반환<br><span style="color:navy">**NULL**</span>: 무한정 기다림. **멤버 값**이 **모두 0**이면 **즉시 반환**


<span style="color:magenta">***struct***</span> <span style="color:navy">**fd\_set**</span>: 관리하는 fd가 있는 **비트 배열 구조체**<br>
  

