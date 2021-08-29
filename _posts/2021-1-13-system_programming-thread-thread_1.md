---
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "thread <1> pthread, mutex, API"
excerpt: "pthread_{create,join,detach,exit,cleanup_push,cleanup_pop,self}, mutex"
comments: true
toc: true
toc_sticky: true
category:
- thread
---
## Thread
- 새로운 프로세스를 만들지 않고 **특정 문맥**만 병렬로 실행할 수 있도록한다.

<span style="color:magenta">***Thread***</span>|<span style="color:steelblue">***Process***</span>
:===|:===
프로세스의 **서브셋**|독립적 프로세스
**코드, 데이터, 힙**을 다른 스레드와 <span style="color:blue">**공유**</span><br>**각자의** <span style="color:red">**스택, pc**</span>가짐|자신만의 **주소 영역**
-|**IPC**로만 다른 프로세스와 통신 가능하다.
context switching 속도 **빠름**|context switching 속도 스레드보다 **느림**

- **fork**가 **copy-on-write**방식으로 자식에게 복사하는데 비해 **스레드**는 많은 부분 공유하기 때문에 빠르다.

***platform***|**fork**<br>real|<br>user|<br>sys|<sub>**pthread**</sub><br>real|<br>user|<br>sys
AMD 2.4 GHz Opteron (8cpus/node)|41.07|60.08|9.91|0.66|0.19|0.43
IBM 1.9 GHz POWER5 p5-575 (8cpus/node)|64.24|30.78|27.68|1.75|0.69|1.10
IBM 1.5 GHz POWER4 (8cpus/node)|104.05|48.64|47.21|2.01|1.00|1.52
INTEL 2.4 GHz Xeon (2 cpus/node)|54.95|1.54|20.78|1.64|0.67|0.90
INTEL 1.4 GHz Itanium2 (4 cpus/node)|54.54|1.07|22.22|2.03|1.26|0.67



- **kernel thread**
	- 하나의 프로세스=적어도 1개의 커널 스레드 가짐
<br>
- **User thread**
	- 유저레벨에서 사용하는 스레드

- **각 스레드**가 <span style="color:magenta">**각각**</span> 가지는 자원
	- errno
	- 스레드 우선순위
	- <span style="color:red">**스택**</span>
	- tid
	- 레지스터 및 sp

- **스레드끼리** <span style="color:blue">**공유**</span>하는 자원
	- 작업 디렉토리
	- fd
	- <span style="color:steelblue">**전역변수**</span>와 데이터들
	- UID, GID
	- <span style="color:magenta">**signal**</span>

<img src="thread.png" width="50%">

### Multi thread 프로그램 단점
---
1. 하나의 <span style="color:magenta">***Thread***</span>에서 발생된 문제가 **전체** <span style="color:steelblue">***Process***</span>에 영향
2. 디버깅이 어렵다.

### Pthread
---
- <span style="color:firebrick">**리눅스**</span>에서는 **pthread**(**P**osix thread) 지원
	- 컴파일 때 <span style="color:green">**\"-lpthread\"**</span> 링크 옵션
- <span style="color:magenta">**signal**</span>은 <span style="color:steelblue">***프로세스***</span>단위로 작동한다.
- <span style="color:magenta">***Thread***</span>은 **각 스레드**마다 **다른 시그널 정책**이 **필요**하므로, **<U>스레드 전용의 시그널 제어 함수</U>**가 필요

<img src="img1.png" width="50%">

## Pthread
### pthread\_create: 스레드 생성
---
```c
#include <pthread.h>

int pthread_create(pthreads_t *thread, pthread_attr_t *attr, void *(*start_routin)(void *), void *arg);
```
  
***parameter***|***Description***
_\*thread_|스레드가 성공적으로 생성됬을 때, 넘겨주는 <span style="color:magenta">**쓰레드 식별 번호**</span>
_\*attr_|스레드 특성 설정하기 위해 사용. <span style="color:steelblue">NULL</span>일 경우 기본 특성
_\*start_routine_|스레드가 수행할 함수, 함수포인터를 넘긴다.
_\*arg_|스레드 함수 start\_routine을 실행시킬 때, 넘겨줄 아규먼트

