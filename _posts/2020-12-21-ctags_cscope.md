---
title: "ctags, cscope"
excerpt: "ctags, cscope"
comments: true
toc: true
toc_sticky: true
category:
- linux-tools
---
## ctags
>   Ctags is a programming tool that generates an index (or tag) file of names found in source and header files of various programming languages to aid code comprehension.<br>  The original Ctags was introduced in BSD Unix 3.0 and was written by Ken Arnold<br>  from Wiki

- 아래 커맨드를 입력시 tags가 만들어 진다.  
```bash
$ ctags -R
```

- vim과 연동해야 vim에서 먹힌다.  
```bash
# vim을 열고...!
:set tags=[tags file 위치]
```
- vim을 열때마다 이럴 순 없지 않은가..! 자동 연동 설정하자!  
```bash
$ vim ~/.vimrc	# vim 설정 파일 진입
$ set tags=./tags
```  
	- 설정을 보면 알겠지만, `./tags`가 먹히는 위치에서 vim을 켜야 자동 연동

### ctags 커맨드
---
- `ctrl + ]`:
- `ctrl + t`:

## cscope
- ctags만으로는 local, global variable이 사용된 곳이나, 함수가 사용된 곳 찾기 힘들다.

1. **cscope.out** 파일을 만들어야 한다.
  
```bash
$ find ./ -name "*.[csSh]" > file_list
$ find ./ -name "*.cpp" >> file_list
$ find ./ -name "*.cc" >> file_list

$ cscope -i file_list
ctrl + d
```
  
- 커맨드를 보면 알겠지만, 현재 폴더에서 .c, .s, .S, .h, .cpp, .cc 파일을 찾아서 file_list에 넣는다.
- cscope -i file_list는 file_list내에 파일을 cscope가 한 줄씩 읽어서 cscope.out 파일 생성한다.

그런데 이거 매번 하기 귀찮으니 쉘로 만들고 어디에서나 사용가능하게 /usr/local/bin에 넣자
### mkcscope.sh
---
`mkcscope.sh`
  
```bash
#!/bin/bash
rm -rf cscope.files file_list
find ./ -name "*.[csSh]" > file_list
find ./ -name "*.cpp" >> file_list
find ./ -name "*.cc" >> file_list

cscope -i file_list
```
```bash
$ chmod +x mkcscope.sh
$ sudo mv ./mkcscope.sh /usr/local/bin
```

어디서든 `mkcscope.sh` 실행 시, 내 현재 위치에 cscope.out을 만들어 준다.

### vim연동
---
```bash
set csprg=/usr/local/bin/cscope
set nocsverb

if filereadable("./cscope.out")
cs add cscope.out
else
cs add /usr/local/bin/cscope.out
endif

set csverb
set csto=0
set cst
```
  
### cscope 커맨드
---
```bash
# vim에서
:cs f [질의 종류] [심볼]
:cs f s start_kernel		# 예
```
  
search type|number|Description
:---:|:---:|:---
s|0|C 심볼을 검색<br>변수, 함수, 매크로, 구조체 등
g|1|전역 선언, 정의 검색
d|2|함수에 의해 호출되는 함수들 검색<br>cs f 2 **get_src** ==> **get_src함수가 Call**하는 함수들 나열<br>get_src==> main, others
c|3|함수를 호출하는 함수들 검색<br>cs f 3 get_src ==> **get_src를 호출**하는 함수들 나열<br>main, others ==> get_src
t|4|텍스트 문자열 검색
e|5|확장 정규식을 사용해 검색
f|6|파일 이름을 검색
i|7|파일을 인클루드하는 파일 검사

- `space bar`: 내리기
- `q`: 나가기

