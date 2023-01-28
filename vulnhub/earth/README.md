# Earth

Iniciamos la investigación mirando las máquinas que hay en la red:

```bash
> sudo arp-scan -I eth0 --localnet
```

![arp-scan.png](arp-scan.png)

Parece que la máquina es de VirtualBox por el tipo de mac address que comienza por 08.

Hacemos un ping para ver si está online (o en cambio la info está cacheada)

```bash
> ping -c 1 192.168.1.53
```

```bash
PING 192.168.1.53 (192.168.1.53) 56(84) bytes of data.
64 bytes from 192.168.1.53: icmp_seq=1 ttl=64 time=15.4 ms

--- 192.168.1.53 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 15.385/15.385/15.385/0.000 ms
```
-------------------------------------------------------------------------------
Y ahora realizamos un escaneo rápido para ver qué servicios están corriendo en la máquina:

```bash
> sudo nmap -sS -n -p1-1000 -Pn 192.168.1.53 
```

```bash
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-22 14:31 EST
Nmap scan report for 192.168.1.53
Host is up (0.0052s latency).
Not shown: 987 filtered tcp ports (no-response), 10 filtered tcp ports (admin-prohibited)
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
MAC Address: 08:00:27:61:4D:85 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 5.44 seconds
```

-------------------------------------------------------------------------------
 
Realizamos una prueba más exhaustiva de los servicios, escaneando todos los puertos pero no encontramos nada más.

Miremos pues qué versiones de servicios están corriendo por esos puertos:

```bash
> sudo nmap -sCV -n -p22,80,443 192.168.1.53
```

```bash
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-26 17:17 EST
Nmap scan report for 192.168.1.53
Host is up (0.0060s latency).

PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 8.6 (protocol 2.0)
| ssh-hostkey: 
|   256 5b2c3fdc8b76e9217bd05624dfbee9a8 (ECDSA)
|_  256 b03c723b722126ce3a84e841ecc8f841 (ED25519)
80/tcp  open  http     Apache httpd 2.4.51 ((Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9)
|_http-server-header: Apache/2.4.51 (Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9
|_http-title: Bad Request (400)
443/tcp open  ssl/http Apache httpd 2.4.51 ((Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9)
| tls-alpn: 
|_  http/1.1
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-title: Test Page for the HTTP Server on Fedora
| ssl-cert: Subject: commonName=earth.local/stateOrProvinceName=Space
| Subject Alternative Name: DNS:earth.local, DNS:terratest.earth.local
| Not valid before: 2021-10-12T23:26:31
|_Not valid after:  2031-10-10T23:26:31
|_ssl-date: TLS randomness does not represent time
|_http-server-header: Apache/2.4.51 (Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9
MAC Address: 08:00:27:61:4D:85 (Oracle VirtualBox virtual NIC)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 25.59 seconds
```

-------------------------------------------------------------------------------

Ahora podemos mirar qué tecnologías web están corriendo en la máquina víctima.

```bash
> whatweb 192.168.1.53:80                                     
```

```bash
http://192.168.1.53:80 [400 Bad Request] Apache[2.4.51][mod_wsgi/4.7.1], 
Country[RESERVED][ZZ], HTML5, HTTPServer[Fedora Linux][Apache/2.4.51 (Fedora) 
OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9], IP[192.168.1.53],
OpenSSL[1.1.1l], Python[3.9], Title[Bad Request (400)], 
UncommonHeaders[x-content-type-options,referrer-policy]
```

```bash
> whatweb 192.168.1.53:443
```

```bash
http://192.168.1.53:443 [400 Bad Request] Apache[2.4.51][mod_wsgi/4.7.1],
Country[RESERVED][ZZ], HTTPServer[Fedora Linux][Apache/2.4.51 (Fedora)
OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9], IP[192.168.1.53],
OpenSSL[1.1.1l], Python[3.9], Title[400 Bad Request]
```

-------------------------------------------------------------------------------

Si inspeccionamos las webs mediante un navegador, vemos que ambos puertos dan Bad Request (400) como respuesta.

![bad-request.png](bad-request.png)

-------------------------------------------------------------------------------

Si tenemos en cuenta los resultados obtenidos en la última ejecución de nmap, podemos observar que se nombran 2 dominios relacionados con 192.168.1.53:

```bash
| Subject Alternative Name: DNS:earth.local, DNS:terratest.earth.local
```

