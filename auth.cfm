<cfsetting enableCFoutputOnly="true">

<cfif not isDefined("ATTRIBUTES")>
	<cfthrow message="You must not include this file. Use <cfmodule> insead.">
</cfif>

<!---------------------------------------------------------------------------->

<!--- if you do not need Basic Authorization, set it to: false --->
<cfset requireBasicAuth = true>

<!--- if you require Basic Authorization, enter the desired credentials here --->
<cfset requiredUsername = ""> <!--- case-insensitive --->
<cfset requiredPassword = ""> <!--- case-sensitive --->

<!---------------------------------------------------------------------------->

<cfif requireBasicAuth>

	<cfif (not len(requiredUsername)) and (not len(requiredPassword))>
		<cfthrow message="You did not specify username and/or password for Basic Auth. Check auth.cfm for more details.">
	</cfif>

	<cfset basicAuth = new Util().getBasicAuth().Credentials>

	<cfset passedAuth = (
		(
			(not len(requiredUsername)) or
			(basicAuth.Username eq requiredUsername)
		)
		and (
			(not len(requiredPassword)) or
			(compare(basicAuth.Password, requiredPassword) eq 0)
		)
	)>

<cfelse>
	<cfset passedAuth = true>
</cfif>

<cfif not passedAuth>

	<cfheader statusCode="401" statusText="Unauthorized">
	<cfheader name="WWW-Authenticate" value='Basic realm="ServerPanel"'>
	<cfabort>

</cfif>