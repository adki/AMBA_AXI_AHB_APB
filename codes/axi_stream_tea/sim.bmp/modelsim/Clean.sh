#!/bin/sh -f

MODELSIMWORK=work

if [ -d ${MODELSIMWORK}      ]; then \rm -fr ${MODELSIMWORK}; fi
if [ -f transcript           ]; then \rm -f  transcript; fi
if [ -f wave.vcd             ]; then \rm -f  wave.vcd; fi
if [ -f vsim.wlf             ]; then \rm -f  vsim.wlf; fi
if [ -f vish_stacktrace.vstf ]; then \rm -f  vish_stacktrace.vstf; fi
if [ -f face_320x240_de.bmp  ]; then \rm -f  face_320x240_de.bmp; fi
if [ -f face_320x240_en.bmp  ]; then \rm -f  face_320x240_en.bmp; fi

