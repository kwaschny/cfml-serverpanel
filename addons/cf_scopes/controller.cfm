<cfsetting enableCFoutputOnly="true">

<!--- remove key from SERVER scope --->
<cfif (
	structKeyExists(FORM, "server_remove") and
	structKeyExists(FORM, "key_pattern") and
	structKeyExists(FORM, "operator")
)>

	<cfset serverKeys   = structKeyArray(SERVER)>
	<cfset keysToRemove = []>

	<cfswitch expression="#FORM["operator"]#">

		<cfcase value="equal">

			<cfloop array="#serverKeys#" index="serverKey">
				<cfif (serverKey eq FORM["key_pattern"]) and (not ATTRIBUTES.admin.isReservedServerKey(serverKey))>
					<cfset keysToRemove.add(serverKey)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="contains">

			<cfloop array="#serverKeys#" index="serverKey">
				<cfif (serverKey contains FORM["key_pattern"]) and (not ATTRIBUTES.admin.isReservedServerKey(serverKey))>
					<cfset keysToRemove.add(serverKey)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="starts">

			<cfloop array="#serverKeys#" index="serverKey">
				<cfif (serverKey.startsWith(FORM["key_pattern"])) and (not ATTRIBUTES.admin.isReservedServerKey(serverKey))>
					<cfset keysToRemove.add(serverKey)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="ends">

			<cfloop array="#serverKeys#" index="serverKey">
				<cfif (serverKey.endsWith(FORM["key_pattern"])) and (not ATTRIBUTES.admin.isReservedServerKey(serverKey))>
					<cfset keysToRemove.add(serverKey)>
				</cfif>
			</cfloop>

		</cfcase>
		<cfcase value="any">

			<cfloop array="#serverKeys#" index="serverKey">
				<cfif not ATTRIBUTES.admin.isReservedServerKey(serverKey)>
					<cfset keysToRemove.add(serverKey)>
				</cfif>
			</cfloop>

		</cfcase>

	</cfswitch>

	<cfloop array="#keysToRemove#" index="serverKey">
		<cfset structDelete(SERVER, serverKey)>
	</cfloop>

</cfif>
