---
title: "파일 처리: 저수준 vs 고수준"
excerpt: "low level systemcall I/O vs STDIO"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 저수준 vs 고수준
  
**file processing**|**Description**
**저수준** 파일 처리|**시스템 콜**<br><span style="color:red">**Byte 단위**</span> 지정한 버퍼 크기만큼 R/W<br>UNIX 계열에서만 호환<br>**p**read, **p**write를 통해 <span style="color:red">**atomic**</span>실행 보장(Thread safe)
**고수준** 파일 처리|**POSIX C**<span style="color:blue">**문자 단위, 줄 단위 R/W**</span><br>C 표준 이므로, **C를 지원하는 모든 플랫폼에서 사용** 가능<br><span style="color:steelblue">**stdio 버퍼링**</span> 있음<br>버퍼링은 **사용자 변수**와 <span style="color:steelblue">**버퍼**</span> **사이**의 **메모리 복사**, <span style="color:steelblue">**버퍼**</span>와 <span style="color:magenta">**커널**</span> 사이의 **복사**까지 **중복**되므로 **메모리 대역폭을 비효율적 사용**.<br>저수준 파일 처리보다 비효율적인 면이 있기에 **real-time system과 같이 응답성과 성능을 중시**한다면 <span style="color:red">**고수준 파일 처리는 최소화**</span>(다양한 옵션이 있기 때문에 저수준 VS 고수준 단편 속도 비교 불가)
  
<br>
**stdio 버퍼**
- **stdio만의 독자적인 버퍼** 사용  
	- 내부적으로 **적절한 크기**로 **read()**를 사용해 **stdio 버퍼**로 가져와, **프로그램이 요구한 만큼 반환**

- **읽을 때**, 버퍼링  
1. 적절한 크기만큼 **시스템 콜 read()**를 사용해 **stdio 버퍼에 저장**
2. 프로그램이 요청하는 만큼 반환
  
- **쓰기 때**, 버퍼링  
1. **바이트** 단위, **줄** 단위의 데이터를 전달받아 **stdio 버퍼**가 꽉차면 **시스템 콜 write() 내부적 호출**
2. 스트림이 단말에 연결된 경우, 버퍼가 가득 찰 때까지 기다리지 않는다.  
		- **\'\n\'**를 만나면 **즉각**적으로 **시스템 콜 write()** 호출(빠른 응답성 요구)  
3. <span style="color:red">**setvbuf()**</span>를 이용해, **비 버퍼링 모드** 셋, **즉시 write() 수행**

## 멀티 스레드/프로세싱에서 파일 출력이 섞이지 않게 하려면 어떻게 하나?
- 복잡한 **멀티 스레드**를 적용한 **네트워크 서버**에서 **로그 파일**을 **기록**하는 데 있어서 **로그 메시지**가 **서로 섞이지 않게** 하고 싶다!!
1. **저수준 출력** 함수 사용  
		- **저수준** 출력은 <span style="color:red">**atomic**</span> 보장 하므로, 저수준 출력을 사용한다.
		- 장점: 성능을 해지치 않는다.
		- 단점: 저수준 FILE I/O는 불편함 
2. <span style="color:red">**Lock**</span> 이용  
		- 장점: 간단
		- 단점: lock쓰면 느림 -> 빈번한 출력에서는 사용하지 않음
3. **직렬화**를 이용하여 전문적으로 출력을 도맡아서 하는 프로세스나 스레드 둔다.  
		- 장점: 신뢰성이 높음, 응답이 좋음
		- 단점: 설계 과정 복잠
4. **mmap**을 이용해 메모리에 쓰고 파일로 동기화하는 방법

## 저수준에서 printf
- 형식화된 출력(formatted print)란, 간단하게 printf
- **저수준**에서 **printf**  
	- **snprintf()**사용 후, **write**계열 함수 사용  
	```c
	len = snprintf(buf, sizeof(buf), "counter : %d", i);
	write(fd, buf, len);
	```
	- **dprintf()**(POSIX.1-2008 표준)
	```c
	dprintf(fd, "counter: %d", i);
	```

## 저수준 파일 처리 관련 함수
- POSIX.1-2008
  
**저수준 함수**|**Description**
***open()***|파일 열기
***openat()***|fd를 지정하여 파일 열기
***close()***|파일 닫기
***create()***|생성
***fcntl()***|fd 조작
***fsync()***|파일 동기화
***fdatasync()***|메타 정보(access time, inode 정보 등)를 제외한 동기화
***dup(), dup2()***|fd 복제
***read(), write()***|읽기, 쓰기
***pread(), pwrite()***|오프셋을 지정한 읽기 쓰기(<span style="color:magenta">**시그널**</span>, <span style="color:red">**스레드**</span>에 <span style="color:navy">**안전**</span>)
***readv(), writev()***|**벡터** 단위 읽기 쓰기
***dprintf()***|저수준에서 printf (POSIX.1-2008에서 추가)
***lseek()***|파일 위치 변경
***truncate()***|파일 크기 변경
***fdopen()***|fd를 고수준 파일 처리 스트림으로 변환
***renameat()***|파일명 변경(POSIX.1-2008에서 추가)
***glob()***|패턴 매칭되는 path명 찾기
***stat(), fstat(), fstatat()***|파일 메타 정보 읽기

## 고수준 파일 처리 관련 함수
  
**고수준 함수**|**Description**
***fopen(), fclose()***|파일 스트림 열기, 닫기
***freopen(), fdopen()***|파일 스트림을 지정한 파일 스트림으로서 열기, fd -> 파일 스트림 변환
***setvbuf(), setbuf()***|stdio 버퍼 설정
***fflush(), fpurge()***|버퍼 비움, 버퍼 삭제
***fread(), fwrite()***|문자열로서가 아닌 Byte로서 읽고 쓰기
***scanf()계열***|형식화된 문자열 입력
***printf()계열***|형식화된 문자열 출력
***fgetpos(), fsetpos(), fseek(), ftell(), rewind()***|파일 스트림 위치 변경, 보고
***clearerr(), feof(), ferror()***|파일 스트림 체크
***ftruncate()***|파일 크기 변경
***fileno()***|스트림->fd
***fmemopen(), open_memsteram()***|메모리를 파일 스트림으로 열기(POSIX.1-2008)
***getline(), getdelim()***|행단위, 구분자 단위로 읽기(POSIX.1-2008)
***getc_unlocked(), getchar_unlocked(), putc_unlocked(), putchar_unlocked()***|getc, getchar, putc, putchar의 **NON-BLOCKING**

## 파일 관련 시스템 함수

**파일 관련 시스템 함수**|**Description**
***umask()***|umask값 조정
***mktemp()***|임시 파일 생성
***remove(), unlink()***|파일 삭제
***link()***|링크 생성
***mkdir(), rmdir()***|디렉터리 생성, 삭제
***opendir(), closedir(), fdopendir(), dirfd()***|디렉터리 열고 닫기
***readdir(), rewinddir(), seekdir(), telldir()***|디렉터리 읽기, 위치 변경/보고
***scandir(), alphasort()***|디렉터리 스캔






## 메모
pread, pwrite, 
만일 파일이 아닌 파이프에 입출력할 때는 read, write를 PIPE_BUF 이내의 길이로 입출력하는 경우에 atomic 보장
(<span style="color:magenta">PIPE_BUF는 POSIX표준에서 _POSIX_PIPE_BUF(512 Byte)의 최소 기준을 세우고 있음)
하지만, 대부분의 유닉스 계열의 PIPE_BUF는 이보다 훨씬 큰 값 지원(보통 Page의 영향을 받아 4KByte 배수)
