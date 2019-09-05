@ECHO OFF
@FOR %%d IN (sim ) DO @(
	@IF EXIST %%d (
		@PUSHD %%d
		@IF EXIST Clean.bat (
			@CALL .\Clean.bat
		)
		@POPD
	)
)
