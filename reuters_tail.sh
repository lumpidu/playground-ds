#!/bin/bash

outfile=$1

if [ -z "$outfile" ] ; then
    echo "error No output file given ..."
    exit 1
fi

rsstail -i 120 -l -u http://mf.feeds.reuters.com/reuters/UKBusinessNews | tee $outfile
