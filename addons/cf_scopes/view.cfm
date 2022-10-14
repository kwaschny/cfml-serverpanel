<cfsetting enableCFoutputOnly="true">

<cfset sorted = structKeyArray(SERVER)>
<cfset arraySort(sorted, "TEXTnoCASE")>

<!--- HTML --->
<cfoutput>

	<div class="cf_scopes">

		<h2>
			SERVER Scope <small class="lowlight">#structCount(SERVER)#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>Key</th>
					<th>Value</th>
				</tr>
			</thead>
			<tbody>
				<cfset LOCAL.i = 0>
				<cfloop array="#sorted#" index="key">

					<cfif ATTRIBUTES.admin.isReservedServerKey(key)>
						<cfcontinue>
					</cfif>
					<cfset LOCAL.i += 1>

					<cfset value = SERVER[key]>

					<tr class="kvp">
						<td class="nobr">
							#encodeForHtml(key)#
						</td>
						<td class="nobr">
							<cfif isSimpleValue(value)>
								<span title="#encodeForHtmlAttribute(value)#">
									#encodeForHtml(value)#
								</span>
							<cfelse>
								<span class="lowlight">
									<cfif isStruct(value)>
										[struct with #structCount(value)# elements]
									<cfelseif isArray(value)>
										[array with #arrayLen(value)# elements]
									<cfelseif isQuery(value)>
										[query with #value.recordCount# rows]
									<cfelse>
										[complex value]
									</cfif>
								</span>
							</cfif>
						</td>
					</tr>

				</cfloop>
				<cfif LOCAL.i eq 0>
					<tr>
						<td colspan="2" class="lowlight">
							no custom keys found
						</td>
					</tr>
				</cfif>
			</tbody>
			<tfoot>
				<tr>
					<th>Key</th>
					<th>Value</th>
				</tr>
			</tfoot>
		</table>

		<form method="post" class="action">

			<select name="operator">
				<option value="equal">equal to</option>
				<option value="contains">contains</option>
				<option value="starts">starts with</option>
				<option value="ends">ends with</option>
				<option value="any">any</option>
			</select>

			<input type="text" name="key_pattern" />

			<button type="submit" name="server_remove">
				Remove Key
			</button>

		</form>

		<style>

			.panel .cf_scopes {
				width: 100%;
			}

				.panel .cf_scopes tr.kvp td:last-child {
					font-family: Consolas, 'Courier New', Courier, monospace;
					font-size: 80%;
				}

		</style>

	</div>

</cfoutput>
