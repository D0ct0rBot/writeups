https://github.github.com/gfm

#
Realizamos un escaneo en la red:
```bash
> sudo arp-scan -I eth0 --localnet
```
![sudo arp-scan -I eth0 --localnet](arp-scan.png)

---
Vemos que hay una máquina VMWare con ip 192.168.1.25
Comprobamos que la máquina esté activa:
```bash
> ping -c 1 192.168.1.25
```
```bash
PING 192.168.1.25 (192.168.1.25) 56(84) bytes of data.
64 bytes from 192.168.1.25: icmp_seq=1 ttl=64 time=3.08 ms

--- 192.168.1.25 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.076/3.076/3.076/0.000 ms
```
---
Ahora, realizamos un escaneo simple de puertos:
```bash
> sudo nmap -sS -p1-1000 -Pn 192.168.1.25
```
 
```bash
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-15 13:51 EST
Nmap scan report for ubuntu.home (192.168.1.25)
Host is up (0.0086s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
80/tcp open  http
MAC Address: 00:0C:29:01:03:D9 (VMware)

Nmap done: 1 IP address (1 host up) scanned in 0.62 seconds
```
Inicialmente, parece haber un puerto abierto: el 80.
---

Miramos que version de servidor http se está utilizando:
```bash
> sudo nmap -sV -p 80 -n -Pn 192.168.1.25 
```

```bash
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-15 13:53 EST
Nmap scan report for 192.168.1.25
Host is up (0.0018s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    nginx 1.10.3 (Ubuntu)
MAC Address: 00:0C:29:01:03:D9 (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 8.48 seconds
```
---
Ahora intentamos mirar qué posible sistema operativo está corriendo dicho servicio, haciendo una búsqueda em google con las siguientes palabras clave:
nginx 1.10.3 Launchpad y allí nos aparecerá lo más probable la versión del SO sobre el que corre el servicio.

Al parecer está corriendo sobre Ubuntu xenial.

-------------------------------------------------------------------------
Miramos qué tecnologías web están corriendo sobre ese servidor:

```bash
> whatweb 192.168.1.25
```
```bash
http://192.168.1.25 [200 OK] Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][nginx/1.10.3 (Ubuntu)], IP[192.168.1.25], Title[Welcome to nginx!], nginx[1.10.3]
---
Y ahora miramos la página principal:
![whatweb](2023-01-16_15-45.png)

---
Como no hay nada, buscaremos directorios ocultos posibles:</p><p></p><p>wfuzz -c --hc 404 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.1.25/FUZZ&nbsp;</p><p></p><pre> 000000009:   200        25 L     69 W       612 Ch      &quot;# Suite 300, San Franci
                                                        sco, California, 94105, 
                                                        USA.&quot;                   
 000000587:   301        7 L      13 W       194 Ch      &quot;wordpress&quot;             
 000045240:   200        25 L     69 W       612 Ch      &quot;http://192.168.1.25/&quot;  </pre><p></p><p>Podemos ver que hay un directorio wordpress</p><p></p><p>-------------------------------------------------------------------------</p><p></p><p>Dentro del directorio wordpress miramos qué posibles subdirectorios puede haber o páginas.</p><p>wfuzz -c --hc 404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt &nbsp;http://192.168.1.25/wordpress/FUZZ wfuzz -c --hc 404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt &nbsp;http://192.168.1.25/wordpress/FUZZ&nbsp;</p><p></p><pre>000000013:   200        496 L    1474 W     28194 Ch    &quot;#&quot;                     
000000241:   301        7 L      13 W       194 Ch      &quot;wp-content&quot;            
000000786:   301        7 L      13 W       194 Ch      &quot;wp-includes&quot;           
000007180:   301        7 L      13 W       194 Ch      &quot;wp-admin&quot;              
000045240:   200        496 L    1474 W     28194 Ch    &quot;http://192.168.1.25/wor
                                                       dpress/&quot;  </pre><p></p>
	<p>Al acceder al directorio wordpress desde el navegador esto es lo que vemos:</p>
	<figure>
    <img alt="2023 01 16 15 49" title="2023 01 16 15 49" src="file:///home/kali/Documents/vulnhub/loly/writeup/2023-01-16_15-49.png"/>
    <figcaption>2023 01 16 15 49</figcaption>
  </figure><p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Como</p>
	<p>Como podemos ver los enlaces hacen referencia a un dominio en concreto, que asumimos es el que aloja el sitio. Por ese motivo, modificaremos /etc/hosts para asignar a la direccion IP el dominio en cuestion:</p>
	<pre>─── ┬──────────────────────────────────────────────────────────────────────────────────────────
       │ File: /etc/hosts
─── ┼──────────────────────────────────────────────────────────────────────────────────────────
  1   │ 127.0.0.1   localhost
  2   │ 127.0.1.1   kali
  3   │ ::1     localhost ip6-localhost ip6-loopback
  4   │ ff02::1     ip6-allnodes
  5   │ ff02::2     ip6-allrouters
  6   │ 192.168.1.25 loly.lc</pre><p>&nbsp;&nbsp;</p>
	<p>Al clicar en la primera pagina, se abre la pagina principal del blog:</p>
	<figure>
    <img alt="2023 01 16 15 59" title="2023 01 16 15 59" src="file:///home/kali/Documents/vulnhub/loly/writeup/2023-01-16_15-59.png"/>
    <figcaption>2023 01 16 15 59</figcaption>
  </figure><p>&nbsp;</p></body></html>
