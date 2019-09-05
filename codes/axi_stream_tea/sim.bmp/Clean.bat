@ECHO OFF
@FOR /D %%I in (*) DO @(
	@IF EXIST %%I\Clean.bat (
		@PUSHD %%I
		@CALL .\Clean.bat
		@POPD
	)
)
