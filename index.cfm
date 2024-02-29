<cfsetting enableCFoutputOnly="true">

<cfmodule template="auth.cfm">

<!--- config --->
<cfmodule template="config.cfm">
<cfif not len(CONFIG.cfAdminPassword)>
	<cfthrow message="You did not specify the server admin password. Check config.cfm for more details.">
</cfif>

<cfset Admin  = new Admin(SERVER, CONFIG.cfAdminPassword)>
<cfset Who    = new Who(SERVER)>
<cfset addOns = directoryList(expandPath("addons"), false, "NAME")>

<cfset isWindows = (Who.getOpSystemVendor() contains "Windows")>

<!--- BEGIN: controller --->

	<cfif not structIsEmpty(FORM)>

		<cfloop array="#addOns#" index="addOn">

			<!--- ignore files with leading underscore --->
			<cfif find("_", addOn) eq 1>
				<cfcontinue>
			</cfif>

			<cfset addOnPath = "addons/#addOn#/controller.cfm">

			<cfif fileExists( expandPath(addOnPath) )>
				<cfmodule admin="#Admin#" who="#Who#" template="#addOnPath#">
			</cfif>

		</cfloop>

		<cflocation url="index.cfm" statusCode="303" addToken="false">

	</cfif>

<!--- END: controller --->

<!--- prefix the folder to disable an add-on --->
<cfset addOnOrder = [
	"cf_requests",
	"jvm_memory",
	[ "os", ( isWindows ? "lazy" : "eager" ) ],
	"cf_apps",
	"iis_iptable",
	"mysql_pools",
	"mysql_queries",
	"mysql_monitor",
	"cf_scopes",
	"server"
]>
<cfif arrayIsEmpty(addOnOrder)>
	<cfset addOnOrder = addOns>
</cfif>

<cfset lazyAddOns = []>

<!--- HTML --->
<cfoutput>

	<meta name="viewport" content="width=device-width">
	<link rel="stylesheet" href="styles.css">

	<h1>
		<a href="">&##128421; ServerPanel</a>
	</h1>

	<section class="panels">
		<cfloop array="#addOnOrder#" index="addOn">

			<cfset isLazy = false>
			<cfif isArray(addOn)>
				<cfset isLazy = arrayFindNoCase(addOn, "lazy")>
				<cfset addOn  = addOn[1]>
			</cfif>

			<!--- ignore files with leading underscore --->
			<cfif find("_", addOn) eq 1>
				<cfcontinue>
			</cfif>

			<cfif isLazy>
				<cfset lazyAddOns.add(addOn)>
			</cfif>

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
						<button type="button" data-href="addon.cfm?key=#urlEncodedFormat(addOn)#" data-target="_blank">
							⤯ Open
						</button>
					</div>
				</div>

				<div class="content">

					<cfset addOnPath = "addons/#addOn#/view.cfm">

					<cfif fileExists( expandPath(addOnPath) )>
						<cfmodule admin="#Admin#" who="#Who#" lazy="#isLazy#" template="#addOnPath#">
					<cfelse>
						<span class="lowlight">AddOn Not Found</span>
					</cfif>

				</div>

			</div>

		</cfloop>
	</section>

	<script src="scripts.js"></script>
	<script>

		// request lazy modules
		window.addEventListener('DOMContentLoaded', () => {
			<cfloop array="#lazyAddOns#" index="addOn">

				const button = document.querySelector('button[data-refresh="#addOn#"]');
				if (button !== null) {
					button.dispatchEvent( new MouseEvent('click') );
				}

			</cfloop>
		});

	</script>

</cfoutput>
