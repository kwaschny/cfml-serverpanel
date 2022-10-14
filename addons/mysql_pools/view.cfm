<cfsetting enableCFoutputOnly="true">

<!--- config --->
<cfmodule template="../../config.cfm">
<cfif not len(CONFIG.cfDatasource)>
	<cfexit>
</cfif>

<cftry>

	<cfquery name="lookup" datasource="#CONFIG.cfDatasource#">

		SELECT
			`DB`,
			COUNT(1) AS `connections`

		FROM
			`information_schema`.`processlist`

		WHERE
			`DB` IS NOT NULL

		GROUP BY
			`DB`

		ORDER BY
			`connections` DESC

	</cfquery>

	<cfcatch>
		<cfset lookup = queryNew("")>
	</cfcatch>
</cftry>

<cfset totalConnections = 0>
<cfloop query="lookup">
	<cfset totalConnections += lookup.connections>
</cfloop>

<!--- HTML --->
<cfoutput>

	<div class="mysql_pools">

		<h2>
			SQL Pools <small class="lowlight">#totalConnections#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>Database</th>
					<th class="number">Connections</th>
				</tr>
			</thead>
			<tbody>
				<cfif lookup.recordCount>
					<cfloop query="lookup">
						<tr>
							<td>
								#encodeForHtml(lookup.DB)#
							</td>
							<td class="number">
								#lookup.connections#
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="5" class="lowlight">
							no connections found
						</td>
					</tr>
				</cfif>
			</tbody>
			<tfoot>
				<tr>
					<th>Database</th>
					<th class="number">Connections</th>
				</tr>
			</tfoot>
		</table>

	</div>

</cfoutput>
