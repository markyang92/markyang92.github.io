---
#```
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "thread <2> cond 조건변수, attribute, signal, cancel"
excerpt: "pthread_cond, pthread_attr, pthread_signal, pthread_kill, pthread_cancel"
comments: true
toc: true
toc_sticky: true
category:
- thread
---
## pthread API III: cond
### cond
---
- 스레드가 3개있다고 가정한다.
	1. **main 스레드**
		- 스레드 1, 2를 생성하고 join한다.
	2. <span style="color:navy">**스레드 1**</span>
		- 2개의 int형 멤버를 가진 구조체에 접근해 특정한 숫자를 입력
	3. <span style="color:orange">**스레드 2**</span>
		- 구조체에 접근해 멤버를 읽어와 "덧셈"하고 이를 화면에 출력한다.
- **critical section**
	- 스레드들이 동시에 접근하는 영역
		- **<U>구조체</U> 영역**: 스레드 1과 2가 접근하는 영역 -> <span style="color:red">**Mutex**</span> 필요
- <span style="color:steelblue">**cond**</span>
	- <span style="color:orange">**스레드 2**</span>는 <span style="color:navy">**스레드 1**</span>에 의해 구조체의 값이 변경되는 것을 감지해야함
		- 변경이 **감지**된 후 구조체에 접근해야함
		- 변경될 때까지 **기다려야한다.**
			- 이 **"기다림"**이 <span style="color:steelblue">**조건변수**</span> <span style="color:steelblue">**cond**</span> 필요함 
		- <span style="color:steelblue">**cond**</span>은 마치 <span style="color:magenta">**시그널**</span>을 주고 받는 것과 같다.
<br>
- **cond** 사용의 이점
	- **cond**를 사용하지 않으면, <span style="color:orange">**스레드 2**</span>는 ***busy wait***해야한다.

<img src="thread_cond.png" width="80%">
- <span style="color:orange">**스레드 2**</span> 에서 ***wait***로 **BLOCK**한걸 다른 스레드의 <span style="color:steelblue">***signal***</span>이 깨워줌!  
  
```c
"thread 1"
{
	mutex lock 얻음
	// 임계영역 시작 ===========================================
	구조체에 접근해서 값 변경
	pthread_cond_signal
	// 임계영역 끝 =============================================
	mutex unlock
}

"thread2"
{
	mutex lock 얻음
	// 임계영역 시작 ===========================================
	pthread_cond_wait
	if( cond_signal 왔다면){
		구조체 값 더함
	}
	// 임계영역 끝 =============================================
	mutex unlock
}
```
### cond 주의사항
---
- 과연 **신호**가 **실시간**으로 전달 될 것을 신뢰할 수 있는가?
	- <span style="color:navy">**스레드 1**</span>이 <span style="color:orange">**스레드 2**</span>가 신호를 잘 받았는지 확인X 진행
<br>
- 위 예제를 while文으로 돌리면 예상치 못한 결과가 발생
	- <span style="color:navy">**스레드 1**</span>이 빨리 한번 더 돌아 작업을 한번 더 한 뒤, <span style="color:orange">**스레드 2**</span>가 작업할 수도 있음  
<img src="thread_cond2.png">
- 따라서 `양방향`으로 **signal**을 주고 받자



### pthread_cond_init()
---
  
```c
#include <pthread.h>

int pthread_cond_init(pthread_cont_t *cond, const pthread_cond_attr *attr);
```
- 기능: **pthread_cond_init()**은 **조건 변수**(condition variable)<span style="color:firebrick">***cond***</span>를 **초기화**하기 위해 사용한다.
	- <span style="color:navy">***attr***</span> 을 이용해서 조건 변수의 특성을 변경할 수 있다.
	- <span style="color:steelblue">**NULL**</span>을 주면, 기본특성으로 초기화한다.
	- **조건 변수**(condition variable)<span style="color:firebrick">***cond***</span>는 상수 <span style="color:magenta">**PTHREAD_COND_INITIALIZER**</span>를 이용해서도 초기화할 수 있다.
  
```c
#include <pthread.h>

pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
// 둘 다 동일한 기능
pthrad_cond_init(&cond, NULL);
```

### pthread_cond_signal()
---
  
```c
#include <pthread.h>

int pthread_cond_signal(pthread_cont_t *cond);
```
- 기능: **조건 변수**(condition variable) <span style="color:firebrick">***cond***</span> 에 <span style="color:magenta">**시그널**</span>을 보낸다.
	- <span style="color:magenta">**시그널**</span>을 보낼 경우 <span style="color:firebrick">***cond***</span> 에서 기다리는(**wait**) 스레드가 있다면 **스레드를 깨운다**.
		- 여러 스레드가 기다리고 있다면 **그 중 하나**의 스레드에게만 전달되며 어떤 스레드에 신호가 전달될지 알 수 없다.  
	- <span style="color:firebrick">***cond***</span> 를 기다리는 **스레드가 없다면**, 아무 일도 일어나지 않는다.

