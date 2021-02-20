<cfsetting enableCFoutputOnly="true">

<cfif not isDefined("ATTRIBUTES")>
	<cfthrow message="You must not include this file. Use <cfmodule> insead.">
</cfif>

<cfparam name="ATTRIBUTES.variable" type="string" default="password">

<!---------------------------------------------------------------------------->

<!--- enter server admin password and uncomment below --->
<cfset CALLER[ATTRIBUTES.variable] = "">