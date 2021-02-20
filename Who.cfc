<cfcomponent output="false">

	<!--- BEGIN: public methods --->

		<cffunction name="getColdFusionVendor"   access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "coldfusion") and
				structKeyExists(VARIABLES.scope["coldfusion"], "productname") and
				isSimpleValue(VARIABLES.scope["coldfusion"]["productname"]) and
				(len(VARIABLES.scope["coldfusion"]["productname"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["coldfusion"]["productname"]>
			</cfif>

			<cfreturn "">
		</cffunction>

		<cffunction name="getColdFusionVersion"  access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "lucee") and
				structKeyExists(VARIABLES.scope["lucee"], "version") and
				isSimpleValue(VARIABLES.scope["lucee"]["version"]) and
				(len(VARIABLES.scope["lucee"]["version"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["lucee"]["version"]>
			</cfif>

			<cfif (
				structKeyExists(VARIABLES.scope, "coldfusion") and
				structKeyExists(VARIABLES.scope["coldfusion"], "productversion") and
				isSimpleValue(VARIABLES.scope["coldfusion"]["productversion"]) and
				(len(VARIABLES.scope["coldfusion"]["productversion"]) gt 0)
			)>
				<cfreturn replace(VARIABLES.scope["coldfusion"]["productversion"], ",", ".", "ALL")>
			</cfif>

			<cfreturn "">
		</cffunction>

		<cffunction name="getJavaRuntimeVendor"  access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "java") and
				structKeyExists(VARIABLES.scope["java"], "vendor") and
				isSimpleValue(VARIABLES.scope["java"]["vendor"]) and
				(len(VARIABLES.scope["java"]["vendor"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["java"]["vendor"]>
			</cfif>

			<cfif (
				structKeyExists(VARIABLES.scope, "system") and
				structKeyExists(VARIABLES.scope["system"], "properties") and
				structKeyExists(VARIABLES.scope["system"]["properties"], "java.vendor") and
				isSimpleValue(VARIABLES.scope["system"]["properties"]["java.vendor"]) and
				(len(VARIABLES.scope["system"]["properties"]["java.vendor"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["system"]["properties"]["java.vendor"]>
			</cfif>

			<cfreturn getSystemProperty("java.vendor")>
		</cffunction>

		<cffunction name="getJavaRuntimeVersion" access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "java") and
				structKeyExists(VARIABLES.scope["java"], "version") and
				isSimpleValue(VARIABLES.scope["java"]["version"]) and
				(len(VARIABLES.scope["java"]["version"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["java"]["version"]>
			</cfif>

			<cfif (
				structKeyExists(VARIABLES.scope, "system") and
				structKeyExists(VARIABLES.scope["system"], "properties") and
				structKeyExists(VARIABLES.scope["system"]["properties"], "java.version") and
				isSimpleValue(VARIABLES.scope["system"]["properties"]["java.version"]) and
				(len(VARIABLES.scope["system"]["properties"]["java.version"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["system"]["properties"]["java.version"]>
			</cfif>

			<cfreturn getSystemProperty("java.version")>
		</cffunction>

		<cffunction name="getJavaVmVendor"       access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "system") and
				structKeyExists(VARIABLES.scope["system"], "properties") and
				structKeyExists(VARIABLES.scope["system"]["properties"], "java.vm.name") and
				isSimpleValue(VARIABLES.scope["system"]["properties"]["java.vm.name"]) and
				(len(VARIABLES.scope["system"]["properties"]["java.vm.name"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["system"]["properties"]["java.vm.name"]>
			</cfif>

			<cfreturn getSystemProperty("java.vm.name")>
		</cffunction>

		<cffunction name="getJavaVmVersion"      access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "system") and
				structKeyExists(VARIABLES.scope["system"], "properties") and
				structKeyExists(VARIABLES.scope["system"]["properties"], "java.vm.version") and
				isSimpleValue(VARIABLES.scope["system"]["properties"]["java.vm.version"]) and
				(len(VARIABLES.scope["system"]["properties"]["java.vm.version"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["system"]["properties"]["java.vm.version"]>
			</cfif>

			<cfreturn getSystemProperty("java.vm.version")>
		</cffunction>

		<cffunction name="getOpSystemName"       access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "os") and
				structKeyExists(VARIABLES.scope["os"], "hostname") and
				isSimpleValue(VARIABLES.scope["os"]["hostname"]) and
				(len(VARIABLES.scope["os"]["hostname"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["os"]["hostname"]>
			</cfif>

			<cfif (
				structKeyExists(VARIABLES.scope, "system") and
				structKeyExists(VARIABLES.scope["system"], "environment") and
				structKeyExists(VARIABLES.scope["system"]["environment"], "COMPUTERNAME") and
				isSimpleValue(VARIABLES.scope["system"]["environment"]["COMPUTERNAME"]) and
				(len(VARIABLES.scope["system"]["environment"]["COMPUTERNAME"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["system"]["environment"]["COMPUTERNAME"]>
			</cfif>

			<cfset LOCAL.name = getEnvironmentVar("COMPUTERNAME")>
			<cfif len(LOCAL.name)>
				<cfreturn LOCAL.name>
			</cfif>

			<cfset LOCAL.name = getEnvironmentVar("HOSTNAME")>
			<cfif len(LOCAL.name)>
				<cfreturn LOCAL.name>
			</cfif>

			<cfreturn createObject("java", "java.net.InetAddress").localhost.getCanonicalHostName()>
		</cffunction>

		<cffunction name="getOpSystemVendor"     access="public" output="false" returnType="string">

			<cfif (
				structKeyExists(VARIABLES.scope, "os") and
				structKeyExists(VARIABLES.scope["os"], "name") and
				isSimpleValue(VARIABLES.scope["os"]["name"]) and
				(len(VARIABLES.scope["os"]["name"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["os"]["name"]>
			</cfif>

			<cfreturn getSystemProperty("os.name")>
		</cffunction>

		<cffunction name="getOpSystemVersion"    access="public" output="false" returnType="string">

			<cfset LOCAL.opSystemVendor = getOpSystemVendor()>
			<cfif reFind("\s[0-9]+[0-9/.-]*$", LOCAL.opSystemVendor)>
				<cfreturn "">
			</cfif>

			<cfif (
				structKeyExists(VARIABLES.scope, "os") and
				structKeyExists(VARIABLES.scope["os"], "version") and
				isSimpleValue(VARIABLES.scope["os"]["version"]) and
				(len(VARIABLES.scope["os"]["version"]) gt 0)
			)>
				<cfreturn VARIABLES.scope["os"]["version"]>
			</cfif>

			<cfreturn getSystemProperty("os.version")>
		</cffunction>

		<cffunction name="getServlet"            access="public" output="false" returnType="string">

			<cfset LOCAL.servlet = "">

			<cfif (
				structKeyExists(VARIABLES.scope, "servlet") and
				structKeyExists(VARIABLES.scope["servlet"], "name") and
				isSimpleValue(VARIABLES.scope["servlet"]["name"]) and
				(len(VARIABLES.scope["servlet"]["name"]) gt 0)
			)>
				<cfset LOCAL.servlet = VARIABLES.scope["servlet"]["name"]>
			<cfelseif (
				structKeyExists(VARIABLES.scope, "coldfusion") and
				structKeyExists(VARIABLES.scope["coldfusion"], "appserver") and
				isSimpleValue(VARIABLES.scope["coldfusion"]["appserver"]) and
				(len(VARIABLES.scope["coldfusion"]["appserver"]) gt 0)
			)>
				<cfset LOCAL.servlet = VARIABLES.scope["coldfusion"]["appserver"]>
			</cfif>

			<cfif LOCAL.servlet neq "J2EE">
				<cfreturn LOCAL.servlet>
			</cfif>

			<cfreturn getPageContext().getServletContext().getServerInfo()>
		</cffunction>

	<!--- END: public methods --->

	<!--- BEGIN: private methods --->

		<cffunction name="getEnvironmentVar" access="private" output="false" returnType="string">

			<cfargument name="varName" type="string" required="true">

			<cftry>

					<cfset LOCAL.env = createObject("java", "java.lang.System").getEnv()>
					<cfif structKeyExists(LOCAL.env, ARGUMENTS.varName)>
						<cfreturn LOCAL.env[ARGUMENTS.varName]>
					</cfif>

				<cfcatch>
				</cfcatch>
			</cftry>

			<cfreturn "">
		</cffunction>

		<cffunction name="getSystemProperty" access="private" output="false" returnType="string">

			<cfargument name="propertyName" type="string" required="true">

			<cftry>

					<cfset LOCAL.prop = createObject("java", "java.lang.System").getProperty(ARGUMENTS.propertyName)>
					<cfif not isNull(LOCAL.prop)>
						<cfreturn LOCAL.prop>
					</cfif>

				<cfcatch>
				</cfcatch>
			</cftry>

			<cfreturn "">
		</cffunction>

	<!--- END: private methods --->

	<cfset VARIABLES.scope = {}>

	<!--- constructor --->
	<cffunction name="init" access="public" output="false" returnType="any">

		<cfargument name="serverScope" type="struct" required="true">

		<cfset VARIABLES.scope = ARGUMENTS.serverScope>

		<cfreturn THIS>
	</cffunction>

</cfcomponent>