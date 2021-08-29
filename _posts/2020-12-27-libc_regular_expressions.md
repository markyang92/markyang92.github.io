---
title: "libc Regular Expressions API"
excerpt: "libc 정규 표현식 API"
comments: true
toc: true
toc_sticky: true
category:
- env
---
## libc(The GNU C Library)의 정규 표현식 API

```c
#include <sys/types.h>
#include <regex.h>

int regcomp(regex_t *reg, const char *pattern, int cflags);
```
기능:  정규 표현식 문자열 ***\*pattern***으로 받아서, ***regex_t***형식 문자열로 변환해 ***\*reg***에 기록한다.<br>즉, <span style="color:red">**정규식 패턴을 저장**</span>하는 것
  
cflags option|Description
:---|:---
**REG\_EXTENDED**|셋**O**:정규 표현식을 interpreting할 때, POSIX Extended Regular Expression syntax를 사용한다.<br>셋**X**: POSIX basix Regular Expression syntax가 사용된다.
**REG\_ICASE**|**Case insensitive**
**REG\_NOSUB**|match position을 report하지 말 것.<br> <U>nmatch</U>와 <U>pmatch</U> 아규먼트는 무시된다.
**REG\_NEWLINE**|**\***을 새 라인에 매치하지 않는다.<br>Non-matching 리스트 (\[^...\])를 새 라인에 매치하지 않는다.<br>Match-beginning-of-line (^)가 <U>eflags</U> 여부에 상관 없이 새라인 이후, 즉시 빈 문자열을 매칭한다.<br>Match-end-of-line ($)가 <U>eflags NOTEOL포함</U> 여부에 상관없이 새 라인 전에 즉시 빈 문자열을 매칭한다.
  

return|value
:---|:---
성공|**0**
실패|**에러코드** ==> ***regerror()***가 이 에러코드를 에러메시지로 변환
  
```c
#include <sys/types.h>
#include <regex.h>

void regfree(regex_t *reg);
```
기능: ***regcomp()***에 의해 할당된 메모리 해제
  
   
```c
#include <sys/types.h>
#include <regex.h>

int regexec(const regex_t *reg, const char *string,
			size_t nmatch, regmatch_t pmatch[], int flags);
```
기능: ***regcomp()***에서 변환된 ***regex_t***를 사용하여 <span style="color:red">**실제로 문자열과 패턴을 조합**</span>하는 **API**  

return|value
:---|:---
성공|**0** : 받은 문자열 *string*이 패턴 *reg*에 적합하다.
실패|**REG\_NOMATCH**
  
  
```c
#include <sys/types.h>
#include <regex.h>

size_t regerror(int errcode, const regex_t *reg,
				char *msgbuf, size_t msgbuf_size);
```
  
<img src="img1.png">
