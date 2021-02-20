<cfcomponent output="false">

	<!--- BEGIN: public methods --->

		<cffunction name="getBasicAuth"   access="public" output="false" returnType="struct">

			<cfargument name="httpRequest" type="any" default="#getHttpRequestData()#">

			<cfset LOCAL.result = {

				Authorization: {

					Method:  "",
					Encoded: "",
					Decoded: ""

				},

				Credentials: {

					Username: "",
					Password: ""

				}

			}>

			<cfif isSimpleValue(ARGUMENTS.httpRequest)>

				<cfset LOCAL.hasPrefix = (findNoCase("Basic", ARGUMENTS.httpRequest) eq 1)>

				<cfif LOCAL.hasPrefix>
					<cfset LOCAL.buffer = replace(ARGUMENTS.httpRequest, "Basic", "")>
				<cfelse>
					<cfset LOCAL.buffer = ARGUMENTS.httpRequest>
				</cfif>
				<cfset LOCAL.buffer = trim(LOCAL.buffer)>

				<cfif LOCAL.buffer contains ":">
					<cfset LOCAL.buffer = toBase64(LOCAL.buffer)>
				</cfif>

				<cfset ARGUMENTS.httpRequest = {
					"headers": {
						"Authorization": ("Basic " & LOCAL.buffer)
					}
				}>

			</cfif>

			<cfif not isStruct(ARGUMENTS.httpRequest)>
				<cfreturn LOCAL.result>
			</cfif>

			<cfif structKeyExists(ARGUMENTS.httpRequest, "Authorization")>
				<cfset ARGUMENTS.httpRequest = {
					"headers": ARGUMENTS.httpRequest
				}>
			</cfif>

			<cfif (
				(not structKeyExists(ARGUMENTS.httpRequest, "headers")) or
				(not isStruct(ARGUMENTS.httpRequest["headers"])) or
				(not structKeyExists(ARGUMENTS.httpRequest["headers"], "Authorization")) or
				(not isSimpleValue(ARGUMENTS.httpRequest["headers"]["Authorization"]))
			)>
				<cfreturn LOCAL.result>
			</cfif>

			<cfset LOCAL.buffer = trim(ARGUMENTS.httpRequest["headers"]["Authorization"])>

			<!--- BasicAuth --->
			<cfif not reFindNoCase("^Basic .+", LOCAL.buffer)>
				<cfreturn LOCAL.result>
			</cfif>

			<cfset LOCAL.result.Authorization.Method  = "Basic">
			<cfset LOCAL.result.Authorization.Encoded = right(LOCAL.buffer, len(LOCAL.buffer) - 6)>

			<!--- BEGIN: decode --->

				<cftry>

					<cfset LOCAL.result.Authorization.Decoded = toString(
						toBinary(LOCAL.result.Authorization.Encoded)
					)>

					<cfcatch>
						<cfreturn LOCAL.result>
					</cfcatch>
				</cftry>

			<!--- END: decode --->

			<!--- BEGIN: credentials --->

				<cfset LOCAL.length = len(LOCAL.result.Authorization.Decoded)>

				<cfif LOCAL.length eq 1>
					<cfreturn LOCAL.result>
				</cfif>

				<cfset LOCAL.split = find(":", LOCAL.result.Authorization.Decoded)>

				<!--- :password --->
				<cfif LOCAL.split eq 1>

					<cfset LOCAL.result.Credentials.Username = "">
					<cfset LOCAL.result.Credentials.Password = right(LOCAL.result.Authorization.Decoded, LOCAL.length - 1)>

				<!--- username: --->
				<cfelseif LOCAL.split eq LOCAL.length>

					<cfset LOCAL.result.Credentials.Username = left(LOCAL.result.Authorization.Decoded, LOCAL.split - 1)>
					<cfset LOCAL.result.Credentials.Password = "">

				<!--- username:password --->
				<cfelse>

					<cfset LOCAL.result.Credentials.Username = left(LOCAL.result.Authorization.Decoded, LOCAL.split - 1)>
					<cfset LOCAL.result.Credentials.Password = right(LOCAL.result.Authorization.Decoded, (LOCAL.length - len(LOCAL.result.Credentials.Username) - 1))>

				</cfif>

			<!--- END: credentials --->

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="stringifyBytes" access="public" output="false" returnType="string">

			<cfargument name="bytes" type="numeric" required="true">

			<cfset LOCAL.bytes = ARGUMENTS.bytes>
			<cfset LOCAL.depth = 1>

			<cfset LOCAL.units = [
					"B",
					"KB",
					"MB",
					"GB",
					"TB"
				]>

			<cfloop condition="LOCAL.bytes gte 1000">
				<cfset LOCAL.bytes /= 1000>
				<cfset LOCAL.depth++>
			</cfloop>

			<!--- round --->
			<cfif LOCAL.depth gte 2>
				<cfset LOCAL.bytes = numberFormat(LOCAL.bytes, "0.00")>
			</cfif>

			<cfif LOCAL.depth gt arrayLen(LOCAL.units)>
				<cfreturn LOCAL.bytes>
			</cfif>

			<cfreturn (LOCAL.bytes & " " & LOCAL.units[LOCAL.depth])>
		</cffunction>

	<!--- END: public methods --->

</cfcomponent>