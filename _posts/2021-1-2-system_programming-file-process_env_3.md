---
#<span style="color:steelblue">
title: "자격 증명, 사용자와 그룹 API, EUID RUID EGID RGID"
excerpt: "set-uid, getuid(), geteuid(), getgid(), getegid(), getgroups(), setuid(), setgid(), initgroups(), getpwuid(), getpwnam()"
comments: true
toc: true
toc_sticky: true
category:
- file
---
## 자격 증명
### set-uid 프로그램
---
- **인증**: **프로세스 속성**, 관리 주체는 **커널**

**set-uid 프로그램**: 명령어를 실행하는 사용자와 관계없이 **특정 사용자의 권한**으로 실행하고 싶은 경우가 있다.  
- **passwd**: 암호 변경
	- 암호는 **/etc/passwd, /etc/shadow**에 저장되기 때문에 암호를 변경하려면 이 파일을 수정해야 한다.
	- 모든 사람에게 Permission을 부여할 순 없다.  
<br>
  
이러한 상황을 위해 존재하는 것이 **파일 권한 set-uid bit**이다.
- 특정 **프로그램**에 **set-uid bit set** 시, 실행한 사용자와 관계 없이 <span style="color:steelblue">**프로그램 파일의 소유자 권한**</span>으로 기동한다.
  
<br>
`ls -l` 명령으로 passwd를 살펴보자  
```bash
$ ls -l /usr/bin/passwd
-rwsr-xr-x	1	root	root	54256	May	17	08:37	/usr/bin/passwd
```
- **\'rwx\'**가 아닌 **\'rw**`s`**\'** 로 되어 있다.  
	- 이는 **set-uid bit set**되었다는 뜻이다.  
- 소유자는 **root**이기 때문에 **passwd**는 누가 시작해도 <span style="color:steelblue">**root 권한**</span>으로 실행된다.
<br>
<br>
  
- **set-uid**프로그램으로 부터 기동된 프로세스에는 두 종류의 인증이 있다.
	- **시작한 사용자**: <span style="color:steelblue">**RUID**</span> **실제 사용자 ID**(real user ID)
	- **set-uid 프로그램 소유자**: <span style="color:red">**EUID**</span> **실효 사용자 ID**(effective user ID)

<span style="color:red">**주의!!**</span> **setuid() 시스템 콜**은 **set-uid 프로그램**과 <span style="color:red">**관계 XX**</span>

- **set-gid bit**: 그룹의 자동 상승 구조를 지시하는 권한 플래그
	- **시작한 사용자 그룹**: <span style="color:steelblue">**RGID**</span> **실제 그룹 ID**(real group ID)
	- **프로그램 소유자**: <span style="color:red">**EGID**</span> **실효 그룹 ID**(effective group ID)

### get{uid,euid,gid,egid}():2 현재 자격 증명 획득
---
  
```c
#include <unistd.h>
#include <sys/types.h>

uid_t getuid(void);	"현재 프로세스의 실제 사용자 ID를 반환"
uid_t geteuid(void);	"현재 프로세스의 실효 사용자 ID를 반환"
gid_t getgid(void);	"현재 프로세스의 실제 그룹 ID를 반환"
gid_t getegid(void);	"현재 프로세스의 실효 그룹 ID를 반환"
```

위 시스템 콜은 절대 실패하지 않는다.


### getgroups():2 보조 그룹 ID 얻기
---
```c
#include <unistd.h>
#include <sys/types.h>

int getgroups(int bufsize, gid_t *buf);
```
- 기능: 현재 프로세스의 **보조 그룹 ID를** **buf**에 쓴다.<br>그러나 프로세스의 보조 그룹 ID가 *bufsize*로 지정한 개수보다 많으면, *buf* 에 아무 것도 쓰지 않고 오류반환한다.

return|value
성공|**보조 그룹 ID 수(0 이상)**
실패|-1, errno set

### set{uid,gid}(), initgroups():2 다른 자격 증명으로 이행하기
---
- 현재의 권한 버리고 **새로운 자격 증명** 이행: **setuid(), setgid(), initgroups()**
  
```c
#include <unistd.h>
#include <sys/types.h>

int setuid(uid_t id);
int setgid(gid_t id);
```
- **setuid()**: 현재 프로세스의 실제 사용자 ID와 실효 사용자 ID를 **id**로 변경한다.
- **setgid()**: 현재 프로세스의 실제 그룹 ID와 실효 그룹 ID를 **id**로 변경한다.
  
```c
#define _BSD_SOURCE
#include <grp.h>
#include <sys/types.h>

int initgroups(const char *user, gid_t group);
```
- /etc/group 등의 데이터베이스를 보고, user가 속한 보조 그룹을 현재 프로세스의 보조 그룹으로 설정
- 두 번째 아규먼트 **group**을 추가한다.
- **group**은 일반적으로 사용자 그룹(primary group)을 보조 그룹에도 추가하기 위해 사용한다.
  
<span style="color:red">**주의!**</span> 슈퍼 사용자가 아니면 성공 할 수 없음!
  
return|value
성공|0
실패|-1, errno set
  
위의 **API**를 사용해 완전히 다른 사용자가 되게 하려면 다음의 순서를 따른다.
1. 슈퍼 사용자(root)로서 프로그램을 시작한다.
2. 원하는 사용자의 사용자명과 ID, 그룹 ID를 얻어 둔다.
3. setgid(변경할 그룹 ID)
4. initgroup(변경할 사용자명, 그룹 ID)
5. setuid(변경할 사용자 ID)

## 사용자와 그룹
- 사용자나 그룹에 대한 정보 취급은 **커널이 관리 X**

### getpw{uid,nam}():3 사용자 정보 검색
---
  
```c
#include <pwd.h>
#include <sys/types.h>

struct passwd *getpwuid(uid_t id);
struct passwd *getpwnam(const char *name);

struct passwd{
	char *pw_name;		"사용자 이름"
	char *pw_passwd;	"패스워드"
	uid_t pw_uid;		"사용자 ID"
	gid_t pw_gid;		"그룹 ID"
	char *pw_gecos;		"본명"
	char *pw_dir;		"홈 디렉터리"
	char *pw_shell;		"셸"
}
```
- **getpwuid()**: <span style="color:magenta">지정한 **id**</span>로 **사용자 정보 검색**
- **getpwnam()**: <span style="color:magenta">지정한 **이름**</span>로 **사용자 정보 검색**

return|value
성공|사용자 정보를 <span style="color:magenta">*struct*</span> <span style="color:steelblue">**passwd**</span> 타입으로 반환
실패|NULL, errno set

<span style="color:red">**주의!**</span> 다시 getpw{uid,nam}()을 호출하면 덮어 쓰일 수 있음

### getgr{gid,nam}():3 그룹 정보 검색
---
  
```c
#include <grp.h>
#include <sys/types.h>

struct group *getgrgid(gid_t id);
struct group *getgrnam(const char *name);

struct group{
	char *gr_name;		"그룹명"
	char *gr_passwd;	"그룹 패스워드"
	gid_t gr_gid;		"그룹 ID"
	char **gr_mem;		"그룹에 속하는 멤버(사용자명 리스트)"
};
```
- **getgrgid()**: **지정한 id**로 **그룹 정보 검색**
- **getgrnam()**: **그룹 이름**으로 **그룹 정보 검색**
  
return|value
성공|사용자 정보를 <span style="color:magenta">*struct*</span> <span style="color:steelblue">**group**</span> 타입으로 반환
실패|NULL, errno set
  
<span style="color:red">**주의!**</span> 다시 getpw{uid,nam}()을 호출하면 덮어 쓰일 수 있음
