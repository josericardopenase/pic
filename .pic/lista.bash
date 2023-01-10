#!/bin/bash
DATE=$(date +%Y%m%d%H%M%S)
var=$(cat snap | cut -d: -f4 | sort -u | grep -v "^\.")
res=""
for i in $var; do
	res="$res ../$i"
	#tar czf fichero.tar.gz "../"$i 1 > /dev/null 2> /dev/null
done
tar czf ./versions/$DATE.tgz $res 1 > /dev/null 2> /dev/null
