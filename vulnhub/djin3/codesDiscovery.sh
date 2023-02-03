#!/bin/bash

for code in {1000..9999}
do
	./singleCodeDiscovery.sh $code &
done
