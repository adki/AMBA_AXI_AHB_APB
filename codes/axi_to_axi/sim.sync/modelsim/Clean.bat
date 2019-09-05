@ECHO OFF

SET MODELSIMWORK=work

IF EXIST %MODELSIMWORK%       RMDIR /S/Q %MODELSIMWORK%
IF EXIST transcript           DEL   /Q   transcript
IF EXIST wave.vcd             DEL   /Q   wave.vcd
IF EXIST vsim.wlf             DEL   /Q   vsim.wlf
IF EXIST vish_stacktrace.vstf DEL   /Q   vish_stacktrace.vstf
