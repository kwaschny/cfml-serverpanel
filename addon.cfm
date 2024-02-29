<cfsetting enableCFoutputOnly="true">

<cfif structKeyExists(URL, "key")>

	<cfset addOn     = URL["key"]>
	<cfset isRefresh = false>

<cfelseif structKeyExists(URL, "fetch")>

	<cfset addOn     = URL["fetch"]>
	<cfset isRefresh = true>

<cfelse>
	<cflocation url="index.cfm" statusCode="303" addToken="false">
</cfif>

<cfmodule template="auth.cfm">

<!--- config --->
<cfmodule template="config.cfm">
<cfif not len(CONFIG.cfAdminPassword)>
	<cfthrow message="You did not specify the server admin password. Check config.cfm for more details.">
</cfif>

<cfset Admin = new Admin(SERVER, CONFIG.cfAdminPassword)>
<cfset Who   = new Who(SERVER)>

<!--- BEGIN: controller --->

	<cfif not structIsEmpty(FORM)>

		<cfset addOnPath = "addons/#addOn#/controller.cfm">

		<cfif fileExists( expandPath(addOnPath) )>
			<cfmodule admin="#Admin#" who="#Who#" template="#addOnPath#">
		</cfif>

		<cflocation url="addon.cfm?key=#urlEncodedFormat(addOn)#" statusCode="303" addToken="false">

	</cfif>

<!--- END: controller --->

<!--- HTML --->
<cfoutput>

	<cfif not isRefresh>

		<meta name="viewport" content="width=device-width">
		<link rel="stylesheet" href="styles.css">

		<section class="panels">
			<div class="panel">

				<div class="controls">
					<div>
						<button type="button" data-refresh="#encodeForHtmlAttribute(addOn)#">
							↻ Refresh
						</button>
					</div>
					<div>
						<button type="button" data-interval="#encodeForHtmlAttribute(addOn)#">
							🗘 Monitor
						</button>
					</div>
				</div>

			<div class="content noscroll">

	</cfif>

	<cfset addOnPath = "addons/#addOn#/view.cfm">

	<cfif fileExists( expandPath(addOnPath) )>
		<cfmodule admin="#Admin#" who="#Who#" template="#addOnPath#">
	<cfelse>
		<span class="lowlight">AddOn Not Found</span>
	</cfif>

	<cfif not isRefresh>

				</div> <!--- content --->

			</div>
		</section>

		<script src="scripts.js"></script>

	</cfif>

</cfoutput>
