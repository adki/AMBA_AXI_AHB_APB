#!/bin/sh

if [ -d work                 ]; then \rm -rf work;                fi
if [ -f comile.log           ]; then \rm -f compile.log;          fi
if [ -f transcript           ]; then \rm -f transcript;           fi
if [ -f wave.vcd             ]; then \rm -f wave.vcd;             fi
if [ -f vsim.wlf             ]; then \rm -f vsim.wlf;             fi
if [ -f vish_stacktrace.vstf ]; then \rm -f vish_stacktrace.vstf; fi
if [ -f ethernet_log.txt     ]; then \rm -f ethernet_log.txt;     fi
if [ -f fds.v                ]; then \rm -f fds.v;                fi
if [ -f mm.v                 ]; then \rm -f mm.v;                 fi
if [ -f m.v                  ]; then \rm -f m.v;                  fi
if [ -f xx.v                 ]; then \rm -f xx.v;                 fi
if [ -f x.v                  ]; then \rm -f x.v;                  fi

/bin/rm -f wlft*
