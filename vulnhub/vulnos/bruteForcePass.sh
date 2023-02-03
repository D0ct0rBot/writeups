#!/bin/bash

if [ $# -eq 0 ];
then
	echo "Wrong number of arguments"
	echo "	$0 hashed_password_file"
	exit 1
fi

passwords_file="/usr/share/wordlists/rockyou.txt"
hashed_pass_file=$1
src_hashed_pass=$(cat $hashed_pass_file)

echo $hashed_pass_file
echo $src_hashed_pass

while read password;
do
	dst_hashed_pass=$(echo $password | sha512sum | awk '{print $1}')
        echo "testing $password : $dst_hashed_pass"

	if [ "$src_hashed_pass" = "$dst_hashed_pass" ];
	then
		echo Password found: "$password"
		exit 0
	fi
done < $passwords_file
