---
#    
#```c
# <span style="color:steelblue">
title: "Time complexity"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- algorithm
---
## Time Complexity
- **O(1)**: 단순 계산(a+b, 배열 접근 연산)
- **O(logN)**: N개를 **절반**으로 계속 나눔
- **O(N)**: 1중 for문
- **O(NlogN)**
- **O(N<sup>2</sup>)**: 2중 for문
- **O(N<sup>3</sup>)**: 3중 for문
- **O(2<sup>N</sup>)**: 크기가 N인 집합의 부분 집합
- **O(N!)**: 크기가 N인 순열
  
<br>
**대략 1억 = 1초**(2000*s* 컴)
<br>
  
**1 초**가 걸리는 **입력의 크기**
- ~~**O(1)**~~
- ~~**O(logN)**~~
- **O(N)** = <span style="color:red">**1억**</span>
- **O(NlogN)** = <span style="color:magenta">**5백만**</span>
- **O(N<sup>2</sup>)** = <span style="color:steelblue">**1만**</span>
- **O(N<sup>3</sup>)** = <span style="color:navy">**500**</span>
- **O(2<sup>N</sup>)** = <span style="color:firebrick">**20**</span> (2<sup>20</sup> = 1048576)
- **O(N!)** = <span style="color:red">**10**</span> (10! 단 10개만 넣어도.. 1초)  
<img src="img1.jpeg" width="50%">