### pthread_cond_broadcast()
---
  
```c
#include <pthread.h>

int pthread_cond_broadcast(pthread_cont_t *cond);
```
- 기능: **조건 변수** <span style="color:firebrick">***cond***</span> 에서 **기다리는(wait) 모든 스레드**에게 <span style="color:magenta">**시그널**</span>을 보내 **깨운다.**
  
### pthread_cond_wait()
---
  
```c
#include <pthread.h>

int pthread_cond_wait(pthread_cont_t *cond, pthread_mutex_t *mutex);
```
- 기능: **조건 변수** <span style="color:firebrick">***cond***</span> 를 통해 신호가 전달될 때까지 **블럭**된다.
	- 신호가 전달되지 않으면, 영원히 블럭된다.
	- ***pthread_cond_wait()***는 블럭되기 전에 <span style="color:red">**mutex**</span>잠금을 자동으로 돌려준다.
	- 블럭에서 깨면 <span style="color:red">**mutex**</span> **획득**

<img src="wait.png" width="60%">
  
### pthread_cond_timedwait()
---
  
```c
#include <pthread.h>

int pthread_cond_timedwait(pthread_cont_t *cond, pthread_mutex_t *mutex, const struct timespec *abstime);
```
- 기능: **조건 변수** <span style="color:firebrick">***cond***</span> 를 통해 신호가 전달될 때까지 **블럭**되고, 자동으로 <span style="color:red">**Mutex**</span>를 돌려준다는 점에서 **pthread_cond_wait()**와 동일
	- **abstime**시간 동안 신호가 도착하지 않는다면 **error**를 발생하면서 리턴
		- **ETIMEDOUT**: errno가 아닌 리턴 값으로 에러가 넘어옴!
	- **pthread_cond_timedwait()**함수는 다른 <span style="color:magenta">**시그널**</span>에 의해 **interrupted**될 수 있으며(**EINTR**) 이 상황에 대한 처리 해야한다.
  
### pthread_cond_destroy()
---
  
```c
#include <pthread.h>

int pthread_cond_destroy(pthread_cont_t *cond);
```
- 기능: **pthread_cond_init()**으로 생성된 **조건 변수** <span style="color:firebrick">***cond***</span> 자원 해제
	- **pthread_cond_destroy()** 함수를 호출하기 전에 어떤 스레드도 <span style="color:firebrick">***cond***</span> 에서의 시그널을 기다리지 않는 걸 확인해야 한다.
	- <span style="color:firebrick">***cond***</span> <span style="color:magenta">***시그널***</span> 을 기다리는 스레드가 존재하면, 이 함수는 실패하고 **EBUSY**를 리턴한다.

### cond example
---
  
<img src="thread_cond_example.png">
1. <span style="color:magenta">***pong***</span> 스레드 실행 후 바로 **wait**
2. <span style="color:magenta">***ping***</span> 스레드 실행 후 <span style="color:green">**\"ping\"**</span> 출력 후 **signal** 보내고 **sleep**
  
<span style="color:red">**주의!**</span> <span style="color:magenta">***pong***</span> 이 먼저 실행되야 하기 때문에, <span style="color:steelblue">**&sync_cond**</span>로 제어

## pthread API IV: Attribute
### pthread_attr_init():
---

```c
#include <pthread.h>

int pthread_attr_init(pthread_attr_t *attr);
```
- **pthread_attr_init**은 <span style="color:magenta">***attr***</span> 을 디폴트 값으로 초기화 시킨다.
- 성공 0, 실패 -1
  
### pthread_attr_destroy():
---

```c
#include <pthread.h>

int pthread_attr_destroy(pthread_attr_t *attr);
```
- <span style="color:magenta">***attr***</span> 객체 제거

### pthread_attr_getscope()
---

```c
#include <pthread.h>

int pthread_attr_getscope(const pthread_attr_t *attr, int *scope);
```
- 스레드가 **어떤 영역(scope)**에서 다루어지고 있는지 얻어오기 위해 사용
	- <span style="color:magenta">**PTHREAD_SCOPE_SYSTEM**</span>: **user 모드** 스레드
		- LINUX에서는 스레드 라이브러리를 통해 스케줄링하는 **user 모드** 스레드
	- <span style="color:magenta">**PTHREAD_SCOPE_PROCESS**</span>: **kernel 모드** 스레드
		- Solaris에서는 **커널 모드** 스레드
  
