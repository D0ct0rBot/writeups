#!/bin/bash
file=$1
cat $file | tr ":" " " | awk '{print $1}'
