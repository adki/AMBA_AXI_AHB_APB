@ECHO OFF

SET MODELSIMWORK=work

IF EXIST %MODELSIMWORK%       RMDIR /S/Q %MODELSIMWORK%
IF EXIST transcript           DEL   /Q   transcript
IF EXIST wave.vcd             DEL   /Q   wave.vcd
IF EXIST vsim.wlf             DEL   /Q   vsim.wlf
IF EXIST vish_stacktrace.vstf DEL   /Q   vish_stacktrace.vstf
IF EXIST face_320x240_de.bmp  DEL   /Q face_320x240_de.bmp
IF EXIST face_320x240_en.bmp  DEL   /Q face_320x240_en.bmp
