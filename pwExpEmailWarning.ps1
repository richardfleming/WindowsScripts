<######################################################################################
  Filename: PwExpEmailWarning.ps1
 
  Version No.: 1.0.0
 
  Revision History
 
  Date           Version     Author             Revision Description            Notes
  ------------------------------------------------------------------------------------ 
  06/26/2012     1.0.0       R.D.Fleming        Initial Check-in ...             [0]
 
 #####################################################################################
 
    Licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
 
 #####################################################################################
 
  Description:
 
 	Checks through AD User accounts for password expiration and sends email
 	notifications when the password is <= x days till expiry or expired.
    (x is configured as configuration point 5 and default value is 15)
    
  Configuration:
  
  This script automatically detects domain settings, however you still need to
  configure some options to your specific network.
  
    1. Change strSMTPServer to your SMTP server
    2. Change strFromEmail to your default from email address
    3. Change strFromDisplayName to the nice name for strFromEmail
    4. (Optional) Add SamAccountName to arrSMTPExempt (useful for those admins
                  who don't like/want to change their passwords)
    5. (Optional) Change intPwdExpireNotificationStartDay if you want notifications
                  to begin sooner or later than 15 days
    6. (Optional) Change the default message in function Prepare-SMTPMessage
    7. (Optional) Sign with your organisations own codesigning cert.
 
  Dependencies:
 
 	Requires ActiveDirectory PowerShell module
    
  Script URL:
    
    https://github.com/richardfleming/WindowsScripts
         
  Notes:
 
 	[0] Initial Check-in of script
 
 #####################################################################################>

# Import required module.
Import-Module ActiveDirectory

# Customisable variables.
Set-Variable -name strSMTPServer -value "your.mailserver.example.com" -scope global
Set-Variable -name strFromEmail -value "no-reply@example.com" -scope global
Set-Variable -name strFromDisplayName -value "Example.com's Automated Password Expiry Notification System" -scope global
Set-Variable -name arrSMTPExempt -value @("", "") -scope global
Set-Variable -name intPwdExpireNotificationStartDay -value 15 -scope global

# Fixed Variables (Do not change)
Set-Variable -name objDomain -value (Get-ADDomain) -scope global


# --- Start of code --- #


<##
 # Clean up our global variables.
 #>
function Remove-AllGlobalVariables {
    Remove-Variable -name strSMTPServer -scope global
    Remove-Variable -name strFromEmail -scope global
    Remove-Variable -name strFromDisplayName -scope global
    Remove-Variable -name arrSMTPExempt -scope global
    Remove-Variable -name intPwdExpireNotificationStartDay -scope global
    Remove-Variable -name objDomain -scope global
}

<##
 # Retreives Domain Policy maximum password age and converts it into days.
 #>
function Get-MaxPwdAge {
    $strDNSRoot = $objDomain.DNSRoot
    $strDN = $objDomain.DistinguishedName
    $strConnection = "LDAP://"+$strDN
    $objAD = [ADSI]$strConnection
    $intMaxPwdAge = -($objAD.ConvertLargeIntegerToInt64($objAD.MaxPwdAge.Value))/(600000000 * 1440)

    Write-Output $intMaxPwdAge
}

<##
 # Sends SMTP e-mail message
 #
 # Only need to set the "To" fields, the subject and the message body.  The SMTP Server, and
 # "From" fields are set at the top of this script and used as defaults, but can be overloaded.
 #
 # Example Usage:
 #   Send-SMTPMessage "joe@example.com" "Joe Example" "Message for Joe Example" "This is a test message for Joe"
 #>
function Send-SMTPMessage([string]$strToEmail, [string]$strToDisplayName, [string]$strSubject, 
                          [string]$strMessageBody,  [string]$strSMTPServer = $strSMTPServer, 
                          [string]$strFromEmail = $strFromEmail, [string]$strFromDisplayName = $strFromDisplayName) {

    # MailAddress object and sender/receiver config
    $objSender = New-Object System.Net.Mail.MailAddress($strFromEmail, $strFromDisplayName)
    $objRecipient = New-Object System.Net.Mail.MailAddress($strToEmail, $strToDisplayName)

    # MailMessage object and email structure
    $objMailMessage = New-Object System.Net.Mail.MailMessage
    $objMailMessage.Sender = $objSender
    $objMailMessage.From = $objSender
    $objMailMessage.To.Add($objRecipient)
    $objMailMessage.Subject = $strSubject
    $objMailMessage.Body = $strMessageBody

    # SMTP Server Object
    $objSmtpClient = New-Object System.Net.Mail.SmtpClient
    $objSmtpClient.Host = $strSMTPServer
    
    # Send the message
    $objSmtpClient.Send($objMailMessage);

}


<##
 # Prepares the message body, then calls Send-SMTPMessage.
 #
 # You may or may not want to edit the default message as it is generic
 #
 # Example Usage:
 #   Prepare-SMTPMessage "joe@example.com" "Joe Example" "JExample" 42
 #>
function Prepare-SMTPMessage ([string]$strUserMail, [string]$strUserDisplayName, 
                              [string]$strUserSamAccountName, [int]$intPwdExpiresInDays)  {

    $strUserDomainAndSamAccountName = $objDomain.NetBIOSName + "\" + $strUserSamAccountName
    
    # Default Message Head.  Change if you wish.
    $strMessageBodyHead = `

@"
Greetings $strUserDisplayName,

This is an automated message to notify you of your passwords impending expiration. Any attempts to reply to this message will be met with failure.


"@    

    # Default Message Foot.  Change if you wish.
    $strMessageBodyFoot = `

@"


Yours virtually,

$strFromDisplayName
"@    

    # If password is set to expire, set appropriate subject and message body
    if ($intPwdExpiresInDays -gt 0) {
        $strMessageSubject = "Your Password is set to expire."
        $strMessageBody = `

@"
Your password for the domain account ($strUserDomainAndSamAccountName) will expire in less than $intPwdExpiresInDays days.
    
If you need assistance in resetting your password, please contact IT.
"@

    # else if the password is already expired, change the subject and message body
    } else {
        $intPwdExpiredInDays = $intPwdExpiresInDays * -1
        $strMessageSubject = "Your Password has expired!"
        $strMessageBody = @"
Your password for the domain account ($strUserDomainAndSamAccountName) has expired.

Please contact the IT group to rectify your password settings. 
"@
    }        
    
    # put the message body together ...
    $strMessageBody = $strMessageBodyHead + $strMessageBody + $strMessageBodyFoot

    # ... and send the message
    Send-SMTPMessage $strUserMail $strUserDisplayName $strMessageSubject $strMessageBody
}    

<##
 # Gets a list of users then checks to see if their passwords are near 
 # expiration or expired, then fires off an email.
 #
 # If the global array arrSMTPExempt is set, then any SamAccountNames
 # listed in there will not receive an email.
 #>
function Get-PasswordExpiredUsers {
    $strFilter = "(ObjectClass -eq 'user') -and (l -like '*') -and (Enabled -eq 'True')"
    $objUsers = Get-ADUser -Filter $strFilter -Properties SamAccountName, DisplayName, mail, PasswordLastSet
    $intMaxPwdAge = Get-MaxPwdAge

    # Interate through each user object and check if the password is expired, or nearing expiration limit
    ForEach ($objUser in $objUsers) {
        $intUsrPwdAgeInDays = (New-TimeSpan $(Get-Date $objUser.PasswordLastSet) $(Get-Date)).Days
        $intPwdExpiresInDays = $intMaxPwdAge - $intUsrPwdAgeInDays
                    
        # Ignore exempt users
        if ($arrSMTPExempt -notcontains $objUser.SamAccountName) {
            # Prepare-SMTPMessage if password expires less than or on a certain day (default is 15)
            if ( $intPwdExpiresInDays -le $intPwdExpireNotificationStartDay ) {
                Prepare-SMTPMessage $objUser.mail $objUser.DisplayName $objUser.SamAccountName $intPwdExpiresInDays
            }
        }
    }
}


<##
 # Meat and potatoes.  Call the relevant functions and then do clean up
 #>
Get-PasswordExpiredUsers
Remove-AllGlobalVariables

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOC0prS2SsnpbuxhEoVh2CLrI
# ljugggI9MIICOTCCAaagAwIBAgIQ4FMg+jBQhL9OMBRd8yfagjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMjA2MjYyMDA2MDRaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA0DP/20tL9Mmh
# bXCjhmWzHj9ANVvaaFuC74SeLqm7ELzHst2IHctx9d+9aM+LZNAZyCAlL7QvkZK3
# +T/HUVEgzUCFgp2qd7xBCb2rLYCN2QTaUH24Js2Uinqa+bub0SjUNEuzoEiQf+cd
# +X+69wNWaODXvw3LNqEChdrvMrgDrR0CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQB9kodvLLeCI/iDq5PaRo+KEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQykj8/3S4MqNJtzL/
# gn4EyjAJBgUrDgMCHQUAA4GBALIUdJGnAJsNi+Vpbj9S8a9297DBB1M+IOUyIHyW
# N7+NcWAzdVW+WK0wz2KfjfpXB9mFMRD6HUVrR28ga18vwWdU2F2aW9U1pigzWVLs
# z6iLKKECbACq2nI6DVQ9vCk7fZapcFWl/ao5PnImUSwLFOhcRgt5imtKaiNtR6iI
# ji2IMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEOBTIPowUIS/TjAUXfMn2oIwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FCsD9rvCXN64WX1It8OzcN/x7uIAMA0GCSqGSIb3DQEBAQUABIGAnob3sCrc12Di
# td9mHSjCfLd2XR+Csj9v4dOB26vTi+NwDL8gNnfksJyaMv4eA3LQ5RbpeaOoRU28
# uZynxNFMrhoFGciSGNPafwQRefx1r2NEiSr9spEVNugZ+F36eTs00jsJx4CNcU/r
# ai8pXmdtMQ9whffMMiRMxT+0WRPuvS8=
# SIG # End signature block
