#!/bin/bash

FILES=100
VARS=10

FILE=0

rm -f *.txt

while [ $FILE -lt $FILES ]
do
	echo $FILE

	cat /dev/urandom | head -c $RANDOM | base64 > $FILE.txt

	VAR=0

	while [ $VAR -lt $VARS ]
	do
		RAND=$((RANDOM % 16 + 1))

		echo -n "$VAR: $FILE" >> $FILE.txt

		cat /dev/urandom | head -c $RAND | base64 >> $FILE.txt

		VAR=$((VAR + 1))
	done

	cat /dev/urandom | head -c $RANDOM | base64 >> $FILE.txt
	cat /dev/urandom | head -c $RANDOM | base64 >> $FILE.txt
	cat /dev/urandom | head -c $RANDOM | base64 >> $FILE.txt

	FILE=$((FILE + 1))
done

echo DONE
