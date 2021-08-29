---
title: "파일시스템 API <4> 파일 정보 획득, 변경 stat(), chmode(), chown(), utime()"
excerpt: "stat(), chmode(), chown(), utime()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 메타 정보 획득하기
- **파일 시스템內 메타 정보**
	- 파일의 종류, 크기, 권한, 소유자, 그룹, 작성 시각, 변경 시각, 액세스 시각

이 것들을 획득하는 시스템 콜이 **stat()**, **lstat()**

### stat():2 fstat():2 lstat():2
---
  
```c
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int stat(const char *path, struct stat *buf);
int fstat(int fd, struct stat *buf);
int lstat(const char *path, struct stat *buf);
```
- 기능
	- ***stat()***은 ***path***로 지정한 엔트리 정보를 취득해, <span style="color:red">**buf에 써넣는다**</span>.  
	- ***fstat()***은 file이 **fd**로 주어진 것 제외하고는 ***stat()***과 동일.  
	- ***lstat()***은 ***path***가 <span style="color:steelblue">**심볼릭 링크**</span>이면, 그 **심볼릭 링크** 정보를 반환, <span style="color:red">**buf에 써넣는다**</span>.
  
 
- <span style="color:red">**주의!**</span> file로 이끄는 **\*path**내 모든 디렉터리 경로에 **permission**이 필요하다.  


return|value
:---|:---
성공|0
실패|-1<br>errno set
  
<br><br>
<span style="color:magenta">**struct stat**</span> **멤버 설명**
  
타입 |멤버 이름|설명
:---|:---|:---
dev\_t|st\_dev|디바이스 번호
ino\_t|st\_ino|i 노드 번호
mode\_t|st\_mode|파일 타입과 권한을 포함한 플래그
nlink\_t|st\_nlink|링크 카운터
uid\_t|st\_uid|소유 사용자 ID
gid\_t|st\_gid|소유 그룹 ID
dev\_t|st\_rdev|디바이스 파일의 종류를 나타내는 번호
off\_t|st\_size|파일 크기(바이트 단위)
bikesize\_t|st\_bikesize|파일 블록의 크기
blkcnt\_t|st\_blocks|블록 수
time\_t|st\_atim.tv\_sec|최종 액세스 시각의 초 단위(예전에는 st\_atime)
long|st\_atim.tv\_nsec|최종 액세스 시각의 나노 초 단위
time\_t|st\_mtim.tv\_sec|최종 변경 시각의 초 단위(예전에는 st\_mtime)
long|st\_mtim.tv\_nsec|최종 변경 시각의 나노 초 단위
time\_t|st\_ctim.tv\_sec|메타 정보의 최종 변경 시각의 초 단위(옛날에는 st\_ctime)
long|st\_ctim.tv\_nsec|메타 정보의 최종 변경 시각의 나노 초 단위
  
- 멤버 타입 대부분 <span style="color:magenta">typedef</span>로 정의 되어 있고, <span style="color:magenta">ssize\_t</span>처럼 정수 타입

### 간단한 예제
---
```c
#include <stdio.h>
#include <fcntl.h>

int main(void){
	int fd;
	struct stat sb; /* 1. stat을 저장할 버퍼 */

	fd=open("person_info", O_RDONLY);
	if(fd==-1){
		perror("open() fail\n);
		return -1;
	}

	if(fstat(fd,&sb)==-1){ /* 2. stat() 사용. 내용은 sb에 저장 */
		printf("stat() fail\n);
		close(fp);
		return -1;
	}
}

```

### 큰 파일에 대한 대응과 long long 타입
---
- 32bit, 2<sup>31</sup>=2GB 이상 표현하기 위해 **라지 파일 서포트**(large file support, LFS)
- 활성화 방법
	- <span style="color:magenta">***#define _FILE_OFFSET_BITS 64***</span><br>그러면, 32bit에서 **off_t**타입이 **long long**이 된다.

### stat 명령어 만들기
---
- 시스템 콜 **stat()**을 사용하여 stat 명령어를 만들어 보자.
- 우리가 만들 stat 명령어는 다음과 같이 파일의 메타 정보를 출력한다.
  
