---
#<span style="color:magenta"></span>
title: "리눅스 자주 쓰는 Shell 커맨드"
excerpt: "shell cmd"
comments: true
toc: true
toc_sticky: true
category:
- linux-system
---
## 패키지 관련
> apt provides a high-level commandline interface for the package management system. It is intended as an end user interface and enables some options better suited for interactive usage by default compared to more specialized APT tools like apt-get and apt-cache.<br>- "man apt"
  

- Ubuntu 패키지 관리 툴 명령어 **apt**

apt 명령|설명
:---|:---
$ apt update|Repository 패키지 인덱스 정보 업그레이드
$ apt upgrade|설치되어 있는 패키지 **업그레이드**
$ apt `dist-`upgrade|의존성 검사하며 업그레이드
$ apt install [패키지 이름]|패키지 설치
$ apt `--reinstall` install [패키지 이름]|패키지 재설치
$ apt remove [패키지 이름]|패키지 **삭제** <span style="color:magenta">**설정 파일 미포함**</span>
$ apt purge [패키지 이름]|패키지 **삭제** <span style="color:magenta">**설정 파일 포함**</span>
$ apt autoremove|불필요한 패키지 제거
$ apt full-upgrade|의존성 고려한 패키지 업그레이드
$ apt search [키워드] | 키워드를 가진 패키지 검색
$ apt show [패키지]|패키지 상세 정보 출력
$ apt list|Repository에 등록된 패키지 목록 조회

**$ apt <span style="color:steelblue">show</span> docker.io**로 도커 패키지 상세 정보 출력  
<img src="img1.png" width="70%" height="70%">
  
**$ apt <span style="color:steelblue">list</span>**로 패키지 목록 조회  
<img src="img2.png" width="70%" height="70%">

### 패키지 업데이트
---
- 패키지 목록: **/var/lib/apt/lists**
- 레파지토리 목록: **/etc/apt/sources.list**

## 압축
- **tar 압축**  
```bash
$ tar -cvf aaa.tar abc
```
	- aaa.tar **<==** abc

- **tar 압축 풀기**  
```bash
$ tar -xvf aaa.tar
```
	- aaa.tar **==>** aaa

- **tar.gz 압축**  
```bash
$ tar -zcvf aaa.tar.gz abc
```
	- aaa.tar.gz **<==** abc

- **tar.gz 압축 풀기**  
```bash
$ tar -zxvf aaa.tar.gz
```
	- aaa.tar.gz **==>** aaa
  
Option|Description
:---:|:---
**-C**|파일 경로 지정
**-p**|파일 권한 저장
**-v**|파일 압축, 압축풀기 때 화면으로 출력
**-f**|파일 이름 지정
**-c**|tar
**-z**|gz
  

## 와일드카드, 정규식
- <span style="color:red">__^__</span>d: <span style="color:red">__시작__</span> 문자가 d
- hello<span style="color:red">__\*__</span>: hello<span style="color:red">__~~~__</span> 뒤엔 상관없는 모든 파일
- <span style="color:red">__[ts]__</span>\*: <span style="color:red">__t 혹은 s__</span>로 시작하는 모든 파일
- <span style="color:red">__[0-9]__</span>\*: <span style="color:red">__0~9__</span>로 시작하는 모든 파일
- <span style="color:red">__[a-zA-Z]__</span>\*: <span style="color:red">__a~z, A~Z__</span>로 시작하는 모든 파일
- <span style="color:red">__[\!a-z]__</span>\*: <span style="color:red">__a~z로 시작 하지 않는__</span> 모든 파일

- __[[:upper:]]\*__: 대문자로 시작하는 모든 파일
- __[![:upper]]\*__: 대문자로 시작하지 않는 모든 파일

- <span style="color:blue">___?___</span>: <span style="color:blue">___앞 문자 있어되고 없어도 되고!___</span>
	- ___books?___: \'s\'가 있어도되고 없어도된다. => book, books

- <span style="color:blue">___.___</span>: <span style="color:blue">___Don't care 1문자___</span>
	- ___book.___: **.** 위치에 한 문자는 와야한다. => books, bookt, ...

- <span style="color:blue">___$___</span>: <span style="color:blue">___문자$ 에서 '문자'로 끝나는 것___</span>
	- ___e$___: xxxxxx**e**

