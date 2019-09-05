@ECHO OFF
:: Copyright (c) 2013 by Ando Ki.
:: All right reserved.
::
:: This code is distributed in the hope that it will
:: be useful to understand Ando Ki's work,
:: but WITHOUT ANY WARRANTY.

SET MODELSIMWORK=work
SET MODELSIMVLIB=vlib
SET MODELSIMVSIM=vsim
SET MODELSIMVCOM=vcom
SET MODELSIMVLOG=vlog

SET DESIGNTOP=top

IF EXIST %MODELSIMWORK% RMDIR /S/Q %MODELSIMWORK%

%MODELSIMVLIB% %MODELSIMWORK%
%MODELSIMVLOG% -work %MODELSIMWORK% -lint -f modelsim.args
%MODELSIMVSIM% -novopt -c -do "add wave *; run -all; quit"^
              %MODELSIMWORK%.%DESIGNTOP%

:END
PAUSE
