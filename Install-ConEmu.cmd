@echo off

%WINDIR%\System32\WindowsPowerShell\v1.0\PowerShell.exe -ExecutionPolicy RemoteSigned -Command "Import-Module .\PSUtils.psm1; Install-ConEmu"

if "%PROCESSOR_ARCHITECTURE%" == "x64" (
    start ..\ConEmu\ConEmu64
) ELSE (
    start ..\ConEmu\ConEmu32
)