**return**|**value**
성공|0
실패|**errno**


- <span style="color:magenta">**pthread\_create**</span>**( &tid, attr, function, (**<span style="color:blue">**void**</span> **\*)**<span style="color:magenta">***arg***</span>**)**;
	- thread의 argument는 <span style="color:blue">__void \*__</span>
	- 64bit system에서는 thread에 보내는 정수형 argument는 `long` ***arg***으로 할 것
  

### pthread\_join: 스레드 정리
---
```c
#include <pthread.h>

int pthread_join(pthread_t th, void **thread_return);
```
  
***parameter***|***Description***
**th**|pthread\_create에 의해 생성된 식별번호 **th**를 기다린다.
**thread\_return**|식별번호 **th**의 **return 값**

- *pthread\_create*  때 **detach**하게 생성 시
	- 생성된 스레드는 나중에 join되지 않을 것이라고 생각
	- 종료하자마자 모든 자원을 해제하며 *pthread\_join*으로 기다릴 수 없다.
	- 부모 스레드와 **떨어져서** 완전히 독립적으로 작용

- **join**시, <span style="color:magenta">**BLOCKING!**</span>


### pthread_create(), pthread_join()에서 argument
---
<img src="img3.png" width="100%">
- **왼)** <span style="color:magenta">***long***</span> **형**　**오)** <span style="color:magenta">___long \*___</span> **형**　arg 주고 받기
- **각 함수** <span style="color:blue">**선언**</span> 원형대로 <span style="color:magenta">**Type casing**</span>해서 보내면됨

### 예제 1. 간단한 pthread
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

// 쓰레드 함수
void *t_function(void *data){

	long id=*((long *)data);

	printf("thread: %ld\n",id);


	return (void**)id;
}

int main(void){
	pthread_t p_thread[2];
	int t_id;
	long a=1, b=3; // x64 system에서는 long 쓰자!!

	// 스레드 생성 아규먼트로 1을 넘긴다.
	t_id=pthread_create(&p_thread[0], NULL, t_function, &a);
	if(t_id<0){
		perror("thread create error: ");
		exit(0);
	}

	// 스레드 생성 아규먼트로 2를 넘긴다.
	t_id=pthread_create(&p_thread[1], NULL, t_function, &b);
	if(t_id<0){
		perror("thread create error: ");
		exit(0);
	}

	long status1;
	long status2;

	pthread_join(p_thread[0], (void**)&status1);
	pthread_join(p_thread[1], (void**)&status2);

	printf("status1: %ld\n", status1);
	printf("status2: %ld\n", status2);

	return 0;
}
```
  
```bash
$ gcc simple_thread.c -lpthread -o simple_thread
$ ./simple_thread
thread1: 1
thread2: 3
status1: 1
status2: 3
```

### 예제 2. double pointer arg 사용하는 스레드
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>


typedef struct{
	int **arr;
}PARAM;

void *t_func(void *args){
	PARAM *param=(PARAM *)args;
	(param->arr)[0][0]=5;

	return param;
}

int main(void){
	pthread_t tid;
	pthread_attr_t attr;
	PARAM *param;

	param=(PARAM*)malloc(sizeof(PARAM));
	param->arr=(int**)malloc(sizeof(int)*1);
	param->arr[0]=(int*)malloc(sizeof(int)*1);

	pthread_attr_init(&attr);
	pthread_create(&tid, &attr, t_func, (void *)param);

	PARAM* return_param;
	pthread_join(tid, (void **)&return_param);

	printf("%d\n", (return_param->arr)[0][0]);

	return 0;

}
```
- <span style="color:navy">**2 차원 배열**</span>은 <span style="color:magenta">***structure***</span> 안에 넣어서 전달해야한다.

