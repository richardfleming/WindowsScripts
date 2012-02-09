WINDOWS SCRIPTS
===============

A collection of useful little scripts to make the life of a SysAdmin easier.

PwExpChk.vbs
------------
Simple VBScript that notifies the current user if their password is about to expire.

### Usage
Download the VBScript [PwExpChk.vbs] (http://github.com/richardfleming/WindowsScripts/blob/master/PwExpChk.vbs) and stick it in a profile logon script, or a GPO logon script.

Configurables
-------------
intPopupWarningInDays - Set the number of days before password expiration to notify.  Default is 7.