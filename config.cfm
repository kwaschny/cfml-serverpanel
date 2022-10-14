<cfsetting enableCFoutputOnly="true">

<cfif not isDefined("ATTRIBUTES")>
	<cfthrow message="You must not include this file. Use <cfmodule> insead.">
</cfif>

<cfparam name="ATTRIBUTES.variable" type="string" default="CONFIG">

<cfset CALLER[ATTRIBUTES.variable] = {}>

<!---------------------------------------------------------------------------->

<!--- enter server admin password --->
<cfset CALLER[ATTRIBUTES.variable]["cfAdminPassword"] = "">

<!--- enter datasource to query against database --->
<cfset CALLER[ATTRIBUTES.variable]["cfDatasource"] = "">