### pthread_detach(): 자식, 부모 스레드 분리하기
---
- **pthread\_detach**를 이용해서, 자식 스레드와 부모 스레드와 완전히 **분리**한다.
	- **자식** 스레드가 **종료**시, 모든 자원이 즉시 반납된다.
	- **detach** 시, **자식 종료 상태를 알 수 없다.**

```c
#include <pthread.h>

int pthread_detach(pthread_t thread);
```
- **detach**할 **thread넣기**

 
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

// 쓰레드 함수
// 1초를 기다린 후, 아규먼트^2를 리턴한다.
void *t_function(void *data){
	char a[100000];
	int num=*((int *)data);
	printf("Thread Start\n");
	sleep(5);
	printf("Thread end\n");
}

int main(void){
	pthread_t p_thread;
	int thr_id;
	int status;
	int a=100;

	printf("Before Thread\n");
	thr_id=pthread_create(&p_thread,NULL,t_function,(void *)&a);
	if(thr_id<0){
		perror("thread create error : ");
		exit(0);
	}

	// 식별번호 p_thread를 가지는 스레드를 detach
	// 시켜준다.
	pthread_detach(p_thread);
	pause();
	return 0;
}
```

## Synchronization
### mutex 잠금
---

- **Race condition(경쟁 상태)**
	- 둘 이상의 <span style="color:steelblue">**프로세스**</span>/<span style="color:magenta">**Thread**</span>가 동시에 어떤 작업을 수행 시, 타이밍 등에 의해 <span style="color:red">**의도치 않은**</span> **결과**가 나올 수 있는 상태

- **Critical Section(임계 영역)**
	- 둘 이상의 <span style="color:steelblue">**프로세스**</span>/<span style="color:magenta">**Thread**</span>가 동시에 접근하면 안되는 <span style="color:steelblue">**공유데이터**</span>를 접근하는 <span style="color:blue">**코드 영역**</span>
	- 즉, **Race Condition**을 발생 시킬 수 있는 <span style="color:blue">**코드 영역**</span>
   
<img src="img4.png" width="70%">

- **Race condition**을 해결하기 위한 간단한 방법: <span style="color:navy">**Lock mechanism**</span>
	- <span style="color:magenta">**Thread**</span>가 **critical section code**에 진입할 수 있는 **열쇠**를(<span style="color:red">**Lock**</span>을 획득) **얻어야** **Critical section code**에 진입할 수 있다.
<br>
- **Mutex**을 이용한 **동기화**에서는 <span style="color:blue">**Mutex**</span>가 <span style="color:red">**lock**</span>의 역할을 한다.
  
<br>
- **Mutex**사용을 위해서는 다음의 4가지 함수가 필요하다.
	- **Mutex 잠금객체**를 만드는 함수
	- **Mutex 잠금**을 얻는 함수
	- **Mutex 잠금**을 되돌려 주는 함수
	- **Mutex 잠금객체**를 제거하는 함수
<br>
- **mutex**는 아래 요소들을 보장함으로써 **임계영역**(Critical Section)을 잠금다.
	- **Atomicity**: mutex 잠금은 최소단위 연적 - **Atomic operation** - 을 보장한다.
		- **Atomic operation**은 일련의 연산 즉 mutex 잠금 연산이 끝날 때까지 다른 프로세스가 그 연산의 변화를 알 수 없는 상태가 되는 연산
	- 전체 연산 중 하나라도 실패할 경우 모든 연산이 실패하며, 시스템은 전체 연산이 시작하기 전의 상태로 복구된다. 
	- <span style="color:steelblue">**Singularity**</span>: 한 스레드가 뮤택스 <span style="color:red">**lock**</span>을 획득했다면, 이 스레드가 뮤택스 잠금을 내놓기 전까지는 다른 스레드가 뮤텍스 <span style="color:red">**lock**</span>을 얻을 수 없도록한다.
	- **None Busy Wait**: 성능 관련, <span style="color:magenta">**Busy wait**</span> <span style="color:red">**(X)**</span>


### pthread_mutex_init
---
- **pthread\_mutex\_init()**으로 **잠금 객체**를 만든다.
  
```c
#include <pthread.h>

