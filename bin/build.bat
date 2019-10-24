@echo off
setlocal enableDelayedExpansion

set MYDIR=..\src
cd  %MYDIR%
for /F %%x in ('dir /B/D %MYDIR%') do (
  erlc +debug_info -o ../bin %%x
)