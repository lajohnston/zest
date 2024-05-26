@echo off

rem Build suite on Windows
rem Ensure wla-z80 and wlalink and in the system path

rem Change to suite directory
pushd "%~dp0"

rem Build ROM
wla-z80 -o suite.o suite.asm
wlalink -d -S -A linkfile suite.sms

rem Output path to ROM
echo|set /p="Zest suite ROM saved to "
echo %~dp0suite.sms

rem Return to original directory
popd