Como no sabemos si se estará efectuando virtual hosting en la máquina que dependa del hostname, vamos a añadir esas entradas al archivo /etc/hosts

![etc_hosts.png](etc_hosts.png)

Ahora vamos a mirar que vemos en el browser:


para http://192.168.1.53

![http_192_168_1_53.png](http_192_168_1_53.png)

para http://earth.local o https://earth.local o http://terratest.earth.local

![http_earth_local.png](http_earth_local.png)

para https://terratest.earth.local

![https_terratest_earth_local.png](https_terratest_earth_local.png)

-------------------------------------------------------------------------------

Y ahora volvemos a mirar whatweb pero con los dominios:

```bash
> whatweb http://earth.local                         
```

```bash
http://earth.local [200 OK] Apache[2.4.51][mod_wsgi/4.7.1], Cookies[csrftoken], Country[RESERVED][ZZ], Django, HTML5, HTTPServer[Fedora Linux][Apache/2.4.51 (Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9], IP[192.168.1.53], OpenSSL[1.1.1l], Python[3.9], Title[Earth Secure Messaging], UncommonHeaders[x-content-type-options,referrer-policy], X-Frame-Options[DENY]
```

```bash
> whatweb https://terratest.earth.local
```

```bash
https://terratest.earth.local [200 OK] Apache[2.4.51][mod_wsgi/4.7.1], Country[RESERVED][ZZ], HTTPServer[Fedora Linux][Apache/2.4.51 (Fedora) OpenSSL/1.1.1l mod_wsgi/4.7.1 Python/3.9], IP[192.168.1.53], OpenSSL[1.1.1l], Python[3.9]
```                                                        
-------------------------------------------------------------------------------

Vamos a ver si podemos descubrir páginas no listadas:

```bash
> wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://earth.local/FUZZ     
```

```bash
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://earth.local/FUZZ
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload                     
=====================================================================
000000014:   200        33 L     76 W       2595 Ch     "http://earth.local/"       
000000259:   301        0 L      0 W        0 Ch        "admin"                     
000045240:   200        33 L     76 W       2595 Ch     "http://earth.local/"       
000138620:   503        9 L      34 W       299 Ch      "u-god"                     

Total time: 0
Processed Requests: 220560
Filtered Requests: 220543
Requests/sec.: 0
```

Podemos ver que en la enumeración existe una página admin.

-------------------------------------------------------------------------------

Veamos qué pinta tiene la página admin en el navegador:

![http_earth_local_admin.png](http_earth_local_admin.png)

Y esta página abre un panel de autenticación:

![http_earth_local_admin_login.png](http_earth_local_admin_login.png)

Y si abrimos burpsuite, podemos ver como se envían los valores de los campos:

![burpsuite_login_panel.png](burpsuite_login_panel.png)

Como podemos ver hay una cookie:

```
Cookie: csrftoken=0n5M1RVM351oxMM7D7tnQE3h9BR7jniIswkjUGFXGHXd0JlJZcC6DZlgAR017BgS
```

También hay otro token como variable post que se envía junto al username y el password:

```
csrfmiddlewaretoken=w1i2HKd3nHrGde7kjXiemQZhxlCnSiijYaxzAzXe0jnvGbGWF2rX9bhgYBLhGwgt&username=username&password=password
```

Este token ya estaba mencionado en el código fuente de la página:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Earth Secure Messaging Admin</title>
 
<link rel="stylesheet" href="/static/styles.css">
</head>
<body>
<h1 class="aligncenter">Log In</h1>
<form method="post">


<input type="hidden" name="csrfmiddlewaretoken" value="I8gG1qDs8tH7XjGT1akqfpeilMx3nlRuBN1beVG1sMVsNEu3SKVeJZ0JaYxYUgWX">


