#!/bin/bash

LINKS_FILE=$1

if [ -z "$LINKS_FILE" ] ; then
    echo "usage: $0 <File with URI Links>"
    exit 1
fi

LINKS=`cat $LINKS_FILE`
for i in $LINKS ; do
    wget $i
done
