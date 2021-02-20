<cfcomponent output="false">

	<!--- BEGIN: public methods --->

		<cffunction name="getApplicationStats" access="public" output="false" returnType="struct">

			<cfset LOCAL.result = {}>

			<cfswitch expression="#VARIABLES.adminAPI#">

				<cfcase value="LUCEE">

					<cfset LOCAL.configWebs = getPageContext().getConfig().getConfigServer(VARIABLES.password).getConfigWebs()>
					<cfloop collection="#LOCAL.configWebs#" item="LOCAL.configWeb">

						<cfset LOCAL.config       = LOCAL.configWebs[LOCAL.configWeb]>
						<cfset LOCAL.scopeContext = LOCAL.config.getFactory().getScopeContext()>
						<cfset LOCAL.appScopes    = LOCAL.scopeContext.getAllApplicationScopes()>

						<cfloop collection="#LOCAL.appScopes#" item="LOCAL.appName">

							<cfif isInternalApp(LOCAL.appName)>
								<cfcontinue>
							</cfif>

							<cfset LOCAL.result[LOCAL.appName] = {
								ApplicationName: LOCAL.appName,
								SessionCount:    structCount( LOCAL.scopeContext.getAllSessionScopes(LOCAL.appName) )
							}>

						</cfloop>

					</cfloop>

				</cfcase>

				<cfcase value="ACF_Pre16">

					<cfset new CFIDE.AdminAPI.Administrator().login(VARIABLES.password)>
					<cfset LOCAL.monitor        = new CFIDE.AdminAPI.ServerMonitoring()>
					<cfset LOCAL.appScopes      = LOCAL.monitor.getAllApplicationScopesMemoryUsed()>
					<cfset LOCAL.sessionTracker = createObject("java", "coldfusion.runtime.SessionTracker")>

					<cfloop collection="#LOCAL.appScopes#" item="LOCAL.appName">

						<cfset LOCAL.result[LOCAL.appName] = {
							ApplicationName: LOCAL.appName,
							SessionCount:    structCount( LOCAL.sessionTracker.getSessionCollection(LOCAL.appName) )
						}>

					</cfloop>

				</cfcase>

				<cfcase value="ACF_Post11">
					<!--- TODO: Where is the API documentation for "Performance Monitoring Toolset" ?! --->
				</cfcase>

			</cfswitch>

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="getMemoryStats"      access="public" output="false" returnType="struct">

			<cfset LOCAL.result = {}>

			<cfset LOCAL.Runtime = createObject("java", "java.lang.Runtime").getRuntime()>

			<cfset LOCAL.result.TotalMemory = max(0, LOCAL.Runtime.totalMemory())>
			<cfset LOCAL.result.FreeMemory  = max(0, LOCAL.Runtime.freeMemory())>
			<cfset LOCAL.result.UsedMemory  = (LOCAL.result.TotalMemory - LOCAL.result.FreeMemory)>
			<cfset LOCAL.result.MemoryPool  = createObject("java", "java.lang.management.ManagementFactory").getMemoryPoolMXBeans()>

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="isReservedServerKey" access="public" output="false" returnType="boolean">

			<cfargument name="key" type="string" required="true">

			<cfreturn arrayFindNoCase([

				"coldfusion",
				"java",
				"lucee",
				"os",
				"separator",
				"servlet",
				"system"

			], ARGUMENTS.key) gte 1>
		</cffunction>

	<!--- END: public methods --->

	<!--- BEGIN: private methods --->

		<cffunction name="determineColdFusionEngine" access="private" output="false" returnType="string">

			<cfargument name="scope" type="struct" required="true">

			<cfif (
				structKeyExists(ARGUMENTS.scope, "coldfusion") and
				structKeyExists(ARGUMENTS.scope["coldfusion"], "productname") and
				isSimpleValue(ARGUMENTS.scope["coldfusion"]["productname"])
			)>
				<cfif ARGUMENTS.scope["coldfusion"]["productname"] contains "Lucee">
					<cfreturn "LUCEE">
				<cfelseif ARGUMENTS.scope["coldfusion"]["productname"] contains "ColdFusion">

					<cfif (
						structKeyExists(ARGUMENTS.scope, "coldfusion") and
						structKeyExists(ARGUMENTS.scope["coldfusion"], "productversion") and
						isSimpleValue(ARGUMENTS.scope["coldfusion"]["productversion"]) and
						isNumeric( listFirst(ARGUMENTS.scope["coldfusion"]["productversion"]) )
					)>
						<cfif listFirst(ARGUMENTS.scope["coldfusion"]["productversion"]) lt 2016>
							<cfreturn "ACF_Pre16">
						<cfelse>
							<cfreturn "ACF_Post11">
						</cfif>
					</cfif>

				</cfif>
			</cfif>

			<cfthrow message="Unable to determine ColdFusion version to use for administrative access.">
		</cffunction>

		<cffunction name="isInternalApp"             access="private" output="false" returnType="boolean">

			<cfargument name="appName" type="string" required="true">

			<cfreturn (
				(find("__", ARGUMENTS.appName) eq 1) or
				(find("lucee_", ARGUMENTS.appName) eq 1) or
				(find("webadmin", ARGUMENTS.appName) eq 1)
			)>
		</cffunction>

	<!--- END: private methods --->

	<cfset VARIABLES.adminAPI = "">
	<cfset VARIABLES.password = "">

	<!--- constructor --->
	<cffunction name="init" access="public" output="false" returnType="any">

		<cfargument name="serverScope"    type="struct" required="true">
		<cfargument name="serverPassword" type="string" required="true">

		<cfset VARIABLES.adminAPI = determineColdFusionEngine(ARGUMENTS.serverScope)>
		<cfset VARIABLES.password = ARGUMENTS.serverPassword>

		<cfreturn THIS>
	</cffunction>

</cfcomponent>