```bash
$ ./stat memo.txt
type	100000 (file)
mode	644
dev	39
ino	1236092
rdev	0
nlink	1
uid	1001
gid	1001
size	1597
blksize	4096
blocks	0
atime	Fri Aug 25 00:01:00 2017
mtime	Fri Aug 25 00:01:00 2017
ctime	Fri Aug 25 00:01:00 2017
```
**stat.c**
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

static char *filetype(mode_t mode);

int main(int argc, char * argv[]){
	struct stat st;
	if(argc!=2){
		fprintf(stderr,"wrong argument\n");
		exit(1);
	}
	if(lstat(argv[1], &st)<0){
		perror(argv[1]);
		exit(1);
	}
	printf("type\t%o (%s)\n", (st.st_mode & S_IFMT), filetype(st.st_mode));
	printf("mode\t%o\n", st.st_mode & -S_IFMT);
	printf("dev\t%llu\n", (unsigned long long)st.st_dev);
	printf("ino\t%lu\n", (unsigned long)st.st_ino);
	printf("rdev\t%llu\n", (unsigned long long)st.st_rdev);
	printf("nlink\t%lu\n", (unsigned long)st.st_nlink);
	printf("uid\t%d\n", st.st_uid);
	printf("gid\t%d\n", st.st_gid);
	printf("size\t%ld\n", st.st_size);
	printf("blksize\t%lu\n", (unsigned long)st.st_blksize);
	pirntf("blocks\t%lu\n", (unsigned long)st.st_blocks);
	printf("atime\t%s", ctime(&st.st_atime));
	printf("mtime\t%s", ctime(&st.st_mtime));
	printf("ctime\t%s", ctime(&st.st_ctime));
	exit(0);
}

static char* filetype(mode_t mode){
	if (S_ISREG(mode)) return "file";
	if (S_ISDIR(mode)) return "directory";
	if (S_ISCHR(mode)) return "chardev";
	if (S_ISBLK(mode)) return "blockdev";
	if (S_ISFIFO(mode)) return "fifo";
	if (S_ISLNK(mode)) return "symlink";
	if (S_ISSOCK(mode)) return "socket";
	return "unknown";
}
```

**보는 바와 같이** <span style="color:magenta">***struct stat***</span>에 필요한 정보가 다 있다.  
<span style="color:red">***주의!***</span>
- <span style="color:steelblue">**심볼릭 링크**</span>의 경우, 심볼릭 링크 자신의 정보를 취하는 것이 적절하므로 **stat()**대신 **lstat()**사용
- <span style="color:magenta">**st\_mode**</span> 멤버에서 파일 유형을 꺼내기 위해 <span style="color:red">**S\_IFMT**</span>와 비트 마스크 사용
- <span style="color:magenta">**S\_ISREG()**</span> 등의 매크로 사용
<br><br>
- **파일 판정 매크로 목록**
  
매크로 이름|효과
:---|:---
__S\_ISREG__|보통 파일이라면 0이 아닌 값
__S\_ISDIR__|디렉터리라면 0이 아닌 값
__S\_ISLNK__|심볼릭 링크라면 0이 아닌 값
__S\_ISCHR__|캐릭터 디바이스라면 0이 아닌 값
__S\_ISBLK__|블록 디바이스라면 0이 아닌 값
__S\_ISFIFO__|named pipe(FIFO)라면 0이 아닌 값
__S\_ISSOCK__|유닉스 소켓이라면 0이 아닌 값
  
  
## 메타 정보 변경
  
**메타 정보를 변경하는 시스템 콜**
  
변경 대상|사용하는 시스템 콜
:---|:---
권한|chmod():2
오너와 그룹|chown():2
최종 액세스 시각과 최종 갱신 시각|utime():2

### chmode():2
---
  
```c
#include <sys/stat.h>

