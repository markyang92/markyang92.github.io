---
title: "파일시스템 API <3> 링크 관련 함수: link(), symlink(), readlink(), unlink(), rename()"
excerpt: "link(), symlink(), readlink(), unlink(), rename()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 하드 링크
- 리눅스에서는 **하나의 파일에 두 개 이상의 이름 지정**할 수 있다.
- 링크: 파일에 새로운 이름을 붙이는 것
  
```bash
$ echo 'This is file' > a
```
- **a**파일을 만들었다.

<img src="img1.png" width="50%" height="50%">
- 파일의 **이름**과 파일의 **실체**의 관계는 위와 같다.

- 파일 **a**의 실체에 새로운 이름 **b**를 붙여본다. <span style="color:red">***(하드 링크)***</span>
	- '파일 **a**를 가리키는 **하드 링크 b**를 만든다'라고 한다.  

  
```bash
$ ln a b
```

<img src="img2.png" width="50%" height="50%">

- **a**의 내용을 바꾸면 **b**의 내용도 바뀐다. a와 b모두 <span style="color:red">**같은 것을 가리키고 있기 때문**</span>이다.

- 파일에 부여된 이름의 개수는 **`ls -l`**을 사용하여 확인할 수 있다.

  
```bash
$ ls -l    #왼쪽 두 번째가 링크 카운터
-rw-r--r--	2	aamine	users	13 Nov 14 00:15 a
-rw-r--r--	2	aamine	users	13 Nov 14 00:15 b
```
  
<img src="img3.png" width="50%" height="50%">

- <span style="color:red">**rm**</span>을 했을 때, <span style="color:blue">**실체가 삭제되는 것 XX**</span>, <span style="color:red">**이름이 삭제**</span>되는 것임
	- 링크 카운터가 <span style="color:red">**0**</span>이 되면, 비로소 <span style="color:blue">**실체가 삭제**</span>


### link():2
---
- <span style="color:red">**하드 링크**</span>를 작성하는 System Call
  
```c
#include <unistd.h>

int link(const char *src, const char *dest);
```
- **link()**는 <span style="color:magenta">**src(원본)**</span> 지정한 파일에 **dest** 이름의 <span style="color:red">**하드링크**</span> 만든다.

return|value
:---|:---
성공|0
실패|-1<br>errno set
  
- ***src***와 ***dest***는 **동일한 파일 시스템上** 이어야 한다.
- ***src***와 ***dest***는 **디렉터리 XX**

### 하드 링크 예제
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]){
	if(argc!=3){
		fprintf(stderr, "%s: wrong arguments\n", argv[0]);
		exit(1);
	}
	if(link(argv[1], argv[2] < 0)){
		perror(argv[1]);
		exit(1);
	}
	exit(0);
}
```
## 심볼릭 링크
- 하드 링크는 이름과 실체를 연결하는 구조<br><span style="color:steelblue">**심볼릭 링크**</span>는 **이름에 이름을 연결**하는 구조이다.
<img src="img4.png" width="80%" height="80%">

- <span style="color:steelblue">**심볼릭 링크**</span>는 **대응하는 실체가 존재하지 않아도 된다.**
- **파일 시스템의 경계를 뛰어넘어 별명을 붙일 수 있다.**
- **디렉터리에도 별명을 붙일 수 있다.**

### symlink():2
---

```c
#include <unistd.h>

int symlink(const char *src, const char *dest);
```
- <span style="color:steelblue">**심볼릭 링크**</span>를 만드는 시스템 콜
	- __\*src(원본) \*dest(심볼릭 링크)__

return|value
:---|:---
성공|0
실패|-1<br>errno set
  
### readlink():2
---
  
```c
#include <unistd.h>

int readlink(const char *path, char *buf, size_t bufsize);
```
- <span style="color:steelblue">**심볼릭 링크**</span>가 **가리키는 이름을 얻는다.**
  
return|value
:---|:---
성공|buf에 포함된 바이트 수 반환
실패|-1<br>errno set
  
  
_parameter_|Description
:---|:---
_\*path_|<span style="color:steelblue">__심볼릭 링크 path__</span>
_\*buf_|심볼릭 링크 path가 가리키는 이름을 담는 버퍼<br><span style="color:red">**문자열 마지막에 '\\0'**</span>을 자동으로 추가 하지 않는점 <span style="color:red">**주의!**</span>
_bufsize_|최대 이만큼만 이름 저장한다.
  


### 심볼릭링크 예제
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]){
	if(argc!=3){
		fprintf(stderr, "%s: wrong number of arguments\n", argv[0]);
		exit(1);
	}
	if(symlink(argv[1], argv[2])<0){
		perror(argv[1]);
		exit(1);
	}
	exit(0);
}
```

## 파일삭제
- **리눅스에서 파일 삭제**란, <span style="color:red">**링크 카운터 == 0**</span>이 되면 삭제되는 것이다!<br>즉 '실체에 붙인 이름 개수를 줄인다'는 뜻

### unlink():2
---
  
```c
#include <unistd.h>

int unlink(const char *path);
```
- 기능: **\*path**로 지정한 이름을 삭제한다.
  
return|value
:---|:---
성공|0
실패|-1<br>errno set
  
<span style="color:red">**주의!**</span>  
- unlink()로 **디렉터리를 삭제할 수는 없다!!!**(rmdir()사용할 것)
- <span style="color:steelblue">**심볼릭 링크**</span>를 **unlink()**로 삭제하면, 심볼릭 링크만 삭제되고 심볼릭 링크가 기리키는 실체 파일은 삭제되지 않는다.

### unlink()를 사용해 rm 명령어 만들기
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]){
	int i;
	if(argc<2){
		fprintf(stderr, "%s: no arguments\n", argv[0]);
		exit(1);
	}
	for(i=1;i<argc;i++)){
		if(unlink(argv[i]<0){
				perror(argv[i]);
				exit(1);
		}
	}
	exit(0);
}
```

## 파일 이동
- 리눅스에서 **파일을 이동한다** **=** <span style="color:steelblue">**하드 링크**</span>만들고 이전 하드 링크 **제거**
  
```bash
$ mv a b

# 위 아래 같은 동작

$ ln a b
$ rm a
```
- **하지만!** 조금 차이점은 있다.  <span style="color:steelblue">**하드 링크**</span>의 특징은 아래와 같다.
	- **다른 파일 시스템X** => <span style="color:orange">**rename() X**</span>
	- **디렉터리 X** => <span style="color:red">**mv는 가능**</span>

### rename():2
---
  
```c
#include <stdio.h>

int rename(const char *src, const char *dest);
```
- 기능: 파일 이동 API. ***src***를 ***dest***로 변경한다.
  
return|value
:---|:---
성공|0
실패|-1<br>errno set
  
- **다른 파일 시스템X**
	- ***src***와 ***dest***가 다른 파일 시스템이면, *rename*은 실패하고 **EXDEV**가 errno에 set

### rename()을 이용한 mv 구현
---
  
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]){
	if(argc!=3){
		fprintf(stderr,"%s: wrong arguments\n", argv[0]);
		exit(1);
	}
	if (rename(argv[1]. argv[2]) <0){
		perror(argv[1]);
		exit(1);
	}
	exit(0);
}
```
 

