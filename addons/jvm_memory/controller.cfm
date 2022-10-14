<cfsetting enableCFoutputOnly="true">

<!--- trigger garbage collection --->
<cfif structKeyExists(FORM, "gc")>

	<cfset createObject("java", "java.lang.System").gc()>

</cfif>