int chmod(const char *path, mode_t mode);
```
- **chmode()**는 ***path***로 지정한 파일의 모드를 ***mode***로 바꾼다.
  
return|value
:---|:---
성공|0
실패|-1<br>errno set
  
- **mode**는 아래 **상수**나 **값**을 **OR**로 묶어 지정하거나, *0755*같은 숫자를 사용한다.
	- C에서 0을 일부러 앞에 두면, 8진수이다.
- **permission 644: 0644, S\_IRUSR \| S\_IWUSR \| S\_IRGRP \| S\_IROTH**
  
**상수**|**값**|**의미**
:---|:---|:---
**S_IRUSR, S_IREAD**|**00400**|소유한 사용자가 읽기 가능
**S_IWUSR, S_IWRITE**|**00200**|소유한 사용자가 쓰기 가능
**S_IXUSR, S_IEXEC**|**00100**|소유한 사용자가 실행 가능
**S_IRGRP**|**00040**|소유한 사용자가 속한 그룹이 읽기 가능
**S_IXGRP**|**00010**|소유한 사용자가 속한 그룹이 실행 가능
**S_IROTH**|**00004**|그 외의 사용자가 읽기 가능
**S_IWOTH**|**00002**|그 외의 사용자가 쓰기 가능
**S_IXOTH**|**00001**|그 외의 사용자가 실행 가능
  
### chown():2
---
  
```c
#include <unistd.h>

int chown(const char *path, uid_t owner, gid_t group);
int lchown(const char *path, uid_t owner, gid_t group);
```
- **chmown()**은 ***path***의 소유 사용자를 **owner**로 소유, 그룹을 **group**으로 변경한다.<br>***path***가 <span style="color:steelblue">**심볼릭 링크**</span>인 경우, 그 심볼릭 링크가 <U>가리키는 파일의 정보</U>를 변경한다.
	- owner: 사용자 ID
	- group: 그룹 ID
	- 이 中 하나만을 변경하는 경우, 변경하지 않는 쪽에 **-1**
<br><br>
- **lchown()**은 ***path***가 <span style="color:steelblue">**심볼릭 링크**</span>인 경우, 그 심볼릭 링크 <U>자체의 정보</U>를 변경한다.
<br><br>
<span style="color:red">**주의!!**</span>
- **<U>소유 <span style="color:red">사용자</span>를 변경</U>**코자 하면, **su 권한 필요**
- **<U>소유 <span style="color:blue">그룹</span>을 변경</U>**하는 경우, 해당 파일의 <span style="color:blue">**소유 사용자**</span>이며 <span style="color:blue">**자신이 포함된 그룹**</span>으로만 변경할 수 있다. (**su 권한이면 임의의 그룹으로 변경가능**)

### utime():2
---
  
```c
#include <sys/types.h>
#include <utime.h>

int utime(const char *path, struct utimbuf *buf);

struct utimbuf{
	time_t actime;	/* 최종 액세스 시각 */
	time_t modtime;	/* 최종 갱신 시각 */
};
```
- 기능: ***utime()***은 **path**로 지정한 파일의<br><span style="color:red">**최종 액세스 시각**</span>**(`st_atime`)** <span style="color:red">**최종 갱신 시각**</span>**(`st_mtime`)**을 변경한다.<br>***buf***가 **NULL**이 아니면 buf의 내용에 따라 *actime*과 *modtime*이 설정된다. ***buf***가 NULL이라면, 양쪽 모두 현재 시각으로 변경된다.  
  
return|value
:---|:---
성공|0
실패|-1<br>errno set
  
_parameter_|Description
:---|:---
_\*path_|**path**로 지정한 파일의 **최종 액세스 시각(st\_atime**, **최종 갱신 시각(st\_mtime)** 을 변경
_\*buf_|<span style="color:steelblue">**!NULL**</span>: **buf**의 내용에 따라 **actime**과 **modtime**이 설정<br><span style="color:steelblue">**NULL**</span>: **양쪽 모두 현재 시각**으로 변경

***time_t***는 추후에 자세히 기술

### chmod 명령 작성 예제
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(int argc, char *argv[]){
	int mode;
	int i;
	if(argc<2){
		fprintf(stderr, "no mode given\n");
		exit(1);
	}
	mode= strtol(argv[1], NULL, 8);
	for(i=2; i<argc; i++){
		if(chmod(argv[i], mode) < 0){
			perror(argv[i]);
		}
	}
	exit(0);
}
```
  
  

