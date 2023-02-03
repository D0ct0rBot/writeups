#!/bin/bash

default_iterations=5000
hasher=sha512sum

if [ $# -lt 2 ];
then
	echo "Wrong number of arguments"
	echo 	usage: $1 password salt [iterations=5000 default]
	exit 1
fi

password=$1
salt=$2

if [ $# -eq 3 ];
then
	iterations=$3
else
	iterations=$default_iterations
fi

key=$password$salt
mkpasswd --method=SHA-512 -S$salt $password

exit 0

# for (( i=1; i<=5000; i++ )
#for i in {1..$iterations};


for i in `seq $iterations`
do
	echo "$i $key"
	newkey=$(echo "$key" | $hasher | awk {'print $1'})
	key=$newkey
done

echo $newkey
