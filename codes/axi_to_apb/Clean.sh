#!/bin/sh

for F in sim
do
    if [ -f $F/Clean.sh ]; then
       ( cd $F; ./Clean.sh )
    fi
done
