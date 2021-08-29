---
#```
title: "Samba 셋팅"
excerpt: ""
comments: true
toc: true
toc_sticky: true
category:
- linux-system
---
## samba
1. Host: Mac OS
2. Remote: Ubuntu 20.04 LTS

## samba install
### samba install(Remote)
--- 
```bash
$ sudo apt install samba
```
- 삼바 계정을 추가하고, 계정에서 접근 가능한 디렉터리를 정한다.
  
```
$ sudo useradd -d [share directory] -m [삼바 계정]
$ sudo useradd -d /home/pllpokko/share -m share_pllpokko
```

- 삼바 계정의 패스워드를 정한다.
  
```bash
$ sudo passwd [삼바 계정]
$ sudo passwd share_pllpokko
```

- 삼바 공유 폴더에 접근할 아이디와 비밀번호를 설정
  
```bash
$ sudo smbpasswd -a [삼바 계정]
$ sudo smbpasswd -a share_pllpokko
```
  
<img src="img2.jpeg">
  
- 삼바 공유용 디렉터리 **권한**지정
  
<img src="img3.png">

### samba configure 파일 설정
---
  
- 삼바서버 설정을 위한 `/etc/samba/smb.conf` 파일 수정
  
```bash
$ sudo vi /etc/samba/smb.conf

# smb.conf ----아래 맨 마지막 줄에 추가 -------------
[삼바 계정]
 comment = samba directory
 path = /home/pllpokko/share
 writeable = yes
 valid users = pllpokko
-------------------저장 후 종료----------------------
```

<img src="img1.jpeg">
  
```bash
$ sudo /etc/init.d/smbd restart
```



- ip 얻기
  
```bash
$ ifconfig
# eth0의 ip 구하기
```

### host side
---
1. finder -> Command + K -> 서버 주소에 `smb://[ip]` 입력

