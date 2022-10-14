<cfsetting enableCFoutputOnly="true">

<cfset DISPLAY_LIMIT = 10>

<!---------------------------------------------------------------------------->

<cfif not structKeyExists(REQUEST, "Admin.getApplicationStats")>
	<cfset REQUEST["Admin.getApplicationStats"] = ATTRIBUTES.admin.getApplicationStats()>
</cfif>
<cfset appStats = REQUEST["Admin.getApplicationStats"]>

<cfset map = {}>

<cfloop collection="#appStats#" item="appName">

	<cfset userSessions = appStats[appName].Sessions>

	<!--- store visitor's IP in: SESSION._remoteAddress --->
	<cfloop collection="#userSessions#" item="id">

		<cfset userSession = userSessions[id]>

		<cfif not structKeyExists(userSession, "_remoteAddress")>
			<cfcontinue>
		</cfif>

		<cfset remoteAddress = userSession["_remoteAddress"]>

		<cfif not structKeyExists(map, remoteAddress)>
			<cfset map[remoteAddress] = 0>
		</cfif>
		<cfset map[remoteAddress] += 1>

	</cfloop>

</cfloop>

<cfset sorted = structSort(map, "NUMERIC", "DESC")>

<!--- HTML --->
<cfoutput>

	<div class="iis_iptable">

		<h2>
			Sessions by IP <small class="lowlight">#arrayLen(sorted)#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>IP</th>
					<th class="number">Sessions</th>
					<th></th>
				</tr>
			</thead>
			<tbody>
				<cfif not arrayIsEmpty(sorted)>

					<cfset i = 0>
					<cfloop array="#sorted#" index="ip">
						<cfset i += 1>

						<cfset count = map[ip]>

						<tr>
							<td>
								<!--- https://apps.db.ripe.net/db-web-ui/query?searchtext= --->
								<a href="https://search.arin.net/rdap/?query=#ip#" target="_blank" rel="noreferrer">
									#REQUEST.Util.getHostNameByIP(ip)#
								</a>
							</td>
							<td class="number">
								#count#
							</td>
							<td align="center">
								<form method="post">
									<button type="submit" name="iptable_ban" value="#ip#">
										Ban IP
									</button>
								</form>
							</td>
						</tr>

						<cfif i gte DISPLAY_LIMIT>
							<cfbreak>
						</cfif>

					</cfloop>

				<cfelse>
					<tr>
						<td colspan="3" class="lowlight">
							no sessions found
						</td>
					</tr>
				</cfif>
			</tbody>
			<tfoot>
				<tr>
					<th>IP</th>
					<th class="number">Sessions</th>
					<th></th>
				</tr>
			</tfoot>
		</table>

	</div>

</cfoutput>
