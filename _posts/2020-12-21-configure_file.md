---
title: "configure 파일 셋팅 - Cross compile용"
excerpt: "Cross Compile위한 configure 파일 셋팅 법"
comments: true
toc: true
toc_sticky: true
category:
- linux-compile
---
## Keyward
- **build**, **host**, **target**은 [여기](https://pllpokko2.github.io/linux-compile/cross_compile/#build-host-target)참고

### Toolchain program
---
  
명령|설명
:---:|:---
addr2line|실행 파일 안의 디버그 심볼을 읽어서 프로그램 주소를 파일 이름과 행 번호로 변환한다.<br>시스템 크래시 리포트에 출력된 주소를 해독할 때 매우 유용하다.
**ar**|아카이브 유틸리티<br><span style="color:red">**static 라이브러리를 만들 때**</span>쓰인다.
**as**|GNU <span style="color:red">**어셈블러**</span>
c++filt|C++와 자바 심볼을 복원(demangle)할 때 쓰인다.
**cpp**|C 전처리기, #define #include 등의 지시자를 확장할 때 쓰인다.
**ld**|GNU <span style="color:red">**링커**</span>
**nm**|**오브젝트 파일의 심볼 나열**
**strip**|오브젝트 파일의 **디버그 심볼 테이블을 없애 <span style="color:red">파일 크기를 줄여준다.</span>**<br>흔히 <span style="color:blue">**타깃에 복사할 모든 실행 코드에 적용한다.**</span>
elfedit|ELF 파일의 ELF 헤더를 업데이트할 때 쓰인다.
g++|GNU C++
gcc|GNU C
gconv|코드 커버리지 도구
gdb|GNU 디버거
gprof|프로그램 프로파일링 도구
objcopy|오브젝트 파일 복사 및 번역
objdump|오브젝트 파일 정보 출력시 사용
ranlib|static 라이브러리 안의 인덱스를 만들거나 수정해 링크 단계를 더 빠르게 한다.
readelf|ELF 오브젝트 형식의 파일에 정보를 출력한다.
size|섹션 크기와 전체 크기를 나열한다.
strings|파일 안의 인쇄 가능 문자열들을 출력한다.
    

### 설치 디렉터리
---
- **\--prefix=_PREFIX_**<br>아키텍처에 독립적인 파일을 _PREFIX_에 설치한다.<br>기본 값은 `/usr/local/`에 **bin, include, lib**이 설치된다.<br>ex) \--prefix=$HOME => $HOME/bin $HOME/lib 등에 파일을 설치한다.

### 시스템 configure
---
- **\--build=_BUILD_**<br>도구를 컴파일하는 시스템의 종류를 지정한다.
- **\--host=_HOST_**<br>서버를 실행할 시스템의 종류를 지정한다. 기본 값은 _BUILD_
- **\--target=_TARGET_**<br> *TARGET*시스템 종류를 위한 컴파일러를 만들 떄 사용한다. 기본 값은 *HOST*이다.

### toolchain options
---
- **\--arch=_ARCH_**<br>아키텍처 선택
- **\--cpu=_CPU_**<br>CPU 선택
- **\--cross-prefix=_PREFIX_**<br>*PREFIX*를 compilation tools로 사용
- **\--enable-cross-compile**<br>크로스 컴파일러가 사용 됨을 가정함
- **\--sysroot=_PATH_**<br>cross-build tree의 root
- **\--target-os=_OS_**<br>target OS compiler
- **\--target-path=_DIR_**<br>target의 build 디렉터리의 view 로 지정할 path
- **\--toolchain=_NAME_**<br>*NAME*에 해당하는 디폴트 툴 세팅<br>(gcc-asan, clang-asan, gcc-msan, clang-msan, gcc-tsan, clang-tsan, gcc-usan, clang-usan, valgrind-massif, valgrind-memcheck, msvc, icl, gcov, llvm-cov, hardened)
- **\--cc=_CC_**<br>C 컴파일러 _CC_ 사용 **ex) \--cc=gcc**
- **\--cxx=_CXX_**<br>C++ 컴파일러 _CXX_ 사용 **ex) \--cxx=g++**
- **\--nm=_NM_**<br>_NM_으로 지정한 툴 사용 **ex) \--nm="nm -g"**
- **\--ar=_AR_**<br>아카이브 툴 _AR_ 사용 **ex) \--ar=ar**
- **\--as=_AS_**<br>어셈블러 _AS_ 사용
- **\--strip=_STRIP_**<br>strip tool _STRIP_ 사용 **ex) \--strip=strip**
- **\--ld=_LD_**<br>링커 _LD_ 사용 **ex) \--ld=LD** 
- **\--pkg-config=_PKGCONFIG_**<br>pkg-config 지정 **ex) \--pkg-config=/usr/lib/pkg-config**
- **\--pkg-config-flags=_FLAGS_**<br>pkgconf에 추가적인 flags 전달
- **\--ranlib=_RANLIB_** ranlib _RANLIB_ 사용
- **\--extra-cflags=_CFLAGS_** CFLAGS 전달 **ex)--extra-cflags="-O2 -DDEBUG"**
- **\--extra-cxxflags=_CXXFLAGS** CXXFLAGS 전달
- **\--extra-ldflags=_LDFLAGS_** LDFLAGS 전달
- **\--extra-libs=_LIBS_** LIBS 전달


## configure tool 사용 예
### ex 1
---
```bash
$ export CC=arm-cortex_a8-linux-gnueabihf-gcc \
./configure --host=arm-cortex_a8-linux-gnueabihf --prefix=/usr --cc=$CC
```
- 결과 `Makefile 생성`
  
```bash
$ make
``` 
- 소스 코드 컴파일 결과(**make의 결과**)는 현재 디렉터리에 생성됨
	- $PWD/usr/bin, $PWD/usr/lib ..
  
```bash
$ make DESTDIR=$(arm-cortex_a8-linux-gnueabihf-gcc -print-sysroot) install
```
- **sysroot 명시 경우** **`sysroot/[_PREFIX_]`** 위치로 옮겨짐
	- **sysroot/usr/bin, sysroot/usr/lib ...**
- prefix 명시하지 않으면 **'/'** 루트 이하에 install됨
### ex2
---
  
```bash
$ export CROSS_COMPILE=/opt/starfish-sdk-x86_64/5.0.0-20190307/sysroots/x86_64-starfishsdk-linux/usr/bin/arm-starfishmllib32-linux-gnueabi
$ export TARGET_ABI=armeabi-v7a
$ export HOST=arm-starfishmllib32-linux-gnueabi
$ export AR=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-ar
$ export AS=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-as
$ export CC=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-gcc
$ export CXX=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-g++
$ export CPP=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-cpp
$ export LD=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-ld
$ export NM=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-nm
$ export STRIP=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-strip
$ export OBJCOPY=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-objcopy
$ export OBJDUMP=$CROSS_COMPILE/arm-starfishmllib32-linux-gnueabi-objdump
$ export SYSROOT=/opt/starfish-sdk-x86_64/5.0.0-20190307/sysroots/ca9v1-starfishmllib32-linux-gnueabi \
./configure \
--enable-cross-compile \
--cc=$CC --cxx=$CXX --strip=$STRIP --nm=$NM --ld=$LD --target-os=linux \
--sysroot=$SYSROOT --prefix=/usr --arch=armv7-a --cpu=cortex-a9 \
--extra-ldflags='-lt -lpthread -lm -pipe'

$ make
```