- a<span style="color:red">__{__</span>aa,bc,dd<span style="color:red">__}__</span>: <span style="color:red">**a**</span>aa <span style="color:red">**a**</span>bc <span style="color:red">**a**</span>dd
	- $ mkdir -p dir{1,2,3} => mkdir -p dir1 dir2 dir3

## 특수 파라미터
- __$#__: 파라미터 <span style="color:red">__전체 갯수__</span>
- __$?__: 최근에 종료된 프로세스 return 값
- __$-__: set 내장명령을 통해 또는 쉘 자체에 의해(ex, -i) 설정된 현재 옵션 플래그로 확장한다.
- __$$__: 현재 쉘의 <span style="color:red">__PID__</span>
- __$!__: 가장 최근 실행된 프로세스의 __PID__
- __$0__: 쉘 또는 쉘 스크립트의 이름을 가지고 있다.
- **$\_**:<span style="color:red"> __실행된 쉘 스크립트의 절대 경로__</span>를 가지고 있다.
- $**[**1~9**]**: 1~9번째 아규먼트
- $**{**10~**}**: 10번 째 아규먼트 부터

- ${<span style="color:blue">**#**</span>변수} : 몇 글자?
  
```bash
$ test="That that is is not not"
$ echo ${#test}
23
```
  
- ${변수<span style="color:blue">**:string 시작 idx**</span>} : 시작idx부터 끝까지
  
```bash
	0123456789....       
$ test="That that is is not not"
$ echo ${test:3}
t that is is not not
```
  
- ${변수<span style="color:red">__:string 시작 idx__</span><span style="color:blue">__:몇글자__</span>} : 시작 idx부터 몇 글자
  
```bash
	0123456789....       
$ test="That that is is not not"
$ echo ${test:3:5}
t that
```
  


## shell cmd 
### find
---
- 현재 디렉터리 + **하위 디렉터리** 파일 검색  
```bash
$ find . -name "*STR"
```

- **하위 디렉터리 검색하지 않음**  
```bash
$ find . -maxdepth 1 -name "FILE"
```

- 파일 검색 후 <span style="color:red">**삭제**</span>  
```bash
$ find . -name "FILE" -delete
```

- **파일, 디렉터리**만 검색  
```bash
$ find . -name "FILE" -type f
```

### wc (갯수)
---
- 현재 디렉터리에서 **디렉터리 개수**  
```bash
$ ls -l | grep ^d | wc -l
```

- 현재 디렉터리에서 **파일 개수**  
```bash
$ ls -l | grep ^- | wc -l
```

- 현재 + **하위 디렉터리 recursive** 디렉터리 개수  
```bash
$ ls -Rl | grep ^d | wc -l
```
  
### grep
---

<span style="color:red">**wildcard 사용 말것!**</span>  
ex) grep "<span style="color:red">__\*__</span>STR" (<span style="color:red">**x**</span>), grep "STR" (<span style="color:blue">**o**</span>)
  
 
Option|Description
:---|:---
**-i**|대소문자 무시
**-r**|하위 까지 search
**-v**|패턴 **없는 것**만 출력
<span style="color:red">__e__</span>grep "donald \| trump"| 정규식 사용

- 현재 디렉터리의 **\*.c** 파일에서 **cp** 문자열 찾기
  
```bash
$ grep "cp" ./*.c
```

- 현재 디렉터리 + **"하위 디렉터리"** __\*.c__ 파일에서 __cp__ 문자열 찾기  
  
```bash
$ grep -r "cp" ./*.c
```

### function
---
1. 명령어에 Argument로 커맨드 넣기  
  
```bash
$ function m() { minicom -w -D/dev/ttyS${1}; }
$ function 10	# ${1] <= 10
```

2. Argument로 cp
  
```bash
$ function cpresult() { cp ${1}result.csv ./result${2}.csv; }
```

### echo
---
- <span style="color:blue">__-e__</span>: 개행 문자("\n") 사용케 함 (원래는 안됨)
  
```bash
$ echo -e 'hello \n'
hello


$ echo 'hello \n'
hello \n

```
  
- <span style="color:blue">__-n__</span>: 자동 줄바꿈 하지 않음
  
```bash
user@linux$ echo -n 'hello'
hellouser@linux$
```
 
- <span style="color:blue">__*__</span>: 현재 디렉터리 내용이 ' ' 공백문자를 두고 나옴
  
