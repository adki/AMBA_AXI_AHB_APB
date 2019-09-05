#!/bin/sh

DIRS="modelsim isim"
for F in $DIRS
do
    if [ -f $F/Clean.sh ]; then
       ( cd $F; ./Clean.sh )
    fi
done