pthread_mutex_t mutex; // mutex object

int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr *attr);
```

***parameter***|***Description***
_\*mutex_|mutex 잠금객체
_\*attr_| <span style="color:navy">**mutex type**</span> 결정, <span style="color:magenta">() 매크로</span><br>**fast** (<span style="color:magenta">**PTHREAD\_MUTEX\_INITIALIZER**</span>): 하나의 스레드가 하나의 잠금만을 얻을 수 있는 일반적 형태<br> **recursive** (<span style="color:magenta">**PTHREAD\_RECURSIVE\_MUTEX\_INITIALIZER**</span>): 잠금을 얻은 스레드가 다시 잠금을 얻을 수 있다. 이 경우 잠금에 대한 카운트가 증가하게 된다.<br> **error checking** (<span style="color:magenta">**PTHREAD\_RECURSIVE\_MUTEX\_INITIALIZER**</span>): <br> <span style="color:steelblue">**NULL**</span>: 기본값 **fast**

**선언 방법 1.**
- pthread\_mutex\_t mutex = PTHREAD\_MUTEX\_INITIALIZER;
  
**선언 방법 2.**
- pthread\_mutex\_t mutex;<br>pthread_mutex_init(&mutex, NULL);

### pthread_mutex_destroy
---
  
```c
#include <pthread.h>

int pthread_mutex_destroy(pthread_mutex_t *mutex);
```
- 기능: **mutex** 객체 파괴.<br><span style="color:red">**주의!!**</span>: ***locked mutex***를 파괴 시도 시, **EBUSY** 에러 코드

***return***|***Value***
성공|0
실패|errno

- 뮤텍스를 사용할 일이 없다면 제거(free)하자.

### pthread_mutex_{,try_}lock
---

```c
#include <pthread.h>

int pthread_mutex_lock(pthread_mutex_t *mutex);
```
- **pthread\_mutex\_lock**으로 <span style="color:red">**lock**</span>을 **요청**한다.
- 만약 <span style="color:red">**lock**</span>을 선점한 스레드가 있다면, 요청한 스레드는 <span style="color:navy">**대기 상태**</span>가 된다.

  
```c
#include <pthread.h>

int pthread_mutex_try_lock(pthread_mutex_t *mutex);
```
- 만약 잠금을 얻을 수 있는지만 **체크**하고 **대기(블럭)상태로 되지 않고** 다음 코드로 넘어가야한다면..

### pthread_mutex_unlock
---
  
```c
#include <pthread.h>

int pthread_mutex_unlock(pthread_mutex_t *mutex);
```
- **mutex** <span style="color:red">**lock**</span>을 되돌려준다.

### 뮤텍스 잠금 예제
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

int ncount; // 스레드가 공유되는 자원
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // 스레드 초기화

/* mutex object를 전역으로 선언해 어디서든 사용될 수 있게 하자. */

// 스레드 함수 1
void* do_loop(void *data){
	int i;
	pthread_mutex_lock(&mutex); // 뮤텍스 락
	for(i=0;i<10;i++){
		printf("loop1 : %d ",ncount);
		ncount ++;
		sleep(1);
	}
	pthread_mutex_unlock(&mutex); // 잠금을 해제
}

// 스레드 함수 2
void *do_loop2(void *data){
	int i;

	/* 잠금을 얻으려고 하지만 do_loop에서 이미 잠금을 얻었으므로
	   잠금이 해제될때까지 기다린다. */
	pthread_mutex_lock(&mutex); // 잠금을 생성한다.
	for(i=0; i<10; i++){
		printf("loop2 : %d ", ncount);
		ncount++;
		sleep(1);
	}
	pthread_mutex_unlock(&mutex); // 잠금 해제
}

int main(void){
	int thr_id;
	pthread_t p_thread[2];
	int status;
	int a = 1;

	ncount=0;
	thr_id=pthread_create(&p_thread[0], NULL, do_loop, (void *)&a);
	sleep(1);
	thr_id=pthread_create(&p_thread[1], NULL, do_loop2, (void *)&a);

	pthread_join(p_thread[0], (void *)&status);
	pthread_join(p_thread[1], (void *)&status);

	status=pthread_mutex_destroy(&mutex);
	printf("code = %d\n", status);
	printf("programing is end\n");
	return 0;

}
``` 