<img src="img2.png"> 
  
### read
---
- **read**: 사용자로 부터 입력을 받음(스페이스도 받음, 엔터를 만나면 끝냄) ≒ **gets()**
  
```bash
$ read num
34		# num <= 34

$ echo $num
34
```
  
#### $REPLY
---
- **$REPLY**: read 명령어에서 사용하는 **디폴트 변수**<br>read 에서 따로 변수를 안두면 자동으로 저장됨

  
```bash
$ echo "Are  you ready ?"
$ read
y
$ echo $REPLY
y
```

### wc
---
- wc **-c** [파일]: 파일이 몇 Byte인가?
- wc **-m** [파일]: 파일 안에 글자 갯수는?
- wc <span style="color:blue">**-l**</span> [파일]: 파일 내 ***라인 수?***

### 대입, 테스트
---
#### $(), $(())
---
- **Command Substitution**  
<span style="color:red">$(</span>command<span style="color:red">)</span> : 명령 대체  
```bash
$ VAR=$(ipcs | awk '$2==2 ${print $1}')
$ echo=$VAR
```

- **Arithmetic expansion**  
<span style="color:red">$((</span>expression<span style="color:red">))</span> : 산술연산  
```bash
$ i=$(($i+1))
```

#### $(()) $[ ] 계산 대입 vs (()) [] 테스팅
----
  
```bash
# 계산 대입
i=5
i=$(($i+1))
i=$[$i+1]

# 테스팅
  ∨		# 띄워 쓰기!
if ((i<=1))
then
	echo $i
fi
  ∨ ∨ ∨   ∨ ∨	# 띄워 쓰기!
if [ $i -le 1 ]
then
	echo $i
fi
```

#### 문자 비교
---
  
비교 문|Description
:---:|:---
문자1 **`==`** 문자2 | 문자1과 문자2가 **일치** 시, true
문자1 **`!=`** 문자2 | 문자1과 문자2가 **불일치** 시, true
**`-z`** 문자 | 문자 **`== null`** 시, true
**`-n`** 문자 | 문자 **`!= null`** 시, true
   
##### 문자 존재 유무
---- 
  
- **특정 문자 존재 유무**<br> <span style="color:red">**[[ ]]**</span> 반드시 **두 개**사용  
  
```bash
string="abc"

if [[ $string =~ "a" ]]; then
	echo "true"
else
	echo "false"
fi
```
  
```bash
$ echo "Are you eady?"
$ read ; if [[ $REPLY =~ ^[yY]$ ]] ; then echo "true" ; fi
y
true
$
```
- <span style="color:red">**[[ =~ ]]**</span>: 문자열 비교 패턴
- <span style="color:red">**^**</span>: 맨 첫글자 찾기
- <span style="color:red">**$**</span>: 맨 끝 글자
- <span style="color:red">**=~**</span>: 우측에 정규표현식 패턴을 사용
 

#### 수치 비교
---
  
비교 문|Description|뜻
:---:|:---|:---
값1 <span style="color:magenta">**-eq**</span> 값2|값1 <span style="color:blue">**==**</span> 값2|<span style="color:red">__eq__</span>ual
값1 <span style="color:magenta">**-ne**</span> 값2|값1 <span style="color:blue">**!=**</span> 값2|<span style="color:red">__n__</span>ot <span style="color:red">__e__</span>qual
값1 <span style="color:magenta">**-lt**</span> 값2|값1 <span style="color:blue">**<**</span> 값2|<span style="color:red">__l__</span>ess <span style="color:red">__t__</span>han
값1 <span style="color:magenta">**-le**</span> 값2|값1 <span style="color:blue">**<=**</span> 값2|<span style="color:red">__l__</span>ess <span style="color:red">__e__</span>qual
값1 <span style="color:magenta">**-gt**</span> 값2|값1 <span style="color:blue">**>**</span> 값2|<span style="color:red">__g__</span>reater <span style="color:red">__t__</span>han
값1 <span style="color:magenta">**-ge**</span> 값2|값1 <span style="color:blue">**>=**</span> 값2|<span style="color:red">__g__</span>reater <span style="color:red">__e__</span>qual
  
#### 논리 연산
---
  
