---
#    
#```c
# <span style="color:steelblue">
title: "시험에서 입출력, STL"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- algorithm
---
## scanf(), printf()

### 특정 자료형 거르기
---
<span style="color:red">
<img src="img1.jpg">

### 특정 갯수만큼만 받기
---

```c
scanf("%1d", &a);
```
- **%**<span style="color:red">**1**</span>**d** 와 같이 중간에 숫자를 넣은 만큼 입력을 받는다.
	- 12345 입력 시, 1 2 3 4 5 따로 받을 수 있다.


```c
scanf("%5s", str);
```
- **%**<span style="color:red">**5**</span>**s** 와 같이 <span style="color:navy">**string**</span>도 중간에 숫자를 넣은 만큼 입력을 받는다.
	- <span style="color:green">"hello world"</span> >> "%<span style="color:red">**3**</span>s" >> <span style="color:green">"hel"</span>


### scanf 로 끝까지 받기
---
- **scanf**의 **리턴 값**은 **성공적으로** <span style="color:red">**입력 받은 인자 개수**</span>이다.
- **파일의** <span style="color:red">**끝**</span>까지 받아야 하는 경우 
```c
while( scanf("%d %d", &a, &b) == 2);
```


## 한줄 입력

- ***scanf(), cin >>***으로는 <span style="color:red">**한 줄**</span>입력 불가!

```c
fgets(s, 100, stdin);	"fgets()는 줄 바꿈까지 입력 받음!! 주의!!"
getline(cin, s);
```



