#!/bin/bash

code=$1
curlCommand="curl -s http://10.0.2.4:5000/?id=$code"
#echo $curlCommand
$curlCommand | grep "500 Internal Server Error" > /dev/null
if [ $? = 1 ]; then 
	echo "Command code $code: successful"
fi