옵션|Description
:---:|:---
조건1 <span style="color:blue">**-a**</span> 조건2|<span style="color:magenta">**AND**</span>
조건1 <span style="color:blue">**-o**</span> 조건2|<span style="color:magenta">**OR**</span>
조건1 <span style="color:blue">**&&**</span> 조건2| <span style="color:magenta">**양쪽 다 성립**</span>
조건1 <span style="color:blue">**\|\|**</span> 조건2| <span style="color:magenta">**한쪽 또는 양쪽 다 성립**</span>
<span style="color:blue">**!**</span>조건|<span style="color:magenta">**조건이 성립하지 않음**</span>
<span style="color:blue">**true**</span>|<span style="color:magenta">**조건이 언제나 성립**</span>
<span style="color:blue">**false**</span>|<span style="color:magenta">**조건이 언제나 성립하지 않음**</span>


#### 파일 검사
---
   
```bash
$ if [ -f hi ]	# hi가 파일이면 true
```

옵션|Description
:---:|:---
<span style="color:blue">**-e**</span> 파일명|파일이 <span style="color:magenta">**존재 시**</span> 참
<span style="color:blue">**-d**</span> 파일명|파일이 <span style="color:magenta">**디렉터리**</span>면 참
<span style="color:blue">**-h**</span> 파일명|파일이 <span style="color:magenta">**심볼릭 링크**</span> 파일
<span style="color:blue">**-f**</span> 파일명|파일이 <span style="color:magenta">**일반 파일**</span>이면 참
<span style="color:blue">**-r**</span> 파일명|파일이 <span style="color:magenta">**읽기 가능**</span>이면 참
<span style="color:blue">**-w**</span> 파일명|파일이 <span style="color:magenta">**쓰기 가능**</span>이면 참
<span style="color:blue">**-x**</span> 파일명|파일이 <span style="color:magenta">**실행 가능**</span>이면 참
<span style="color:blue">**-s**</span> 파일명|파일의 <span style="color:magenta">**크기가 0이 아니면**</span> 참
<span style="color:blue">**-u**</span> 파일명|파일의 <span style="color:magenta">**set-user-id가 설정**</span>되면 참
  

### ( ) : sub shell group
---
- **내부 명령이 <span style="color:red">서브 쉘</span>에서 실행**되는 경우  
```bash
$ u2dos() ( set -f; IFS=''; printf '%s\r\n' $(cat "$1") )
```

### { } : inline group
---
- **중괄호 안**의 명령은 마치 **하나의 명령처럼** 취급된다.  
```bash
$ { local v1; v1=123; }
```

### 배열
---
  
- **배열 선언 및 참조하기**
  
```bash
#!/binb/ash
arr=(1 2 3 4 5 6 7 8 9 10 15 20 25 30)

echo "${arr[0]}"	# 배열 idx 0번 참조
echo "${arr[*]}"	# 배열 전부 출력
echo "${arr[@]}"	# 배열 전부 출력
echo "${!arr[@]}"	# 배열 인덱스 넘버 전부 출력
echo "${#arr[@]}"	# 배열 size
echo "${#arr[0]}"	# 배열 특정 인덱스 사이즈
```
  
<img src="img3.png" width="50%" height="50%">
  
- **배열 for文**
  
```bash
#!/bin/bash
arr=(1 2 3 4 5 6 7 8 9 10 15 20 25 30)

for (( i=0 ; i < ${#arr[@]} ; i++ )) ; do
	echo "${arr[$i]}" # 배열 사이즈
done
```
  
1  
2  
3  
.. 쭉 echo
  
```bash
#!/bin/bash
classrom=(desk pen note chair book)

echo ${classroom[@]}
echo ${#classroom[@]}

for i in #{classroom[@]}; do
	echo $i
done
```
  
<img src="img4.png" width="30%" height="30%">
  
### 연산자(expr)
---
- 역할: 숫자 계산<br>사용하는 경우 <span style="color:red">__`__</span> 를 사용해야한다. 연산자 <span style="color:red">__\*__</span>와 괄호 <span style="color:red">**( )**</span> 앞에는 역 슬래시<span style="color:red">__\\__</span>와 사용
- **연산자, 숫자, 변수, 기호** 사이에는 <span style="color:red">**space**</span>를 넣어야 함
  
```bash
num=`expr \( 3 \* 5 \) / 4 + 7`
echo $num
10
```
  
### if 文
---
- **if**
  
```bash 
if [ 조 건 ]
then
	명 령
