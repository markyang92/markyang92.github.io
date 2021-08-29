---
#<span style="color:magenta">
#<span style="color:steelblue">
#<img src="img" width="%" height="%">
title: "가변 인자"
excerpt: "가변 인자"
comments: true
toc: true
toc_sticky: true
category:
- c
---
## 가변 인자 사용하기
- 함수에서 가변 인자를 정의
	- **고정 매개변수**가 <span style="color:steelblue">**한 개**</span> 이상
		- <span style="color:red">**가변 인수 몇 개**</span>인지 지정해야함...
	- 고정 매개변수 뒤 \' **...** \'를 붙여 매개변수의 개수가 정해지지 않았다는 표시 해줌
	- <span style="color:red">**주의!**</span> \'...\' **뒤**에는 <U>다른 매개변수를 지정할 수 없음</U>
  
- **foo(4, 10, 20, 30, 40);** 사용 <br>***foo(<span style="color:magenta">int args</span>, ...)***선언 이면<br>　　　***<span style="color:magenta">args</span>*** = **4** 들어가고 **<span style="color:steelblue">나머지 값</span>**들은 **...** 부분에 들어간다.


  
```c
#include <stdio.h>
#include <stdarg.h>

void printNumbers(int dummy, int args, ...){
	va_list ap;					// 가변인자 담을 포인터

	va_start(ap, args);				// 포인터와 가변인자 갯수 지정
	printf("<dummy: %d> ",dummy);
	printf("Num of variables: %d [ ", args);
	for(int i=0; i<args; i++)	{
		int num=va_arg(ap, int);		// 포인터와 자료형크기를 넣어서 순방향 이동
		printf("%d ", num);
	}
	va_end(ap);					// 가변인자 포인터 NULL
	printf("]\n");
}

int main(){
	printNumbers(0, 1, 10);
	printNumbers(0, 2, 10, 20);
	printNumbers(0, 3, 10, 20, 30);
	printNumbers(0, 4, 10, 20, 30, 40);

	return 0;
}
```
<img src="img3.png" width="60%" height="60%">
 
- <span style="color:magenta">***va_list***</span>: 가변 인자 **목록** <span style="color:magenta">**포인터**</span>
- <span style="color:magenta">***va_start***</span> **(포인터, 갯수)**: 가변 인자 포인터 설정

<img src="img1.png" width="70%" height="70%">
  
- <span style="color:magenta">***va_arg***</span> **(포인터, 자료형)**: 가변 인자 포인터에서 <U>'자료형' 크기</U>만큼 **하나의 인덱스 데이터**가져옴.<br><br>　　　　　　　　　　　<span style="color:red">**순방향 이동!!**</span>
  
<img src="img2.png" width="70%" height="70%">
- <span style="color:magenta">***va_end***</span> **(포인터)**: 가변 인자 처리 끝난 후, 지정한 **포인터**를 <span style="color:steelblue">**NULL**</span>로 만듬

### 자료형이 다른 가변 인자 함수
---
- 자료형이 다르면 `switch`文을 사용하자.  
<img src="img4.png" width="40%" height="40%">  
- **고정 변수**에, <span style="color:green">**switch**</span>에서 <span style="color:magenta">***case***</span>로 구분할 <span style="color:green">**문자열**</span> 보냄


```c
#include <stdio.h>
#include <stdarg.h>    // va_list, va_start, va_arg, va_end가 정의된 헤더 파일

void printValues(char *types, ...)    // 가변 인자의 자료형을 받음, ...로 가변 인자 설정
{
    va_list ap;    // 가변 인자 목록
    int i = 0;

    va_start(ap, types);        // types 문자열에서 문자 개수를 구해서 가변 인자 포인터 설정
    while (types[i] != '\0')    // 가변 인자 자료형이 없을 때까지 반복
    {
        switch (types[i])       // 가변 인자 자료형으로 분기
        {
        case 'i':                                // int형일 때
            printf("%d ", va_arg(ap, int));      // int 크기만큼 값을 가져옴
                                                 // ap를 int 크기만큼 순방향으로 이동
            break;
        case 'd':                                // double형일 때
            printf("%f ", va_arg(ap, double));   // double 크기만큼 값을 가져옴
                                                 // ap를 double 크기만큼 순방향으로 이동
            break;
        case 'c':                                // char형 문자일 때
            printf("%c ", va_arg(ap, int));      // char 크기만큼 값을 가져옴
                                                 // ap를 char 크기만큼 순방향으로 이동
            break;
        case 's':                                // char *형 문자열일 때
            printf("%s ", va_arg(ap, char*));    // char * 크기만큼 값을 가져옴
                                                 // ap를 char * 크기만큼 순방향으로 이동
            break;
        default:
            break;
        }
        i++;
    }
    va_end(ap);    // 가변 인자 포인터를 NULL로 초기화

    printf("\n");    // 줄바꿈
}

int main()
{
    printValues("i", 10);                                       // 정수
    printValues("ci", 'a', 10);                                 // 문자, 정수
    printValues("dci", 1.234567, 'a', 10);                      // 실수, 문자, 정수
    printValues("sicd", "Hello, world!", 10, 'a', 1.234567);    // 문자열, 정수, 문자, 실수

    return 0;
}
```

<span style="color:red">**주의!!**</span>: **gcc**에서는!!
  
<span style="color:magenta">***va_arg***</span>**(**<span style="color:magenta">**ap**</span>, <span style="color:orange">**자료형**</span>);
- _char_,_bool_ -> _int_
- _short_ -> _int_
- _float_ -> _double_

### vfprintf():3 사용하기
---
- **switch**는 너무 귀찮다면 <span style="color:magenta">***vfprintf()***</span> 사용하자!
