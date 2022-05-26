@echo off
ECHO Enter commit message:
SET /p input=""
GOTO check
  

:check
IF "%input%" == "" (
	ECHO Input is empty
	input="Unspecified Commit Message"
	GOTO exit 
) ELSE (
	GOTO commit
)

:commit
git.exe pull
git.exe add -A
git.exe commit -m "%input%"
git.exe push
ECHO Successfully Commited

:exit
PAUSE