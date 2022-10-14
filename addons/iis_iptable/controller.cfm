<cfsetting enableCFoutputOnly="true">

<cfset APPCMD_PATH = "C:\Windows\System32\inetsrv\appcmd">

<cfif structKeyExists(FORM, "iptable_ban")>

	<cfexecute

		name="#APPCMD_PATH#"
		arguments="set config -section:system.webServer/security/ipSecurity /+""[ipAddress='#FORM["iptable_ban"]#',allowed='False']"""

		timeout="5"
		variable="result"
		errorVariable="error"
	>

</cfif>
