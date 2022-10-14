<cfsetting enableCFoutputOnly="true">

<!--- stop application --->
<cfif (
	structKeyExists(FORM, "app_stop") and
	structKeyExists(FORM, "app_pattern") and
	structKeyExists(FORM, "operator")
)>

	<cfset appNames   = structKeyArray( ATTRIBUTES.admin.getApplicationStats() )>
	<cfset appsToStop = []>

	<cfswitch expression="#FORM["operator"]#">

		<cfcase value="equal">

			<cfloop array="#appNames#" index="appName">
				<cfif appName eq FORM["app_pattern"]>
					<cfset appsToStop.add(appName)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="contains">

			<cfloop array="#appNames#" index="appName">
				<cfif appName contains FORM["app_pattern"]>
					<cfset appsToStop.add(appName)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="starts">

			<cfloop array="#appNames#" index="appName">
				<cfif appName.startsWith(FORM["app_pattern"])>
					<cfset appsToStop.add(appName)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="ends">

			<cfloop array="#appNames#" index="appName">
				<cfif appName.endsWith(FORM["app_pattern"])>
					<cfset appsToStop.add(appName)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="any">

			<cfloop array="#appNames#" index="appName">
				<cfset appsToStop.add(appName)>
			</cfloop>

		</cfcase>

	</cfswitch>

	<cfloop array="#appsToStop#" index="appName">

		<cftry>

			<!--- switch to application and stop it --->
			<cfapplication name="#appName#">
			<cfset applicationStop()>

			<cfcatch>
				<!--- race condition: application might no longer exist --->
			</cfcatch>
		</cftry>

	</cfloop>

</cfif>
