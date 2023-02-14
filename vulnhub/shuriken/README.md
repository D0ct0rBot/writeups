# Shuriken

Como siempre realizamos un escaneo de máquinas en la red accesible por la interfaz eth0
![arpscan.png](arpscan.png)

Como podemos ver la máquina con ip 192.168.1.149 es la máquina candidata a víctima.

┌──(kali㉿kali)-[~]
└─$ sudo nmap -sS -Pn -n -minrate 5000 192.168.1.149             
Starting Nmap 7.93 ( https://nmap.org ) at 2023-02-14 16:12 EST
Nmap scan report for 5000 (0.0.19.136)
Host is up.
All 1000 scanned ports on 5000 (0.0.19.136) are in ignored states.
Not shown: 1000 filtered tcp ports (no-response)

Nmap scan report for 192.168.1.149
Host is up (0.0067s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE    SERVICE
80/tcp   open     http
8080/tcp filtered http-proxy
MAC Address: 00:0C:29:8C:B3:CC (VMware)

Como se puede ver hay 2 puertos accesibles, el 80 y el 8080.

Ahora realizaremos un escaneo más exhaustivo sobre estos puertos

└─$ sudo nmap -sVC -p80,8080 192.168.1.149
Starting Nmap 7.93 ( https://nmap.org ) at 2023-02-14 16:21 EST
Nmap scan report for shuriken.home (192.168.1.149)
Host is up (0.0035s latency).

PORT     STATE    SERVICE    VERSION
80/tcp   open     http       Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Shuriken
8080/tcp filtered http-proxy
MAC Address: 00:0C:29:8C:B3:CC (VMware)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 9.83 seconds

Cosas interesantes que podemos observar son:
- la máquina víctima está asociada al nombre shuriken.home
- las versión del servidor apache es la 2.4.29 y es un Ubuntu.

Podemos mirar si esa versión es vulnerable utilizando searchsploit
De momento, no añadimos la entrada en /etc/hostname

