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
git config core.autocrlf input
git.exe add -A
git.exe commit -m "%input%"
git.exe pull
git.exe push

ECHO 
ECHO Successfully Commited

:exit
PAUSE