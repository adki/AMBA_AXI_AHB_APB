@ECHO OFF
@SET DIRS=modelsim isim
@FOR %%d IN ( %DIRS% ) DO (
	@IF EXIST %%d (
		@ECHO OFF
		@PUSHD %%d
		@.\Clean.bat
		@POPD
	)
)
