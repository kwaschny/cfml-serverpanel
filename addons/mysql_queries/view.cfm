<cfsetting enableCFoutputOnly="true">

<cfset lookup = queryNew("")>

<!--- config --->
<cfmodule template="../../config.cfm">
<cfif len(CONFIG.cfDatasource)>
	<cftry>

		<cfquery name="lookup" datasource="#CONFIG.cfDatasource#">

			SELECT
				SUBSTRING_INDEX(`HOST`, ':', 1) AS `host`,
				COUNT(1) AS `queries`

			FROM
				`information_schema`.`processlist`

			WHERE
				`COMMAND` = 'Query'

			GROUP BY
				SUBSTRING_INDEX(`HOST`, ':', 1)

			ORDER BY
				`queries` DESC

		</cfquery>

		<cfcatch>
		</cfcatch>
	</cftry>
</cfif>

<cfset totalQueries = 0>
<cfloop query="lookup">
	<cfset totalQueries += lookup.queries>
</cfloop>

<!--- HTML --->
<cfoutput>

	<div class="mysql_queries">

		<h2>
			SQL Queries by Host <small class="lowlight">#totalQueries#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>Host</th>
					<th class="number">Queries</th>
				</tr>
			</thead>
			<tbody>
				<cfif lookup.recordCount>
					<cfloop query="lookup">
						<tr>
							<td>
								#REQUEST.Util.getHostNameByIP(lookup.host)#
							</td>
							<td class="number">
								#lookup.queries#
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="5" class="lowlight">
							no active queries
						</td>
					</tr>
				</cfif>
			</tbody>
			<tfoot>
				<tr>
					<th>Host</th>
					<th class="number">Queries</th>
				</tr>
			</tfoot>
		</table>

	</div>

</cfoutput>
