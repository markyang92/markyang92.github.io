---
#```
title: "Yocto <1>"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- yocto
---
## Yocto?
- 임베디드 개발자는 환경세팅 매우 힘들다.
	- arch, OS, What boot-loader?, compiler...
  
- Yocto는 불필요한 삽질을 사전에 방지해주는 <span style="color:magenta">**형상관리 툴**</span>
- **Yocto**는 여러 개의 작업을 `하나의 작업 경로 내`에서 **모두 처리 할 수 있는** `간편 빌드 시스템`
	- ex: 개발자가 보드에 부트로드, OS(Linux 3.18, Linux 4.1 각각 따로) 그리고 시스템 이미지를 만드는 작업환경을 구축한다면..<br>부트 로더, 리눅스 소스 코드, 시스템 이미지를 각각 **git**에서 받아오고 각각의 빌드 스크립트를 작성한 후 **각각의 폴더에서** 이미지 파일을 추출해내는 형태 일 것이다.  
	<img src="img1.png">
  
- 하지만 <span style="color:steelblue">**yocto**</span>는 위 모든 것을 **하나의 경로**내에서 해결할 수 있도록 구현한다.


