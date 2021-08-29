---
title: "파일시스템 API <5> 임시파일 생성, 파일삭제, 변경 tmpnam(), tmpfile(), remove(), rename()"
excerpt: "tmpnam(), tmpfile(), remove(), rename()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 임시파일 생성
- 임시파일은 `/tmp` 에 만들어진다.
- 보통은 모든 응용프로그램들이 사용해야 하므로 권한은 **777**이다.
	- 하지만 root가 만들어 놓은 임시파일을 다른 유저가 접근하면 안된다.
- UNIX는 `stikey bit` 도입하여 문제 해결
	- 누구나 자신의 파일을 만들 수 있지만, 자신의 권한이 아닌 파일에는 접근 못하게한다.

- UNIX에서 아래와 같이 **랜덤**하게 임시파일 이름을 만드는 함수를 제공한다.
  
```c
#include <stdio.h>

char *tmpnam(char *s);
FILE *tmpfile(void);
```
- <span style="color:blue">**tmpnam**</span>을 사용하면 **절대 경로**를 가지는 랜덤한 이름의 파일 이름을 아규먼트로 되돌려 준다.
	- ex) \"/tmp/file8pwCL\"
- <span style="color:blue">**tmpfile**</span>은 임시 파일을 read/write모드로 생성하고, 여기에 대한 파일 스트림 포인터를 되돌려준다.
	- 이 파일은 프로그램이 종료될 때 자동적으로 삭제된다.
	- 만약 유일한 파일이름이 만들어지지 않는다면 NULL을 되돌려준다.
  
```c
#include <stdio.h>

int main(){
	char name[255];
	int i;
	mkstemp(name);
	printf("%s\n",name);
}
```

## 파일 지우기 및 이름 변경
  
```c
#include <stdio.h>

int remove(char *path);
int rename(char *oldpath, const char *newpath);
```
- **remove**: **파일 삭제**
- **rename**: **파일 이름 변경**
