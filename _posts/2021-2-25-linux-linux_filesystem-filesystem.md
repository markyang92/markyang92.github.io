---
#    
#```c
# <span style="color:steelblue">
title: "리눅스 파일 시스템 종류, 지원하는 파일 시스템 확인,스왑 파티션 관리"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- linux-filesystem
---
## 리눅스 파일 시스템
1. **ext(ext1)**, Extended File System, extfs
- 1992년 4월 리눅스 0.96c 발표
- 파일 시스템 최대 크기: 2GB
- 파일 이름 길이: 255Byte
2. **ext2**
- 1993년 1월 발표
- 리눅스 커널 2.6.17이전 파일 시스템 최대 크기: 2TB
- 현재 파일 시스템 최대 크기: 32TB
- 현재도 부팅 가능한 USB flash, SSD 사용
3. **ext3**
- 2001년 11월 리눅스 2.4.15에 추가
- ext2 파일을 별도 변경없이 `이식가능`
- 2~32TB
- <span style="color:red">**journaling**</span>: 데이터의 `복구 기능`강화
		- 디스크 기록 전 `먼저 저널에` 수정 사항 `기록`
		- 기록 전에 갑자기 전원 나가거나 충돌 시, 이 저널의 기록을 보고 재빨리 복구
- 단점
		- inode 동적 할당이나 다양한 블록 크기와 같은 최신 파일 시스템 기능이 부족
		- 온라인 조각 모음 기능이 없다.
4. **ext4**
- 2008년 12월 25일 리눅스 커널 2.6.28에 포함되어 공개
- 1EB이상의 볼륨과 16TB 이상의 파일 지원, <span style="color:red">**ext2, ext3 호환**</span>
 
<br>
- **다른 기타 파일 시스템**
  
**파일 시스템**|**기능**
**msdos**|MS-DOS 파티션을 사용하기 위한 파일 시스템
**iso9660**|CD-ROM, DVD의 표준 파일 시스템, 읽기 전용으로 사용
**nfs**|Network File System으로 원격 서버의 디스크를 연결할 때 사용
**ufs**|Unix File System으로 유닉스의 표준 파일 시스템
**vfat**|윈도 95, 98, NT를 지원하기 위한 파일 시스템
**hpfs**|HPFS를 지원하기 위한 파일 시스템
**ntfs**|윈도의 NTFS를 지원하기 위한 파일 시스템
**sysv**|유닉스 시스템 V를 지원하기 위한 파일 시스템
**hfs**|맥의 hfs 파일 시스템을 지원하기 위한 파일 시스템
  
<br>
  
- **특수 용도의 가상 파일 시스템**
	- 디스크가 아니라 `메모리에서 생성`되어 사용하는 `가상 파일 시스템`
		- 생겼다 없어졌다.
  
**파일시스템**|**기능**
**swap**|스왑영역을 관리하기 위한 스왑 파일 시스템
**tmpfs**|**Temporary File System**으로 `메모리에 임시 파일`저장 위한 파일 시스템<br>재부팅 시 기존 내용 없어진다.<br>**/run**
**proc**|`커널의 현재 상태`를 나타내는 파일 가지고 있음<br>proc 파일 시스템<br>**/proc**
**ramfs**|램 디스크를 지원하는 파일 시스템
**rootfs**|**/** 루트 파일 시스템
  
## 시스템 지원 파일 시스템 확인
- `/proc/filesystems` 파일 내용에서 현재 커널이 지원하는 파일 시스템 종류 알려줌  
<img src="img1.png" width="50%">
	- <span style="color:red">**nodev**</span>은 해당 파일 시스템이 `블록 장치(예: 디스크)`에 `연결되어 있지 않다.` = `가상 파일 시스템`

## 스왑 파티션 관리
- 스왑 파티션: **스왑**으로 쓰기위한 디스크의 파티션을 일부 `스왑 파티션`으로 둠
  
### 현재 스왑 영역 확인
  
```c
$ swapon -s
```
<img src="img2.png">  
  
### 새로운 디스크 파티션을 스왑 영역으로 추가
- fdisk 명령으로 디스크에 `스왑 파티션을 생성`한다.
```c
$ sudo fdisk /dev/sdd
```
- mkswap 명령으로 스왑 파티션을 `포맷`하여 스왑 파일 시스템을 생성한다.  
```c
$ sudo mkswap /dev/sdd1
```
- 스왑 파티션을 `활성화`한다.
```c
$ sudo swapon /dev/sdd1
```
- 스왑 영역이 추가되었는지 확인
```c
$ swapon -s
Filename	Type		Size		Used		Priority
/dev/sda5	partition	1046524		7284		-1
/dev/sdd1	partition	307196		0		-2
```
- 재부팅 시에도 새 스왑 영역을 활성화하려면 `/etc/fstab` 파일에 정보를 추가한다.
```c
/dev/sdd1 swap swap defaults 0 0
```
  
### 기존 파티션에 스왑 파일 추가하기
- 생성할 스왑 파일의 크기를 정한 후, `1024 X 블록 개수`를 산정한다.  
	- 128MB = 1024 x 131,072 
- 빈 파일을 dd 명령으로 생성한다. count 다음에는 위에서 계산한 블록 개수를 지정한다.  
```c
$ sudo dd if=/dev/zero of=/swapfile bs=1024 count=131072
```
- mkswap 명령으로 위에서 생성한 파일을 스왑 파일로 만든다.
```c
$ sudo mkswap /swapfile
```
- 스왑 파일을 활성화한다.
```c
$ sudo swapon /swapfile
```
- 스왑 파일이 추가되어있는지 확인한다.
```c
$ swapon -s
Filename	Type		Size		Used		Priority
/dev/sda5	partition	1046524		11520		-1
/dev/sdd1	partition	307196		0		-2
/swapfile	file		131068		0		-3
```
- 재부팅 시에도 새 스왑 영역을 활성화하려면 /etc/fstab 파일에 정보를 추가한다.
```c
/swapfile swap swap defaults 0 0
```