<img src="img5.png">

## pthread API II.
### pthread_exit(): 현재 실행 중인 스레드 종료
---
  
<img src="thread_exit_code.png" width="90%">

<img src="thread_exit_output.png" width="50%">

<span style="color:red">**주의!!**</span>　<span style="color:magenta">**Mutex 영역**</span>에서 ***pthread_exit()***가 호출되어 버릴 경우, <span style="color:red">***다른 스레드***</span>는 영원히 ***block*** 될 수 있다. 

### pthread_cleanup_push(): 스레드 종료시 호출할 루틴
---
  
```c
#include <pthread.h>

void pthread_cleanup_push(void (*routine) (void *), void *arg);
```
- 기능: <span style="color:navy">***cleanup handler***</span>를 인스톨한다.
	- ***pthread_exit()***가 호출되어 스레드 종료시, <span style="color:blue">***pthread_cleanup_push()***</span>에 의해 인스톨된 함수가 호출된다.
	- **routine**이 스레드가 종료될때 호출되는 <span style="color:blue">**함수**</span>. **arg**는 아규먼트이다.
	- <span style="color:navy">***cleanup handler***</span> 는 <span style="color:steelblue">**자원**</span>을 돌려주거나, **Mutex** 잠금 등의 해제를 위한 용도로 사용
		- <span style="color:magenta">**Mutex 영역**</span>에서 ***pthread_exit()***가 호출되어 버릴 경우, <span style="color:red">***다른 스레드***</span>는 영원히 ***block*** 될 수 있다. 
		- **malloc**으로 할당 받은 메모리, **열린 fd**를 닫기 위해서로 사용한다.


### pthread_cleanup_pop(): cleanup handler제거
---
  
```c
#include <pthread.h>

void pthread_cleanup_pop(int execute);
```
- 기능
	- **execute == 0**, ***pthread_cleanup_push()*** 에 의해 인스톨된 <span style="color:navy">***cleanup handler***</span>를 **실행치 않고**, **삭제**만 시킨다.
	- **execute != 0**0, <span style="color:navy">***cleanup handler***</span>를 **실행**하고, **삭제**한다.

<span style="color:red">**<주의!>**</span> **pthread_cleanup_push()**와 **pthread_cleanup_pop()**은 반드시 <U>같은 함수 내</U>의 <U>같은 레벨의 블럭</U>에서 <U>한 쌍</U>으로 사용

#### pthread_cleanup_{push,pop}() 예제
----

<img src="pthread_cleanup_push_pop.png" width="90%">

### pthread_self():
---
  
```c
#include <pthread.h>

pthread_t pthread_self(void);
```
- 기능: ***pthread_self*** 를 호출하는 현재 스레드의 스레드 식별자를 되돌려준다.


```c
#include <stdio.h>
#include <pthread.h>

void *func(void *a){
	pthread_t id;
	id=pthread_self(); // 스레드 함수 자신의 pthread id
	printf("pthread id in thread func: %ld\n", id);
}

int main(int argc, char *argv[]){
	pthread_t p_thread[2];
	pthread_create(&p_thread[0], NULL, func, (void *)NULL);
	printf("pthread id in main: %ld\n", p_thread[0]);
	pthread_create(&p_thread[1], NULL, func, (void *)NULL);
	printf("pthread id in main: %ld\n", p_thread[1]);

	return 0;
}
```

