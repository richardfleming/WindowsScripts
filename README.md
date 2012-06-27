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


pwExpEmailWarning.ps1
---------------------
Checks through AD User accounts for password expiration and sends email notifications when the password is <= x days till expiry or expired.

### Usage
Download the PowerShell script [pwExpEmailWarning.ps1] (http://github.com/richardfleming/WindowsScripts/blob/master/PwExpEmailWarning.ps1) and create a scheduled task on a domain controller.

Ensure that your domain controller is set to run remotesigned scripts, or this will fail.

Configurables
-------------
strSMTPServer - your SMTP server
strFromEmail - your default from email address
strFromDisplayName - the nice name for strFromEmail
arrSMTPExempt - (Optional) Add SamAccountName to array (useful for those admins who don't like/want to change their passwords)
intPwdExpireNotificationStartDay - (optional) How many days prior to password expiry do you want to start sending email notifications (default 15)
function Prepare-SMTPMessage - (Optional) If you don't like the default email message, look in here.
SIG - (Optional) Sign with your organisations own codesigning cert.
 