<p><label for="id_username">Username:</label> <input type="text" name="username" autofocus autocapitalize="none" autocomplete="username" maxlength="150" required id="id_username"></p>
<p><label for="id_password">Password:</label> <input type="password" name="password" autocomplete="current-password" required id="id_password"></p>
<button type="submit">Log In</button>
</form>
</body>
</html>
```

No obstante este token va cambiando cada vez que se refresca la página.

-------------------------------------------------------------------------------

Por otra parte, la página principal también mostraba un formulario de entrada de datos que podemos probar:

![http_earth_local_test_message.png](http_earth_local_test_message.png)

Y esto es lo que se ve en burpsuite:

![burpsuite_main_window_message.png](burpsuite_main_window_message.png)

Como podemos ver, cada vez que se envía un mensaje se añade una entrada con un mensaje, al parecer codificado.
Y si enviamos varias veces el mismo mensaje, la codificación es la misma, por tanto, no parece que la codificación dependa de csrfmiddlewaretoken.

![encoded_message.png](encoded_message.png)

Para el mensaje "Esto es un mensaje de prueba." y para key "Test key." Esta es la codificación.
1116071b000e16595b3a451e114e1804134b740116545019101c4c354b

-------------------------------------------------------------------------------

Estaría bien averiguar el algoritmo de codificación porque así igual podríamos decodificar los otros mensajes.

Da la sensación de que esas cadenas de carácteres es código en hexadecimal, por lo que podemos probar a decodificarlo on xxd:

```bash
> echo 1116071b000e16595b3a451e114e1804134b740116545019101c4c354b | xxd -r -p > testmessage.txt
```

La secuencia de carácteres obtenida no es ascii, y contiene carácteres de control.

```bash
> xxd testmessage.txt 

