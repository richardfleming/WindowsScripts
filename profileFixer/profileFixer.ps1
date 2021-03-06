<######################################################################################
  Filename: profileFilxer.ps1
 
  Version No.: 1.0.0
 
  Revision History
 
  Date           Version     Author             Revision Description            Notes
  ------------------------------------------------------------------------------------ 
  07/19/2012     1.0.0       R.D.Fleming        Initial Check-in ...             [0]
 
 #####################################################################################
 
    Licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
 
 #####################################################################################
 
  Description:
 
 	Checks the Windows registry for backup profiles and renames the temp profile 
    to .bad, and the .bak profile back to the original key name.
    
    
  Script URL:
    
    https://github.com/richardfleming/WindowsScripts/profileFixer
         
  Notes:
 
 	[0] Initial Check-in of script
 
 #####################################################################################>

function Repair-CorruptProfile {
    [cmdletbinding()]  
    Param()  
    
    Set-Location "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

    Write-Verbose "Fetching backup profile object"
    $objGoodRegistryKey = Get-ChildItem -Recurse -Include *bak
    $objPopup = New-Object -ComObject wscript.shell


    # Check to see if our object isn't null and proceed
    if ($objGoodRegistryKey) {
        Write-Verbose "Backup profile found!"
        Write-Debug $objGoodRegistryKey

        # Get the temp profile key (which is also the name of the original profile)
        $objOriginalRegistryKey = Get-ChildItem -Path . -Recurse -Include $objGoodRegistryKey.PSChildName.Split(".bak")

        # Set the name for the bad
        $strBadRegistryKey = $objOriginalRegistryKey.PSChildName + ".bad"
        if (Test-Path $strBadRegistryKey) {
            Write-Verbose "Found bad profile in registry, deleting."
            Remove-Item $strBadRegistryKey 
        }
        Write-Verbose "Renaming temp profile and labeling as bad"
        Rename-Item  $objOriginalRegistryKey.PSChildName -NewName $strBadRegistryKey 
        Write-Verbose "Renaming backup profile to original name"
        Rename-Item $objGoodRegistryKey.PSChildName -NewName $objOriginalRegistryKey.PSChildName 
        $objPopup.Popup("Success!`n`nYour user profile has been fixed!`n`nPlease log out and back in as your regular self.",0,"profileFixer")    

    } else {
        $objPopup.Popup("Nothing to fix.`n`nIf you believe this to be in error, contact your support person.",0,"profileFixer")
    }

}

Repair-CorruptProfile







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