```c
#include <stdio.h>
#include <pthread.h>

int main(void){
	pthread_attr_t pattr;
	int scope;

	pthread_attr_init(&pattr);
	pthread_attr_getscope(&pattr, &scope);
	if (scope == PTHREAD_SCOPE_SYSTEM)
		printf("user mode thread\n")
	else if (scope == PTHREAD_SCOPE_PROCESS)
		printf("kernel mode thread\n");
	return 0;
}
```
  
### pthread_attr_setscope
---
  
```c
#include <pthread.h>

int pthread_attr_setscope(pthread_attr_t *attr, int scope);
```
- 기능: 스레드가 어떤 영역(scope)에서 작동하게 할 것인지 결정
	- LINUX는 **user mode**에서만 동작한다.
	- Solaris는 둘다 선택 가능하다.
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

int main(void){
	pthread_attr_t pattr;
	int scope;
	pthread_attr_init(&pattr);

	pthread_attr_setscope(&pattr, PTHREAD_SCOPE_PROCESS);
	pthread_attr_getscope(&pattr, &scope);
	if(scope == PTHREAD_SCOPE_SYSTEM)
		printf("user mode thread\n");
	else if(scope == PTHREAD_SCOPE_PROCESS)
		printf("kernel mode thread\n");

	return 0;
}
```

### pthread_attr_getdetachstate
  
```c
#include <pthread.h>

int pthread_attr_getdetachstate(pthread_attr_t *attr, int detachstate);
```
- 기능: 스레드가 **join**가능 한지, **detached** 상태인지 알아낸다. 알아낸 값은 ***detachstate***에 저장된다.
	- <span style="color:navy">**PTHREAD_CREATE_JOINABLE**</span>: **(default)**, 스레드가 **join** 가능함
	- <span style="color:navy">**PTHREAD_CREATE_DETACHED**</span>: 스레드가 **pthread_detach**를 이용해서 생성되었거나 혹은 **pthread_attr_setdetachstate()**함수를 이용해서 스레드를 **detache 상태로 변경** 시켰을 경우

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

pthread_attr_t attr;
void *test(void *a){
	int policy;
	printf("Thread create\n");
	pthread_attr_getdetachstate(&attr, &policy);
	if(policy == PTHREAD_CREATE_JOINABLE)
		printf("joinable\n");
	else if (policy == PTHREAD_CREATE_DETACHED)
		printf("detache\n");
}

int main(void){
	int status;
	pthread_t p_thread;
	pthread_attr_init(&attr);
	if(pthread_create(&p_thread, NULL, test, (void *)NULL)<0){
		perror("pthread_create error: ");
		exit(1);
	}
	pthread_join(p_thread, (void **)&status);

	return 0;
}
```

### pthread_attr_setdetachstate
---
  
```c
#include <pthread.h>

int pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate);
```
- 기능: 스레드의 상태를 <span style="color:navy">**PTHREAD_CREATE_JOINABLE**</span> 혹은 <span style="color:navy">**PTHREAD_CREATE_DETACHED**</span>로 변경
  
```c
...

pthread_attr_t attr;

"JOINABLE 상태로 변경"
pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

"DETACHED 상태로 변경"
pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
```

## pthread API V: signal
### pthread_sigmask()
---

```c
#include <pthread.h>
#include <signal.h>

int pthread_sigmask(int how, const sigset_t *newmask, sigset_t *oldmask);
```
- 기능: <span style="color:red">**스레드는 시그널 공유**</span> 따라서 <span style="color:steelblue">**프로세스**</span>에서 <span style="color:red">**스레드**</span>로 <span style="color:magenta">**시그널**</span>을 **전달**하면, **모든 스레드**로 <span style="color:magenta">**시그널**</span>이 전달된다.
	- **특정 스레드**만 <span style="color:magenta">**시그널**</span>을 받도록 하고 싶을 때 사용한다.

### pthread_kill()
---
  
```c
#include <pthread.h>
#include <signal.h>

int pthread_kill(pthread_t thread, int signo);
```
- 기능: 스레드 식별 번호 ***thread*** 로 <span style="color:magenta">**시그널**</span> **signo**를 전달한다.
  
### sigwait()
---
  
```c
#include <pthread.h>
#include <signal.h>

int sigwait(const sigset_t *set, int* signo);
```
- 기능: <span style="color:navy">**set**</span>, signo

## pthread API VI: cancel
### pthread_cancel()
---
  
```c
#include <pthread.h>

int pthread_cancel(pthread_t thread);
```

### pthread_setcancelstate()
---
  
```c
#include <pthread.h>

int pthread_setcancelstate(int state, int *oldstate);
```

### pthread_setcanceltype()
---
  
```c
#include <pthread.h>

int pthread_setcanceltype(int type, int *oldtype);
```

### pthread_testcancel()
---
  
```c
#include <pthread.h>

void pthread_testcancel(void);
```


