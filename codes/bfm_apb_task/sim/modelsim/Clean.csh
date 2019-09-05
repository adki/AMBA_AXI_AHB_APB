#!/bin/csh -f

if ( -d work                 ) then
\rm -rf work    
endif
if ( -d lib                  ) then
\rm -rf lib     
endif
if ( -e transcript           ) then 
\rm -f transcript    
endif
if ( -e wave.vcd             ) then 
\rm -f wave.vcd    
endif
if ( -e vish_stacktrace.vstf ) then 
\rm -f vish_stacktrace.vstf    
endif
if ( -e ethernet_log.txt     ) then 
\rm -f ethernet_log.txt    
endif
if ( -e mm.v                 ) then 
\rm -f mm.v    
endif
if ( -e m.v                  ) then 
\rm -f m.v    
endif
if ( -e xx.v                 ) then 
\rm -f xx.v    
endif
if ( -e x.v                  ) then 
\rm -f x.v    
endif
if ( -e vsim.wlf             ) then 
\rm -f vsim.wlf    
endif

\rm -f wlf??*
