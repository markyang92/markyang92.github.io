---
title: "linux directory"
excerpt: "리눅스 디렉터리 계층"
comments: true
toc: true
toc_sticky: true
category:
- linux-system
---
# linux structure
## Directory
- FHS(Filesystem Hierarchy Standard)  
디렉터리 트리표준 규격 3.0

## /bin
- *부팅할 때 필요한* 시스템의 기본 명령어 및 실행파일
- */usr/bin*
	- 일반 사용자를 위한 명령어 및 실행파일
	- 최근에는 /usr/bin에 심볼릭 링크되어 있어 구별하지 않는 경우도 있다
	- `/bin`과`/usr/bin`은 배포판이 관리하는 디렉터리
- */usr/**local**/bin*
	- 사용자가직접 설치하는 파일은 여기에! 

## /sbin
- 부팅할 때 필요한 **관리자 용** 명령어
- */usr/sbin*
	- 평상 시 사용하는 시스템 관리 명령어, 서버 프로그램

## /lib
- /lib, /lib64
	- 부팅 시 필요한 라이브러리(`libxxx.a`, `libxxx.so`)
	- C용 외에도 펄, 루피  파이썬 등의 라이브러리 보관
	- 배포판에 따라 /lib, /lib64 사용법이 다르다.
		- Ubuntu
			- /lib64: 거의 사용하지 않음
			- /lib/`x86_64-linux-gnu` 처럼 /lib 디렉터리 밑에 한 단계 디렉터리를 만들어 각종 라이브러리 배치
		- CentOs
			- /lib64: 64bit 라이브러리
			- /lib: 32bit 라이브러리나 아키텍처 독립적인 파일  
- /usr/**local**/lib에 직접 설치하는 라이브러리 

## /usr
- /usr의 특징은 여러 컴퓨터에서 `공유할 수 있는 파일`, `일반 사용자`를 위한 파일
	- 공유?
		- 네트워크 파일 시스템: 대학과 기업 등 구성원들이 사용하는 복수의 머신이 네트워크 파일 시스템을 통해 특정 컴퓨터의 파일 시스템을 네트워크를 통해 마운트하여 사용하는 경우
		- *NFS, SAMBA*
			- 중앙 서버에서 `/usr`에 필요한 파일을 두고, 복수의 시스템이 원격으로 /usr을 마운트해서 사용하게 한다.
			- 복수의 컴퓨터에서 동일한 프로그램이나 라이브러리를 사용할 수 있다
			- 따라서, `/usr 에는 공유할 수 있는 것으로만!`
			- 공유할 수 없는 것은 /var 에!

## */src
- 시스템에서 사용되는 명령어의 **소스 코드**나 **리눅스 커널 소스 코드**

## */include
- 시스템의 `헤더 파일`
- 커널의 헤더 파일: /usr/include/linux

## */share
- 아키텍처에 의존하지 않아 서로 다른 아키텍처에서도 공유할 수 있는 파일들
	- ex) 도큐먼트 류(man, info...)
		- man1, man2, ... 뒤 숫자는 섹션 번호
		- /usr/share/man/man1/cp.1 '도큐먼트 이름.섹션'
	- 배포판에 따라, /usr/man에 보관하기도 한다.

## /usr/**local**
- 각 시스템의 **User**에게 책임이 있는 디렉터리들

## */var
- 자주 바뀌는 파일을 저장
	- ex) 서버 로그, 메일 박스 등..
- 공유하는 파일은 부적합!

- /var/log: 프로세스가 쓰는 로그 파일 저장
- /var/spool: 사용자 메일(/var/spool/mail)이나 프린트 입력(/var/spool/cups) 저장
- /var/run: 실행 중인 서버 프로세스의 PID가 저장(**PID 파일**)
	- 서버 가동 시, 이 디렉터리에 PID 기록, 종료할 때는 제거해야함(매너)
	- ex) inetd 서버
		- `/var/run/inetd.pid`에 자신의 프로세스 ID를 기록한다.
		```bash
		cat /var/run/inetd.pic
		76
		```
		- 이를 응용해서 다음과 같이 inetd에 HUP 시그널을 보내, 설정 파일을 다시 읽도록 할 수 있다.
		```bash
		$ kill -HUP `cat /var/run/inetd.pid`
		```
	- 최근에는 `/var/run`이 `/run`으로 이동하고, /var/run은 단지 /run에 심볼릭 링크  
	분리 이유는, 운영체제 재부팅 시 사라져도 좋은 디렉터리를 /var에서 부터 분리하기 위해서다.

## /etc
- /etc는 **각 시스템의 설정 파일**이 보관
- /etc/fstab, /etc/hosts

## /dev
- /dev에는 **디렉터리 파일**
- 리눅스 2.4 이후엔, 시스템에 존재하는 디바이스 파일만을 그때마다 작성하는 ***devfs***(Device File System)도입
	- devfs는 USB와 같은 동적 디바이스 대응이 잘 이루어지지 않는 문제
- 리눅스 2.6 이후, ***udev*** 도입
- devfs는 커널의 일부로 구현되어 있지만, udev는 커널 밖에 구현되어 있다.

## /proc
- /proc에는 일반적으로 `프로세스 파일 시스템`(Process File System, *procfs*)이 탑재
	- 프로세스를 파일 시스템에 표현한 것
	- pid 1인 프로세스의 정보를 얻고 싶다면, `/proc/1`을 보면 된다.
	```bash
	$ cat /proc/1/statm
	46339	1110	709	0	37310	0
	```
	- ps 명령어, 프로세스 정보 이외에도 커널의 정보 실시간 출력 용도
		- `/proc/partitions`: 시스템에 존재하는 파티션 목록
		- `/proc/scsi`: 시스템에 연결된 SCSI 디바이스 정보
		- `/proc/sys/kernel/hostname`: 현재 호스트 이름
	- 커널에 무언가를 지정하는 데 사용할 수도 있다.
		- `echo -n 'host name' > /proc/sys/kernel/hostname`: 여기서 호스트 이름을 write 하면, 반영
	- 프로세스 파일 시스템의 각 파일의 역할과 형식은 man 5 proc에서 확인 

## /sys
- 리눅스 2.6부터 **sysfs**라는 새로운 파일 시스템 추가. 이 파일 시스템을 탑재하는 디렉터리 '/sys'  
시스템에 존재하는 디바이스나 디바이스 드라이버의 정보를 얻을 수 있다.
- procfs에서 프로세스와 관계없는 정보들이 탑재되기 시작하면서 *시스템 관련 정보들을 별도로 제공*하기 위해 만들어짐

## /boot
- 커널 프로그램 저장
- 리눅스 커널은 *vmlinuz* 파일에 담겨 있다.
	- UNIX: unix
	- BSD: vmunix
	- LINUX: vmlinux -> 압축 -> vmlinuz

## /root
- 슈퍼 사용자 홈 디렉터리

## */tmp
- 임시 파일 저장 공간
- /tmp: 리부팅 시 삭제
- /var/tmp: 리부팅해도 삭제되지 않는다.

## 정리
  
관점            |O           |X                
:---|:---|:---
복수의 호스트에서 공유?|/usr|/var
Read Only?|/usr|/var
아키텍처 의존?|/usr/lib|/usr/share
배포자가 관리 여부?|/usr|/usr/local
리부팅 해도 남아 있음?|/var/tmp|/tmp
  

