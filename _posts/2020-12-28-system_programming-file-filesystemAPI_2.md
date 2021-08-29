---
title: "파일시스템 API <2> 디렉터리 관련 함수: mkdir(), rmdir()"
excerpt: "mkdir(), rmdir()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 디렉터리 만들기
### mkdir():2
---
  
```c
#include <sys/stat.h>
#include <sys/types.h>

int mkdir(const char *path, mode_t mode);
```
- ***mkdir()***은 <span style="color:blue">***path***</span>로 지정한 디렉터리를 만든다.

return|value
:---|:---
성공|0
실패|-1<br>errno set

_parameter_|Description
:---|:---
_\*path_|디렉터리를 만들 _path_
_mode_|**permission**지정<br>지정된 권한이 그대로 되는 것은 아니고, 먼저 **umask** 값과 비트 연산이 이루어진다.
  
- **mkdir()**은 다른 시스템 콜에비해 <span style="color:red">**실패**</span>자주 한다. 원인은 아래와 같다.
	- **ENOENT**: 상위 디렉터리가 없다. ex) *mkdir("/usr/src/hello",0)*에서, */usr/src*가 없는 경우
	- **ENOTDIR**: *path*로 지정한 상위 디렉터리가 디렉터리가 아니다. ex) *mkdir("/usr/src/hello", 0)*에서, */usr/src*가 파일인 경우
	- **EEXIST**: *path*로 지정한 경로에 이미 파일이나 디렉터리가 존재한다. ex) *mkdir("/usr/src/hello", 0)*에서, */usr/src/hello*가 이미 존재
	- **EPERM**: 상위 디렉터리에 대한 변경 권한이 없다. ex) *mkdir("/usr/src/hello", 0)*에서, */usr/src*에 쓰기 권한이 없는 경우

## umask
- **mkdir(), open()**을 사용할 때 만들어질 파일의 권한을 지정할 수 있지만, 지정한 값이 그대로 사용되는 것은 아니다.<br><span style="color:magenta">**umask를 사용해서 변경된 값이 사용된다.**</span>
- umask는 프로세스의 속성 중 하나로, 가장 일반적인 값은 8진수 022<sub>8</sub>다.
- open(), mkdir()에서 실제로 사용되는 권한은 **'mode & ~umask'**로 계산된다.
	- ex) mode=0777, mask=022<sub>8</sub> => 0755  
　　　　111 111 111 => 111 111 111<br>
　　　　000 010 010	=> 111 101 101<br>
　　　　　　　　　　　**111 101 101** <= <span style="color:red">**실제 적용되는 권한**</span><br>

### umask():2
---
- **umask** 값은 시스템 콜 **umask()**로 변경할 수 있다.
  
```c
#include <sys/types.h>
#include <sys/stat.h>

mode_t umask(mode_t mask);
```
- **umask()**는 프로세스의 **umask 값**을 <span style="color:red">**mask**</span>로 변경하고, 직전까지의 **umask 값을 반환**한다.
  
return|value
:---|:---
성공|직전까지 쓰던 **umask 값**
실패|-
  
_parameter_|Description
:---|:---
_mask_|변경할 **mask 값 입력**


## mkdir 예제
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

int main(int argc, char *argv[]){
	int i;
	if(argc<2){
		fprintf(stderr,"%s: no arguments\n",argv[0]);
		exit(1);
	}
	for(i=1;i<argc;i++){
		if(mkdir(argv[i],0777)<0){ 
			perror(argv[i]);
			exit(1);
		}
	}
	exit(0);
}
```

## 디렉터리 삭제하기
### rmdir():2
---
  
```c
#include <unistd.h>

int rmdir(const char *path);
```
- ***rmdir()***은 ***path***로 지정한 디렉터리를 삭제한다.
- 디렉터리는 반드시 비어 있어야한다.

return|value
:---|:---
성공|0
실패|-1<br>errno set

## rmdir 예제
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char * argv[]){
	int i;
	if(argc<2){
		fprintf(stderr, "%s: no arguments\n", argv[0]);
		exit(1);
	}
	for(i=1;i<argc;i++){
		if(rmdir(argv[i])<0){
			perror(argv[i]);
			exit(1);
		}
	}
	exit(0);
}
```