fi

if [ 조 건 ]; then 명 령 ; fi
```
  
- **if else**
  
```bash
if [ 조 건 ]
then
	명 령 
else
	명 령
fi

if [ 조 건 ]; then 명 령; else 명 령; fi
```
  
- <span style="color:red">**if elif**</span>
  

```bash
if [ 조 건 ]
then
	명 령
elif [ 조 건 ]
then
	명 령
fi

if [ 조 건 ]; then 명 령; elif [ 조 건]; then 명 령; fi
```
  

### while 文
---
  
```bash
i=1

while [ $i -lt 5 ]
do
	echo $i
	i=$(($i+1))
done

i=1; while [ $i -lt 5 ] ; do echo $i; i=$(($i+1)) ; done
```

### for 文
---
  
```bash
for (( i = 0; i < 10 ; i++ ))
do
	명 령
done

for (( i = 0; i < 10 ; i++ )); do 명 령 ; done
```


  

## Network
### port
---
- 현재 시스템의 포트 할당 확인  
```bash
$ lsof -i -P -n | grep -i listen
```
<img src="img1.png">

## 시스템
### 우선순위
---
- 스케줄링 우선순위  
```bash
$ nice [-n 조정수치] [cmd [arg..]]
```
  
Option|Description
:---|:---
無 옵션| nice는 상속받은 현재의 스케줄링 우선권을 출력한다
-n [조정수치]| - 조정수치 생략 시, **nice = 10**<br> - **su 권한 시, nice = 음수 가능**<br> - 우선순위: **-20 (<span style="color:red">高 priority ↑↑↑</span>) ~ 19 (<span style="color:blue">低 priority ↓↓↓</span>)**
  
### 마운트
---
- 마운트  
```bash
$ mount [-fnrvw] [-t 파일시스템 유형] [-o 옵션] 장치명 디렉터리명
ex) $ mount -t vfat /dev/sdb1 /mnt/usb
```

- 언마운트  
```bash
$ unmount 장치명 디렉터리명
```
  
## 환경변수
### 환경변수 미리 지정된 변수
---
  
```bash
$ echo $HOME
/home/pllpokko
```  
  
ENV|Description
:---|:---
**HOME**|사용자의 홈 디렉터리
**PATH**|실행파일을 찾는 경로
**LANG**|프로그램 사용 시 기본 지원되는 언어
**PWD**|사용자의 현재 작업하는 디렉터리
**TERM**|로그인 터미널 타입
**SHELL**|로그인해서 사용하는 쉘
**USER**|사용자의 이름
**DISPLAY**|X 디스플레이 이름
**VISUAL**|visual 편집기의 이름
**EDITOR**|기본 편집기의 이름
**COLUMNS**|현재 터미널이나 윈도우 터미널의 컴럼 수
**PS1**|명령 프롬프트 변수
**PS2**|2차 명령 프롬프트. 명령 행에서 사용하여 명령 행을 연장 햇을 때 나타냄
**BASH**|사용하는 bash 쉘의 경로
**BASH_VERSION**|bash의 버전
**HISTFILE**|history 파일의 경로
**HISTFILESIZE**|history 파일의 크기
**HISTSIZE**|history에 저장되는 갯수
**HISTCONTROL**|중복되어지는 명령에 대한 기록 유무를 지정하는 변수
**HOSTNAME**|호스트의 이름
**LINES**|터미널의 라인 수
**LOGNAME**|로그인 이름
**LS_COLORS**| ls 명령의 색상 관련 옵션
**MAIL**|메일을 보관하는 경로
**MAILCHECK**|메일 확인 시간
**OSTYPE**|운영체제 타입
**SHLVL**|쉘의 레벨
**TERM**|터미널 종류
**UID**|사용자의 UID
**USERNAME**|사용자 이름
  

### which/whereis
---
- **which**: ***PATH 경로내*** 실행 파일 검색
- **whereis**: ***실행 파일, 소스, 맨페이지 위치***
  
```bash
$ which bash
/bin/bash
$ whereis bash
bash: /bin/bash /etc/bash.bashrc /usr/share/man/man1/bash.1.gz
```
  
## vim
### 문자열 찾기
---
- 검색 문자열 뒤에 **\c**
  
```bash
# vim
/findstr\c
```
  
