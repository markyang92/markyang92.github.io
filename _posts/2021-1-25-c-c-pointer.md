---
#```
#<span style="color:magenta">
#<span style="color:steelblue">
#<span style="color:firebrick">
#<img src="img" width="%" height="%">
title: "aliasing restrict pointer"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- c
---
## 에일리어싱과 restrict 포인터
- **에일리어싱**: 어떤 **한 공간**에 대해 **복수 개**의 **접근 경로**가 있는 **경우를 의미**한다.  
	- **\*P**: <span style="color:blue">**포인터 P**</span>가 있고 그 **객체가 100**이라는 길이를 가진다고 가정한다.  
		- <span style="color:red">**P+1**</span> **=** <span style="color:blue">**Q**</span>라고 지칭한다면 이를 <span style="color:steelblue">**에일리어싱**</span> 되었다고 합니다.  
<img src="img1.png" width="50%">
	- **형변환(type casting)**을 위한 **최적화를 방해**하거나 **문제를 일으킬 소지**도 있습니다.  
		- <span style="color:magenta">*인수*</span>로 **받아들이는 주소**가 <span style="color:magenta">***에일리어싱***</span> 되었을 때 **오류**를 방지 위해 **미리 검사**하는 행위 때문에 <span style="color:blue">**성능 저하**</span>가 발생
		- <span style="color:magenta">***int***</span> <span style="color:blue">***\*i_form***</span> 은 **int형 변수를 에일리어싱하는 변수**
<br><br>
- **함수 인수**가 **다른 곳**에서 **참조하지 않음**을 <span style="color:red">**보장**</span>해주다면 <sub>1.</sub><U>내부적으로 병렬처리</U>하거나 <sub>2.</sub><U>에일리어싱에 대한 검사를 하지 않아</U>도 되므로 **상당히 효율적**으로 함수를 설계할 수 있다.

## restrict 포인터
- <span style="color:magenta">***restrict 포인터***</span>: **최적화**, **신뢰성 있는 코드**를 위해..
	- API가 최적화나 신뢰성을 높이기 위해 **독점적**으로 **인수**로 **넘어오는 메모리에 접근**해야 할 필요성
  
```c
"과거 memcpy"
void *memcpy(void *dest, const void *src, size_t n);

"C99 이후 memcpy"
void *memcpy(void *restrict s1, const void *restrict s2, size_t n);
```
- <span style="color:magenta">***restrict***</span> 포인터로 **객체**를 다른 공간에서 **에일리어싱**하지 않도록 강제함
	- implementation이 **내부적**으로 ***s1***, ***s2*** 의 접근이 **비순차**, **비동기적**으로 **진행**, **병렬**처리 될 수 있음 암시
	- **과거** <span style="color:magenta">*memcpy*</span>는 <span style="color:red">**비동기적 진행** **X**</span>, 일일이 메모리 위치를 확인하는 작업도 한다. 이는 **심각한 오버헤드 유발**
<br><br>
- 에일리어싱을 사용하지 않음을 확신할 수 없다면, memcpy대신 **memmove**를 사용하도록 강요
  
```c
int *p_num, *p_alias;
p_num = (int *)malloc(sizeof(int) * 100);
p_alias = p_num + 20; /* 에일리어싱 되었음 */ 
memcpy(p_num, p_alias, sizeof(int) * 50);
```
- ***p_num***, ***p_alias***는 **에일리어싱** 되었으므로 <span style="color:magenta">***restrict***</span> <span style="color:navy">**포인터 룰** **위반**, <span style="color:red">**사이드 이펙트 발생 가능성**
