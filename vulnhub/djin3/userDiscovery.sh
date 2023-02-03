#!/bin/bash

usernamefile="possibleUsers.txt"
while read  username;
do
	echo "$username\n$username\n" | nc 10.0.2.4 31337 
done < $usernamefile
