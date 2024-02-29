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

							<cfset LOCAL.sessionScopes = LOCAL.scopeContext.getAllSessionScopes(LOCAL.appName)>

							<cfset LOCAL.result[LOCAL.appName] = {
								ApplicationName: LOCAL.appName,
								Sessions:        LOCAL.sessionScopes,
								SessionCount:    structCount(LOCAL.sessionScopes)
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

						<cfset LOCAL.sessionScopes = LOCAL.sessionTracker.getSessionCollection(LOCAL.appName)>

						<cfset LOCAL.result[LOCAL.appName] = {
							ApplicationName: LOCAL.appName,
							Sessions:        LOCAL.sessionScopes,
							SessionCount:    structCount(LOCAL.sessionScopes)
						}>

					</cfloop>

				</cfcase>

				<cfcase value="ACF_Post11">
					<!--- TODO: Where is the API documentation for "Performance Monitoring Toolset" ?! --->
				</cfcase>

			</cfswitch>

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="getCpuStats"         access="public" output="false" returnType="struct">

			<cfset LOCAL.result = {}>

			<cfset LOCAL.OS = createObject("java", "java.lang.management.ManagementFactory").getOperatingSystemMXBean()>

			<cfset LOCAL.result.Cores       = LOCAL.OS.getAvailableProcessors()>
			<cfset LOCAL.result.Utilization = decimalFormat( LOCAL.OS.getSystemLoadAverage() )>
			<cfset LOCAL.result.UtilType    = ( (LOCAL.result.Utilization gte 0.00) ? "L" : "" )>

			<cfif LOCAL.result.Utilization lt 0>
				<cftry>

					<cfexecute

						name="PowerShell"
						arguments="(Get-WmiObject Win32_Processor).LoadPercentage"

						timeout="2"

						variable="LOCAL.out"
					>
					</cfexecute>

					<cfset LOCAL.result.Utilization = trim(LOCAL.out)>
					<cfset LOCAL.result.UtilType    = "%">

					<cfcatch>
					</cfcatch>
				</cftry>
			</cfif>

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="getDiskStats"        access="public" output="false" returnType="array">

			<cfset LOCAL.result   = []>
			<cfset LOCAL.sumFree  = 0>
			<cfset LOCAL.sumTotal = 0>

			<cfset LOCAL.disks = createObject("java", "java.io.File").listRoots()>
			<cfloop array="#LOCAL.disks#" index="LOCAL.disk">

				<cfset LOCAL.usable = disk.getUsableSpace()>
				<cfset LOCAL.total  = disk.getTotalSpace()>

				<cfset LOCAL.result.add({
					Name:  disk.toString(),
					Free:  LOCAL.usable,
					Total: LOCAL.total
				})>

				<cfset LOCAL.sumFree  += LOCAL.usable>
				<cfset LOCAL.sumTotal += LOCAL.total>

			</cfloop>

			<cfset LOCAL.result.add(javaCast("int", 0), {
				Name:  "",
				Free:  LOCAL.sumFree,
				Total: LOCAL.sumTotal
			})>

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

		<cffunction name="getThreadStats"      access="public" output="false" returnType="struct">

			<cfargument name="filter"   type="string"  default="" hint="regular expression">
			<cfargument name="maxDepth" type="numeric" default="100">

			<cfset LOCAL.result           = {}>
			<cfset LOCAL.result.Threads   = []>
			<cfset LOCAL.result.Count     = 0>
			<cfset LOCAL.result.Daemons   = 0>
			<cfset LOCAL.result.Runnable  = 0>
			<cfset LOCAL.result.Blocked   = 0>
			<cfset LOCAL.result.Waiting   = 0>
			<cfset LOCAL.result.Deadlocks = 0>

			<cfset LOCAL.filterByName = (len(ARGUMENTS.filter) gt 0)>

			<cfset LOCAL.threadBean = createObject("java", "java.lang.management.ManagementFactory").getThreadMXBean()>
			<cfset LOCAL.threadIDs = LOCAL.threadBean.getAllThreadIds()>

			<cfset LOCAL.result.Daemons = LOCAL.threadBean.getDaemonThreadCount()>

			<cfset LOCAL.buffer = LOCAL.threadBean.findDeadlockedThreads()>
			<cfset LOCAL.result.Deadlocks = ( isNull(LOCAL.buffer) ? 0 : arrayLen(LOCAL.buffer) )>

			<cfset LOCAL.result.Count = LOCAL.threadBean.getThreadCount()>

			<cfloop array="#LOCAL.threadIDs#" index="LOCAL.threadID">

				<!--- without stacktrace --->
				<cfset LOCAL.threadInfo = LOCAL.threadBean.getThreadInfo(LOCAL.threadID)>
				<cfif isNull(LOCAL.threadInfo)>
					<cfcontinue>
				</cfif>

				<cfswitch expression="#LOCAL.threadInfo.getThreadState()#">
					<cfcase value="RUNNABLE">
						<cfset LOCAL.result.Runnable++>
					</cfcase>
					<cfcase value="BLOCKED">
						<cfset LOCAL.result.Blocked++>
					</cfcase>
					<cfcase value="WAITING TIMED_WAITING" delimiters=" ">
						<cfset LOCAL.result.Waiting++>
					</cfcase>
				</cfswitch>

				<cfif LOCAL.filterByName>

					<cfset LOCAL.threadName = LOCAL.threadInfo.getThreadName()>
					<cfif not reFindNoCase(ARGUMENTS.filter, LOCAL.threadName)>
						<cfcontinue>
					</cfif>

				</cfif>

				<!--- with stacktrace --->
				<cfset LOCAL.threadInfo = LOCAL.threadBean.getThreadInfo(LOCAL.threadID, ARGUMENTS.maxDepth)>

				<cfif not isNull(LOCAL.threadInfo)>
					<cfset LOCAL.result.Threads.add(LOCAL.threadInfo)>
				</cfif>

			</cfloop>

			<cfreturn LOCAL.result>
		</cffunction>

		<cffunction name="isAdobeCF"           access="public" output="false" returnType="boolean">

			<cfreturn (find("ACF_", VARIABLES.adminAPI) eq 1)>
		</cffunction>

		<cffunction name="isLuceeCF"           access="public" output="false" returnType="boolean">

			<cfreturn (VARIABLES.adminAPI eq "LUCEE")>
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
