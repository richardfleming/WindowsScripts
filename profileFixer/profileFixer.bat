@ECHO OFF
powershell.exe -Command "& {Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File C:\profileFixer\profileFixer.ps1' -WindowStyle Hidden -Verb RunAs }"

