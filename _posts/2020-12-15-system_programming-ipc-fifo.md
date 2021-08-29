---
title: "Pipe <2> fifo()"
excerpt: "fifo()"
comments: true
toc: true
toc_sticky: true
category:
- ipc
---
## Named pipe(FIFO)
- Uni-directional byte stream: 그냥 주면 받아야함
- 파일 경로가 ID
	- <span style="color:red">***unrelated process(Child 아닌 것도)***</span> 간에도 사용 가능
- FIFO 생성과 open이 분리되어 있음
- **open()시 read-side와 write-side가 동기화**됨
	- 즉, <span style="color:red">**양쪽 모두 open시도가 있어야 성공!**</span>
	- open시 O_NONBLOCK이 유용하게 사용될 수 있음
		- 하나만 open시 block되지만, `open(...,O_NONBLOCK)` 옵션하면 block안걸림
		- 하지만, 한 쪽만 fifo open후, O_NONBLOCK이면 에러
		
<img src="img1.PNG" width="100%" height="100%">

```c
#include <sys/types.h>
#include <sys/stat.h>

int mkfifo(const char *pathname, mode_t mode);
```
- 역할: named pipe 파일을 생성
  
return value|describe
:---:|:---
0|성공
-1|실패
   
parameter|describe
:---|:---
_\*pathname_|생성할 named pipe `파일 경로`
*mode*|permission
    
**named PIPE(fifo) example**
<img src="ex1.PNG" width="100%" height="100%">

