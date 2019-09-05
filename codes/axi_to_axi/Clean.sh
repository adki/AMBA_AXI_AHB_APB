#!/bin/sh

for F in *; do
    if [[ -d "${F}" && ! -L "${F}" ]]; then
    if [ -f ${F}/Clean.sh ]; then
       ( cd ${F}; ./Clean.sh )
    fi
    fi
done
