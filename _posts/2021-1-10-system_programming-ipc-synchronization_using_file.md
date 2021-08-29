---
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "파일을 이용한 동기화"
excerpt: "synchronization"
comments: true
toc: true
toc_sticky: true
category:
- ipc
---
## 파일을 이용한 동기화
- **Race condition(경쟁 상태)**
	- 둘 이상의 <span style="color:steelblue">**프로세스**</span>/<span style="color:magenta">**Thread**</span>가 동시에 어떤 작업을 수행 시, 타이밍 등에 의해 <span style="color:red">**의도치 않은**</span> **결과**가 나올 수 있는 상태

- **Critical Section(임계 영역)**
	- 둘 이상의 <span style="color:steelblue">**프로세스**</span>/<span style="color:magenta">**Thread**</span>가 동시에 접근하면 안되는 <span style="color:steelblue">**공유데이터**</span>를 접근하는 <span style="color:blue">**코드 영역**</span>
	- 즉, **Race Condition**을 발생 시킬 수 있는 <span style="color:blue">**코드 영역**</span>
   
<img src="img1.png" width="70%">

- **Race condition**을 해결하기 위한 간단한 방법: <span style="color:navy">**Lock mechanism**</span>
	- <span style="color:magenta">**Thread**</span>가 **critical section code**에 진입할 수 있는 **열쇠**를(<span style="color:red">**Lock**</span>을 획득) **얻어야** **Critical section code**에 진입할 수 있다.
<br>
- **파일**을 이용한 **동기화**에서는 <span style="color:blue">**파일 디스크립터**(***fd***)</span>가 <span style="color:red">**lock**</span>의 역할을 한다.

```c
#include <sys/file.h>

int flock(int fd, int operation);
```

***return***|***value***
:===|:===
성공|0
실패|-1

***parameter***|***Description***
:===|:===
_fd_|파일 디스크립터
_operation_|__LOCK\_SH__: <span style="color:steelblue">**shared lock**</span> 걸기 - 여러개의 프로세스(스레드)가 lock을 획득 할 수 있다.<br>__LOCK\_EX__: <span style="color:firebrick">**exclusive lock**</span> 걸기 -어느 프로세스(스레드)가 lock을 소유한다면 다른 프로세스(스레드)는 lock을 획득 할 수 없다.<br>__LOCK\_UN__: lock <span style="color:steelblue">**풀기**</span> _shared, exclusive_ **둘다 풂**<br>__LOCK\_NB__: non-block(획득에 실패한 P/T는 대기아닌 바로 <span style="color:firebrick">***Error Return***</span>-errno 필요). 다른 값과 ORing(**\|**)하여 사용
  
<br>
  
　|<span style="color:steelblue">***shared***</span> lock 획득 시도|<span style="color:firebrick">***exclusive***</span> lock 획득 시도
:===|:===|:===
lock 없음|즉시 성공|즉시 성공
어떤 프로세스/스레드에 의해<br><span style="color:steelblue">***shared locked***</span> 상태|즉시 성공|**모든** <span style="color:steelblue">**shared lock**</span>이 풀릴 때까지 대기
어떤 프로세스/스레드에 의해<br><span style="color:firebrick">***exclusive lock***</span> 상태|<span style="color:firebrick">***exclusive lock***</span>이 풀릴 때까지 대기| <span style="color:firebrick">***exclusive lock***</span>이 풀릴 때까지 대기

### ex 1. simple\_flock.c
---
  
```c
#include <stdio.h>
#include <sys/file.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define NON_BLOCK 1

static void print_usage(char *progname){
	printf("usage: %s {ex | sh}\nex: exclussive lock\nsh: shared lock\n", progname);
	exit(-1);
}

int main(int argc, char *argv[]){
	int fd;
	int ops;

	if(argc<2){
		print_usage(argv[0]);
	}

	if(!strcmp(argv[1], "sh")){
		ops = LOCK_SH;
	} else if (!strcmp(argv[1], "ex")){
		ops = LOCK_EX;
	} else{
		print_usage(argv[0]);
	}

	fd=open("lockfile", O_RDWR | O_CREAT, 0600);
	if(fd<0){
		perror("open fail\n");
		return -1;
	}

	printf("trying to grab the lock\n");
#if NON_BLOCK == 0
	if(flock(fd, ops){ // Lock
		printf("flock(ops %d)\n", ops);
		goto out;
	}
#elif NON_BLOCK == 1
	if(flock(fd, ops | LOCK_NB)!=0){ // Lock
		printf("flock(ops %d), errno=%d(%s)\n", ops, errno, strerror(errno));
		goto out;
	}
#endif
	printf("got the lock!\n");
	int ch=getc(stdin); // Wait for inserting key from User.

	if(flock(fd, LOCK_UN)!=0){ // Unlock
		printf("flock(unlock)\n");
		goto out;
	}
	printf("unlock!\n");

	return 0;
out:
	close(fd);
	return -1;


}

```
  
<img src="img2.png">
- 두 **Process** 모두 <span style="color:steelblue">**Shared Lock**</span> **grab 시도**
	- 두 **Process** 모두 **lock 소유 가능**
	- 두 **Process** 모두 **critical section**에 들어와있다.
  
<img src="img3.png">
- **P1** <span style="color:steelblue">**Shared Lock**</span> **먼저 lock획득**, **P2** <span style="color:firebrick">**Exclusive Lock**</span> **grab 시도**
	- **P1**이 먼저 lock 획득 시, **P2**는 나중에 lock 획득 시도 -> 대기 상태된다.
	- **P1**이 Unlock 해야 **P2**는 Lock 획득
  
<img src="img4.png">
- **P2** <span style="color:firebrick">**Exclusive Lock**</span> **먼저 lock획득**, **P1**은 <span style="color:steelblue">**Shared Lock**</span>
	- **P2**가 먼저 Ex-lock 획득, **P1**은 나중에 lock 획득 시도 하지만 대기 상태된다.
	- **P2**이 Unlock 해야 **P1**는 Lock 획득
  
<img src="img5.png">
- **P1, P2** <span style="color:firebrick">**Exclusive Lock**</span>
	- 뒤늦게 lock 획득 시도 시, 대기 상태

<img src="img6.png">
- <span style="color:red">__LOCK\_NB__ set!</span> 시!, 뒤늦게 lock 획득 시도하는 프로세스는 <span style="color:red">**error!**</span>
