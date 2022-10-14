<cfsetting enableCFoutputOnly="true">

<cfif not structKeyExists(REQUEST, "Admin.getApplicationStats")>
	<cfset REQUEST["Admin.getApplicationStats"] = ATTRIBUTES.admin.getApplicationStats()>
</cfif>
<cfset appStats = REQUEST["Admin.getApplicationStats"]>

<cfset apps = structSort(appStats, "NUMERIC", "DESC", "SessionCount")>

<!--- HTML --->
<cfoutput>

	<div class="cf_apps">

		<h2>
			Applications <small class="lowlight">#arrayLen(apps)#</small>
		</h2>

		<table class="full">
			<thead>
				<tr>
					<th>Application</th>
					<th class="number">Sessions</th>
				</tr>
			</thead>
			<tbody>
				<cfif not arrayIsEmpty(apps)>

					<cfloop array="#apps#" index="appName">

						<cfset app = appStats[appName]>

						<tr>
							<td>
								#encodeForHtml(appName)#
							</td>
							<td class="number">
								#encodeForHtml(app.SessionCount)#
							</td>
						</tr>

					</cfloop>

				<cfelse>
					<tr>
						<td colspan="2" class="lowlight">
							no applications available
						</td>
					</tr>
				</cfif>
			</tbody>
			<tfoot>
				<tr>
					<th>Application</th>
					<th class="number">Sessions</th>
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

			<input type="text" name="app_pattern" />

			<button type="submit" name="app_stop">
				Stop Application
			</button>

		</form>

		<script>

			var selects = document.querySelectorAll('.panel .cf_apps select[name="operator"]');
			for (var i = 0; i < selects.length; i++) {

				selects[i].addEventListener('change', function() {

					var input = this.parentNode.querySelector('input[type="text"]');

					if (this.value === 'any') {

						input.value    = '*';
						input.readOnly = true;

					} else {

						input.value    = ( (input.value === '*') ? '' : input.value );
						input.readOnly = false;
					}
				});
			}

		</script>

	</div>

</cfoutput>
