---
# <span style="color:steelblue">
title: "디렉터리 API getcwd(), chdir()"
excerpt: "디렉터리 API getcwd(), chdir()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 디렉터리 API
## getcwd():2 현재 디렉터리 얻기
- cwd: current working directory
  
```c
#include <unistd.h>

char *getcwd(char *buf, size_t bufsize);
```
- 기능: 실행 중인 프로세스의 현재 디렉터리를 buf에 써넣는다.

return|value
성공|\*buf
실패|NULL, errno set<br>**ERANGE**: 현재 경로를 나타내는 문자열이 _bufsize_ Byte보다 클 때

_parameter_|Description
:---|:---
_\*buf_|현재 경로를 써넣을 버퍼 주소
_bufsize_|버퍼의 사이즈 Byte

### path를 위한 버퍼 확보
---
- [**readlink()**](https://pllpokko2.github.io//system-programming/filesystemAPI_3/#readlink2)에서도 _bufsize_ 정하는 것이 문제였다.
- **malloc()** 후, 부족하면 **realloc()**으로 버퍼 사이즈를 키우는 편이 낫다.
  
```c
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define INIT_BUFSIZE 1024

char*
my_getcwd(void){
	char *buf, *tmp;
	size_t size = INIT_BUFSIZE;

	buf = malloc(size);
	if(!buf) return NULL;
	for(;;){
		errno=0;
		if (getcwd(buf,size))
			return buf;
		if (errno != ERANGE) break;
		size *= 2;			// 사이즈 2배
		tmp=realloc(buf, size);		// buf시작으로 size만큼 realloc -> tmp에
		if(!tmp) break;			// tmp가 NULL이면 탈출
		buf=tmp;			// buf를 tmp에 매칭
	}
	free(buf);
	return NULL;
}
```

## chdir():2 현재 디렉터리 변경
  
```c
#include <unistd.h>

int chdir(const char *path);
```
- 기능: 현재 프로세스의 현재 디렉터리를 인자로 **지정한 path**로 변경한다.

return|value
성공|0
실패|-1, errno set

### 다른 프로세스의 현재 디렉터리 변경
---
- API가 지원하는 것은 **현재** 프로세스만 바꿀 수 있다.
- 다만 심볼릭 링크 **/proc/PID/cwd**를 사용하는 방법이 있다.
