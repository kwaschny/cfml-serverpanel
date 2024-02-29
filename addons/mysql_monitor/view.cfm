<cfsetting enableCFoutputOnly="true">

<cfset lookup = queryNew("")>

<!--- config --->
<cfmodule template="../../config.cfm">
<cfif len(CONFIG.cfDatasource)>

	<cftry>

		<cfquery name="lookup" datasource="#CONFIG.cfDatasource#">

			SELECT
				`USER`,
				SUBSTRING_INDEX(`HOST`, ':', 1) AS `host`,
				`DB`,
				`STATE`,
				`TIME_MS`,
				`MEMORY_USED`,
				`INFO`

			FROM
				`information_schema`.`processlist`

			WHERE
					`COMMAND`  = 'Query'
				AND `STATE`   <> 'Filling schema table'

			ORDER BY
				`TIME_MS` DESC

		</cfquery>

		<cfcatch>
		</cfcatch>
	</cftry>
</cfif>

<!--- HTML --->
<cfoutput>

	<div class="mysql_monitor">

		<h2>
			SQL Monitor <small class="lowlight">#lookup.recordCount#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>Time</th>
					<th class="number">Memory</th>
					<th>State</th>
					<th>DB</th>
					<th>Statement</th>
				</tr>
			</thead>
			<tbody>
				<cfif lookup.recordCount>
					<cfloop query="lookup">

						<cfset display = '<span class="ok">#ceiling(lookup.TIME_MS)# ms</span>'>
						<cfif lookup.TIME_MS gte 1000>
							<cfset display  = '<span class="bad">#ceiling(lookup.TIME_MS / 1000)# s</span>'>
						</cfif>
						<cfif lookup.TIME_MS gte 60000>
							<cfset display = '<span class="bad">#int(lookup.TIME_MS / 60000)# m, #((lookup.TIME_MS / 1000) % 60)# s</span>'>
						</cfif>

						<tr>
							<td class="time">
								#display#
							</td>
							<td class="small number">
								#stringifyBytes(lookup.MEMORY_USED)#
							</td>
							<td class="small">
								#encodeForHtml(lookup.STATE)#
							</td>
							<td class="small">
								#encodeForHtml(lookup.DB)#<br>
								#encodeForHtml(lookup.USER)# @ #encodeForHtml(lookup.host)#
							</td>
							<td class="stmt">
								#encodeForHtml(lookup.INFO)#
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
					<th>Time</th>
					<th class="number">Memory</th>
					<th>State</th>
					<th>DB</th>
					<th>Statement</th>
				</tr>
			</tfoot>
		</table>

		<style>

			.panel .mysql_monitor {
				width: 100%;
			}

				.panel .mysql_monitor td {
					vertical-align: top;
				}
					.panel .mysql_monitor td.small {
						font-size: 80%;
					}

				.panel .mysql_monitor .time {
					white-space: nowrap;
				}

					.panel .mysql_monitor .time .ok {
						color: ##00C000;
					}
					.panel .mysql_monitor .time .bad {
						color: ##FF0000;
						font-weight: bold;
					}

				.panel .mysql_monitor .number {
					white-space: nowrap;
				}

				.panel .mysql_monitor .stmt {
					font-size: 70%;
					overflow-wrap: anywhere;
				}

		</style>

	</div>

</cfoutput>

<cffunction name="stringifyBytes" access="private" output="false" returnType="string">

	<cfargument name="bytes" type="any"    required="true">
	<cfargument name="unit"  type="string" default="MB">

	<cfset LOCAL.bytes = ( isNumeric(ARGUMENTS.bytes) ? ARGUMENTS.bytes : 0 )>
	<cfset LOCAL.depth = 1>

	<cfset LOCAL.realUnits = [ "B", "KB", "MB", "GB" ]>

	<cfloop from="1" to="#(arrayFindNoCase(LOCAL.realUnits, ARGUMENTS.unit) -1)#" index="LOCAL.depth">
		<cfset LOCAL.bytes /= 1000>
	</cfloop>

	<cfif LOCAL.depth gte 2>
		<cfset LOCAL.bytes = numberFormat(LOCAL.bytes, .00)>
	</cfif>

	<cfreturn (LOCAL.bytes & " " & LOCAL.realUnits[LOCAL.depth])>
</cffunction>
