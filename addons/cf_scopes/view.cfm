<cfsetting enableCFoutputOnly="true">

<!--- filter keys in SERVER scope --->
<cfset sorted = structKeyArray(SERVER)>
<cfloop from="#arrayLen(sorted)#" to="1" index="i" step="-1">
	<cfif ATTRIBUTES.admin.isReservedServerKey(sorted[i])>
		<cfset arrayDeleteAt(sorted, i)>
	</cfif>
</cfloop>
<cfset arraySort(sorted, "TEXTnoCASE")>

<!--- HTML --->
<cfoutput>

	<div class="cf_scopes">

		<h2>
			SERVER Scope <small class="lowlight">#arrayLen(sorted)#</small>
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
