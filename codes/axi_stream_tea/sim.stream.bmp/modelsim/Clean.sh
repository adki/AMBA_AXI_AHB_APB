#!/bin/sh -f

MODELSIMWORK=work

if [ -d ${MODELSIMWORK}      ]; then \rm -fr ${MODELSIMWORK}; fi
if [ -f transcript           ]; then \rm -f  transcript; fi
if [ -f wave.vcd             ]; then \rm -f  wave.vcd; fi
if [ -f vsim.wlf             ]; then \rm -f  vsim.wlf; fi
if [ -f vish_stacktrace.vstf ]; then \rm -f  vish_stacktrace.vstf; fi

