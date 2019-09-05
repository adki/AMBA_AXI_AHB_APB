@ECHO OFF

REM Copyright (c) 2009 by Ando Ki.
REM All right reserved.
REM
REM This code is distributed in the hope that it will
REM be useful to understand iPROVE related products,
REM but WITHOUT ANY WARRANTY.

SET MODELSIMWORK=work

IF EXIST %MODELSIMWORK%       RMDIR /S/Q %MODELSIMWORK%
IF EXIST transcript           DEL   /Q   transcript
IF EXIST wave.vcd             DEL   /Q   wave.vcd
IF EXIST vsim.wlf             DEL   /Q   vsim.wlf
IF EXIST vish_stacktrace.vstf DEL   /Q   vish_stacktrace.vstf
