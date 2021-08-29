---
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "리눅스 ls, 권한, pstree"
excerpt: "ls: 파일 조회, 파일의 종류, 권한, ps: 프로세스 트리"
comments: true
toc: true
toc_sticky: true
category:
- linux-system
---
## 파일의 종류
- 리눅스에서는 다양한 파일이 있다.
- **\"ls -al\"**명령을 참조하여 살펴본다.
  
<img src="img1.png" width="80%">  
- **\"ls -al\"**의 첫 필드로 <span style="color:steelblue">**파일의 종류**</span>를 알 수 있다.
  
***first field***|***type***|***Example***
**-**|일반 파일|txt, jpg, wave, pdf...
**d**|디렉터리|
<span style="color:steelblue">**l**</span>|링크|심볼릭, 하드링크
<span style="color:orange">**c**</span>|디바이스 파일|프린터, 사운드 카드 등
**s**|소켓|소켓
**p**|pipe|파이프

- **권한**: <span style="color:red">**소유자**</span>(**u**ser), <span style="color:navy">**그룹**</span>(**g**roup), **Other**
	- **-<span style="color:red">rwx</span><span style="color:navy">rw-</span>r-x**    
  
**rwx**|**r-x**|**--x**|**-w-**|**--x**
:===:|:===:|:===:|:===:|:===:
421|401|001|020|001
7|6|1|2|1

- **chmod**: 권한 변경
	- chmod <span style="color:red">**o-rwx**</span> [file] : 파일의 <span style="color:red">**other의 rwx 삭제**</span>
	- chmod g**-**x [file] : 파일의 group의 x **삭제**
	- chmod u**+**x [file] : 파일의 user의 x **가능**

## pstree: 프로세스 트리
- 예를 들어 실행 파일이 여러 자식 프로세스를 만든다고 가정
    
```bash
$ ./fork_omit_switch
[0] PID(24090) PPID(24089)
[1] PID(24091) PPID(24090)
[2] PID(24092) PPID(24091)
[2] PID(24091) PPID(24090)
[1] PID(24090) PPID(24089)
...
```  
- 프로세스의 PID와 PPID관계를 보기 쉽지 않다.
<br><br>
- `pstree -pl`: 프로세스 트리 조회
  
```bash
$ ./fork_omit_switch&
$ pstree -pl
...
fork_omit_switch(20489) ... fork_omit_switch(24090) ... fork_omit_switch(24091) ... fork_omit_switch(24092)
                                                        fork_omit_switch(24093)
                        ... fork_omit_switch(24094) ... fork_omit_switch(24095)
                        ... fork_omit_switch(24096)
```

