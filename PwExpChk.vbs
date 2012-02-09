'*************************************************************************************
' Filename: PwExpChk.vbs
'
' Version No.: 1.0
'
' Revision History
'
' Date           Version     Author             Revision Description            Notes
' ------------------------------------------------------------------------------------
' 02/09/2012     1.0.0       R.D.Fleming        Initial Checkin ...              [0]
'
'*************************************************************************************
'
'   Licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
'
'*************************************************************************************
'
' Description
'
'	AD logon VBScript to notify user of impending 
'	password expiration via dialogue box
'
' Dependencies:
'
'	May require addition of script path to IE Trusted Sites list
'        
' Notes:
'
'	[0] Initial Checkin of script
'
'************************************************************************************

' Change this variable to desired warning length (in days)
intPopupWarningInDays = 7

' set user info
Set objLoginInfo = CreateObject( "ADSystemInfo" ) 
strUserDN = objLoginInfo.UserName

' set domain info
strDomainDN = UCase( objLoginInfo.DomainDNSName ) 
Set objDomain = GetObject( "LDAP://" & strDomainDN )

' get password info
Set intMaxPwdAge = objDomain.Get( "maxPwdAge" )
Set objUser = GetObject( "LDAP://" & strUserDN )

' Figure out password expiry limit, then figure out when password will expire
intNumDays = CCur( ( intMaxPwdAge.HighPart * 2 ^ 32 ) + intMaxPwdAge.LowPart ) / CCur( -864000000000 )
strWhenPasswordExpires = DateAdd( "d", intNumDays, objUser.PasswordLastChanged )
intDaysLeft = DateDiff( "d", Date, strWhenPasswordExpires )


' Display Popup Warning
if ( intDaysLeft <= intPopupWarningInDays ) and ( intDaysLeft >= 0 ) then
	Msgbox "Password Expires in " & intDaysLeft & " day(s)" & " at " & strWhenPasswordExpires & vbNewLine & vbNewLine & _
	"Press CTRL-ALT-DEL and select the 'Change a password...' option to change your password.", 0, "Password Expiration Notice"
End if