00000000: 1116 071b 000e 1659 5b3a 451e 114e 1804  .......Y[:E..N..
00000010: 134b 7401 1654 5019 101c 4c35 4b         .Kt..TP...L5K
```

Sin embargo, la longitud del mensaje decodificado es muy similar a la del mensaje de entrada:

```bash
> echo 1116071b000e16595b3a451e114e1804134b740116545019101c4c354b | xxd -r -p | wc -c
29
```

```bash
> echo "Esto es un mensaje de prueba." | wc -c
30
```

ESto nos puede dar una pista del tipo de algoritmo usado en la codificación.

Además, si cambiamos la key, el mensaje codificado cambia:

```
Text: "Esto es un mensaje de prueba."
key: "0"
output: "7543445510554310455e105d555e43515a5510545510404245555251"
```

Así que podemos pensar que la key forma parte de los parámetros de entrada del algoritmo de codificación.

-------------------------------------------------------------------------------

Podríamos probar a hacer una XOR con ambos parámetros y ver qué devuelve, pero si no es algo así de simple, entonces se puede complicar mucho.
Antes de ponernos a programar un script para hacer una prueba, podemos buscar en internet a ver si hay alguna herramienta online de codificación/decodificación en formato XOR.

Google: XOR Encoder
> https://www.dcode.fr/xor-cipher

Introducimos el texto de prueba y la key de entrada (0 = 0x30 en ascii) y si ponemos que nos de el resultado como lista de carácteres en hexadecimal, esto es lo que obyenemos:

![xor_encode.png](xor_encode.png)

Y vemos que tiene muy buena pinta, dado que la cadena de carácteres obtenido en la página principal para dicho texto con la misma clave, produce los mismos valores hexadecimales al decodificarla:

```bash
> echo 7543445510554310455e105d555e43515a5510545510404245555251 | xxd -r -p | xxd 
```

```
00000000: 7543 4455 1055 4310 455e 105d 555e 4351  uCDU.UC.E^.]U^CQ
00000010: 5a55 1054 5510 4042 4555 5251            ZU.TU.@BEURQ
```                                                              

Es decir el proceso que se realiza en la página earth.local para codificar un mensaje es:

Entramos un mensaje y sale un mensaje codificado.

```
mensaje -> XOR key -> xxd -> mensaje codificado
```

y, por tanto, el proceso de decodificación con XOR sería:

Entramos un mensaje codificado y sale el mensaje normal.

```
mensaje codificado -> xxd -r -> XOR key -> mensaje 
```

Crearemos un script para dados 2 parámetros de entrada, un fichero y un texto, nos genere un mensaje codificado/decodificado

![xordecode.py](xordecode.py)

-------------------------------------------------------------------------------

En el panel de autenticación, probamos entradas típicas como:

- admin / admin,
- admin / admin123,
- admin / 0n5M1RVM351oxMM7D7tnQE3h9BR7jniIswkjUGFXGHXd0JlJZcC6DZlgAR017BgS
- admin / (vacío) <- El formulario no lo permite.
- earth / admin
- earth / admin123
- earth / 0n5M1RVM351oxMM7D7tnQE3h9BR7jniIswkjUGFXGHXd0JlJZcC6DZlgAR017BgS

Ninguna de las credenciales nos da acceso. Así que probaremos a realizar un ataque de fuerza bruta,
para posibles usuario admin, earth o terratest

Nota: 0n5M1RVM351oxMM7D7tnQE3h9BR7jniIswkjUGFXGHXd0JlJZcC6DZlgAR017BgS es el valor extraño que hemos encontrado como cookie para la variable *csrftoke* en el código html. Buscando por google, al final averiguamos que esta variable en la cookie, forma parte de un mecanismo para evitar ataques tipo CSRF (Cross Site Request Forgery) y no nos va a llevar a ningún lugar al realizae la intrusión.

-------------------------------------------------------------------------------

Seguimos investigando realizando más enumeraciones. Estas son las enumeracione realizadas:

Para earth.local
	subdominios
	gobuster dns --domain earth.local --wordlist /usr/share/SecLists/Discovery/DNS/subdomains-top1million-110000.txt
		Nada

Para http://earth.local

	Ficheros backup con gobuster
	gobuster dir -d --url http://earth.local --wordlist /usr/share/SecLists/Discovery/Web-Content/common.txt -x txt,html,php,js,gz,tar.gz,zip 
		Nada

	Ficheros backup con gobuster añadiendo /
	gobuster dir -f -d --url http://earth.local --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x bak,php.bak,tar.gz,zip,txt 
		Nada

	Más bak files con wfuzz
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://earth.local/FUZZ.bak
		Nada

Para http://earth.local/admin
	Directorios 
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://earth.local/admin/FUZZ
		000000053:   200        18 L     50 W       746 Ch      "login"                
		000001225:   302        0 L      0 W        0 Ch        "logout"               
		000045240:   200        15 L     33 W       306 Ch      "http://earth.local/admin/"

Para http://earth.local/static 
	Ficheros y directorios con gobuster
	gobuster dir --url http://earth.local/static --wordlist /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x html,php,js,gz,tar.gz,zip,txt
		Nada

	Ficheros backup con gobuster
	gobuster dir -d --url http://earth.local/static --wordlist /usr/share/SecLists/Discovery/Web-Content/common.txt -x txt,html,php,js,gz,tar.gz,zip 
		Nada

Para http://terratest.earth.local
	Directorios
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://terratest.earth.local/FUZZ  

	php files
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://terratest.earth.local/FUZZ.php

	js files
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt http://terratest.earth.local/FUZZ.js

Para https://terratest.earth.local:443
	Directorios
	wfuzz --hc 400,404,403,405,500 -w /usr/share/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt https://terratest.earth.local:443/FUZZ

	Ficheros backup con gobuster
	gobuster dir -d -k --url https://terratest.earth.local:443 --wordlist /usr/share/SecLists/Discovery/Web-Content/common.txt -x txt,html,php,js,gz,tar.gz,zip 
		/index.html           (Status: 200) [Size: 26]
		/index.html           (Status: 200) [Size: 26]
		/robots.txt           (Status: 200) [Size: 521]
		/robots.txt           (Status: 200) [Size: 521]
-------------------------------------------------------------------------------

Como podemos ver, hay un fichero robots.txt que podemos intentar mirar:

https://terratest.earth.local/robots.txt

```
User-Agent: *
Disallow: /*.asp
Disallow: /*.aspx
Disallow: /*.bat
Disallow: /*.c
Disallow: /*.cfm
Disallow: /*.cgi
Disallow: /*.com
Disallow: /*.dll
Disallow: /*.exe
Disallow: /*.htm
Disallow: /*.html
Disallow: /*.inc
Disallow: /*.jhtml
Disallow: /*.jsa
Disallow: /*.json
Disallow: /*.jsp
Disallow: /*.log
Disallow: /*.mdb
Disallow: /*.nsf
Disallow: /*.php
Disallow: /*.phtml
Disallow: /*.pl
Disallow: /*.reg
Disallow: /*.sh
Disallow: /*.shtml
Disallow: /*.sql
Disallow: /*.txt
Disallow: /*.xml
Disallow: /testingnotes.*
```

Vemos que hay una entrada para no permitir el acceso a ficheros "testingnotes.*" a los rastreadores.

(para información sobre como funiona los ficheros robots.txt:

https://developers.google.com/search/docs/crawling-indexing/robots/robots_txt?hl=es#syntax)

-------------------------------------------------------------------------------

Probamos a ver si existe un fichero como testingnotes.txt 
En caso de no encontramos nada, siempre podríamos intentar realizar una fuerza bruta sobre extensiones, pero en este caso no es neceario.

https://terratest.earth.local/testingnotes.txt

```
Testing secure messaging system notes:
*Using XOR encryption as the algorithm, should be safe as used in RSA.
*Earth has confirmed they have received our sent messages.
*testdata.txt was used to test encryption.
*terra used as username for admin portal.
Todo:
*How do we send our monthly keys to Earth securely? Or should we change keys weekly?
*Need to test different key lengths to protect against bruteforce. How long should the key be?
*Need to improve the interface of the messaging interface and the admin panel, it's currently very basic.
```

Como vemos la codificación de los mensajes se realizaba utilizando XOR

También se puede ver que se utiliza un fichero testdata.txt para testear la encriptación, podemos mirar si podemos acceder al fichero desde la web, y en ese caso podríamos obtener la key utilizada.

Vemos que el username para el portal de administración es terra.

Así pues, mientras investigamos si podemos obtener la key vamos a realizar un ataque de fuerza bruta para entrar en el panel de aministración.

-------------------------------------------------------------------------------

Podemos pues intentar un ataque de fuerza bruta para intentar entrar en el panel:


```bash
> hydra -l terra -P /usr/share/wordlists/rockyou.txt -f -u -vV terratest.earth.local http-form-post "/admin/login:username=^USER^&password=^PASS^:Please enter a correct username and password"
```

Esta vía no lleva a ningún lado. 

-------------------------------------------------------------------------------

Vemos que tenemos acceso al fichero testdata.txt

https://terratest.earth.local/testdata.txt

Este es el contenido del fichero testdata.txt:

```
According to radiometric dating estimation and other evidence, Earth formed over 4.5 billion years ago. Within the first billion years of Earth's history, life appeared in the oceans and began to affect Earth's atmosphere and surface, leading to the proliferation of anaerobic and, later, aerobic organisms. Some geological evidence indicates that life may have arisen as early as 4.1 billion years ago.
```

-------------------------------------------------------------------------------


Matemáticamente la funcion XOR se comporta de la siguiente manera:

a XOR b = c
y
c XOR b = a

pero también:

a XOR c = b
o
c XOR a = b


Si sustituimos las letras por palabras con significado:


Mensaje XOR clave = MensajeEncriptado

y para realizar el paso inverso:

MensajeEncriptado XOR clave = Mensaje

pero también:

Mensaje XOR MensajeEncriptado = clave
o
MensajeEncriptado XOR Mensaje = clave

Utlizaremos como segundo parámetro el texto de prueba.

```bash
> key=$(cat testdata.txt)
```

Ahora hemos de coger uno de los mensajes encriptados que aparecen inicialmente en la web y lo utilizaremos como mensaje fuente:

```bash
> echo 2402111b1a0705070a41000a431a000a0e0a0f04104601164d050f070c0f15540d1018000000000c0c06410f0901420e105c0d074d04181a01041c170d4f4c2c0c13000d430e0e1c0a0006410b420d074d55404645031b18040a03074d181104111b410f000a4c41335d1c1d040f4e070d04521201111f1d4d031d090f010e00471c07001647481a0b412b1217151a531b4304001e151b171a4441020e030741054418100c130b1745081c541c0b0949020211040d1b410f090142030153091b4d150153040714110b174c2c0c13000d441b410f13080d12145c0d0708410f1d014101011a050d0a084d540906090507090242150b141c1d08411e010a0d1b120d110d1d040e1a450c0e410f090407130b5601164d00001749411e151c061e454d0011170c0a080d470a1006055a010600124053360e1f1148040906010e130c00090d4e02130b05015a0b104d0800170c0213000d104c1d050000450f01070b47080318445c090308410f010c12171a48021f49080006091a48001d47514c50445601190108011d451817151a104c080a0e5a > encodedmsg.txt
```

Recordemos que este texto ha sufrido el proceso de ser convertido a texto donde cada valor codificado se representa en hexadecimal.
Antes de realizar el proceso de obtención de la key original, debemos pasar los datos de hexadeimal a mensaje encritpado con XOR.

```bash
> cat encodedmsg.txt | xxd -r -d > encodedmesg.dat 
```

Y ya podemos realizar el proceso de obtención de la clave original utilizando el script que creamos al principio.

```bash
> python3 xordecode.py encodedmsg.dat $key 
```

```bash
earthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimatechangebad4humansearthclimat
```

Así pues la clave utilizada parece ser la siguiente *earthclimatechangebad4humans*

-------------------------------------------------------------------------------
