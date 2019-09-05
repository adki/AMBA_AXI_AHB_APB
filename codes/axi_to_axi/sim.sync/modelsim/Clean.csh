#!/bin/csh -f

if ( -d work                 ) \rm -rf work    
if ( -d lib                  ) \rm -rf lib     
if ( -e transcript           ) \rm -f transcript    
if ( -e wave.vcd             ) \rm -f wave.vcd    
if ( -e vish_stacktrace.vstf ) \rm -f vish_stacktrace.vstf    
if ( -e ethernet_log.txt     ) \rm -f ethernet_log.txt    
if ( -e fds.v                ) \rm -f fds.v    
if ( -e mm.v                 ) \rm -f mm.v    
if ( -e m.v                  ) \rm -f m.v    
if ( -e xx.v                 ) \rm -f xx.v    
if ( -e x.v                  ) \rm -f x.v    
if ( -e vsim.wlf             ) \rm -f vsim.wlf    
if ( -e compile.log          ) \rm -f compile.log

\rm -f wlf??*
