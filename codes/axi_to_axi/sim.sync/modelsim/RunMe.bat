@ECHO OFF

SET WORK=work
SET VLIB=vlib
SET VSIM=vsim
SET VCOM=vcom
SET VLOG=vlog

SET TOP=top

IF EXIST %WORK% RMDIR /S/Q %WORK%

%VLIB% %WORK%
IF %errorlevel% NEQ 0 GOTO :END
%VLOG% -work %WORK% -f modelsim.args
IF %errorlevel% NEQ 0 GOTO :END
%VSIM% -c -do "run -all; quit" %WORK%.top
IF %errorlevel% NEQ 0 GOTO :END

:END
PAUSE
