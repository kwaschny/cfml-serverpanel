<cfsetting enableCFoutputOnly="true">

<cfmodule template="auth.cfm">

<!--- config --->
<cfmodule variable="cfAdminPassword" template="config.cfm">
<cfif not structKeyExists(VARIABLES, "cfAdminPassword")>
	<cfthrow message="You did not specify the server admin password. Check config.cfm for more details.">
</cfif>

<cfset Admin = new Admin(SERVER, cfAdminPassword)>

<!--- BEGIN: controller --->

	<cfif not structIsEmpty(FORM)>

		<!--- remove key from SERVER scope --->
		<cfif (
			structKeyExists(FORM, "server_remove") and
			structKeyExists(FORM, "key_pattern") and
			structKeyExists(FORM, "operator")
		)>

			<cfset serverKeys   = structKeyArray(SERVER)>
			<cfset keysToRemove = []>

			<cfswitch expression="#FORM["operator"]#">

				<cfcase value="equal">

					<cfloop array="#serverKeys#" index="serverKey">
						<cfif (serverKey eq FORM["key_pattern"]) and (not Admin.isReservedServerKey(serverKey))>
							<cfset keysToRemove.add(serverKey)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="contains">

					<cfloop array="#serverKeys#" index="serverKey">
						<cfif (serverKey contains FORM["key_pattern"]) and (not Admin.isReservedServerKey(serverKey))>
							<cfset keysToRemove.add(serverKey)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="starts">

					<cfloop array="#serverKeys#" index="serverKey">
						<cfif (serverKey.startsWith(FORM["key_pattern"])) and (not Admin.isReservedServerKey(serverKey))>
							<cfset keysToRemove.add(serverKey)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="ends">

					<cfloop array="#serverKeys#" index="serverKey">
						<cfif (serverKey.endsWith(FORM["key_pattern"])) and (not Admin.isReservedServerKey(serverKey))>
							<cfset keysToRemove.add(serverKey)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="any">

					<cfloop array="#serverKeys#" index="serverKey">
						<cfif not Admin.isReservedServerKey(serverKey)>
							<cfset keysToRemove.add(serverKey)>
						</cfif>
					</cfloop>

				</cfcase>

			</cfswitch>

			<cfloop array="#keysToRemove#" index="serverKey">
				<cfset structDelete(SERVER, serverKey)>
			</cfloop>

		</cfif>

		<!--- stop application --->
		<cfif (
			structKeyExists(FORM, "app_stop") and
			structKeyExists(FORM, "app_pattern") and
			structKeyExists(FORM, "operator")
		)>

			<cfset appNames   = structKeyArray( Admin.getApplicationStats() )>
			<cfset appsToStop = []>

			<cfswitch expression="#FORM["operator"]#">

				<cfcase value="equal">

					<cfloop array="#appNames#" index="appName">
						<cfif appName eq FORM["app_pattern"]>
							<cfset appsToStop.add(appName)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="contains">

					<cfloop array="#appNames#" index="appName">
						<cfif appName contains FORM["app_pattern"]>
							<cfset appsToStop.add(appName)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="starts">

					<cfloop array="#appNames#" index="appName">
						<cfif appName.startsWith(FORM["app_pattern"])>
							<cfset appsToStop.add(appName)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="ends">

					<cfloop array="#appNames#" index="appName">
						<cfif appName.endsWith(FORM["app_pattern"])>
							<cfset appsToStop.add(appName)>
						</cfif>
					</cfloop>

				</cfcase>
				<cfcase value="any">

					<cfloop array="#appNames#" index="appName">
						<cfset appsToStop.add(appName)>
					</cfloop>

				</cfcase>

			</cfswitch>

			<cfloop array="#appsToStop#" index="appName">

				<cftry>

					<!--- switch to application and stop it --->
					<cfapplication name="#appName#">
					<cfset applicationStop()>

					<cfcatch>
						<!--- race condition: application might no longer exist --->
					</cfcatch>
				</cftry>

			</cfloop>

		</cfif>

		<!--- trigger garbage collection --->
		<cfif structKeyExists(FORM, "gc")>

			<cfset createObject("java", "java.lang.System").gc()>

		</cfif>

		<cflocation url="index.cfm" statusCode="303" addToken="false">

	</cfif>

<!--- END: controller --->

<!--- BEGIN: prepare data --->

	<cfset Who   = new Who(SERVER)>
	<cfset Util  = new Util()>

	<cfset memory   = Admin.getMemoryStats()>
	<cfset appStats = Admin.getApplicationStats()>
	<cfset apps     = structSort(appStats, "NUMERIC", "DESC", "SessionCount")>

<!--- END: prepare data --->

<!--- HTML --->
<cfoutput>

	<meta name="viewport" content="width=device-width">
	<link rel="stylesheet" href="styles.css">

	<h1>&##128421; ServerPanel</h1>

	<section class="panels">

		<div class="server panel">

			<h2>About</h2>

			<table>
				<tr>
					<th>
						CFML Engine
					</th>
					<td>
						#encodeForHtml( Who.getColdFusionVendor() )# #encodeForHtml( Who.getColdFusionVersion() )#
					</td>
				</tr>
				<tr>
					<th>
						Servlet Engine
					</th>
					<td>
						#encodeForHtml( Who.getServlet() )#
					</td>
				</tr>
				<tr>
					<th>
						Java Runtime
					</th>
					<td>
						#encodeForHtml( Who.getJavaRuntimeVendor() )# #encodeForHtml( Who.getJavaRuntimeVersion() )#
					</td>
				</tr>
				<tr>
					<th>
						Java VM
					</th>
					<td>
						#encodeForHtml( Who.getJavaVmVendor() )# #encodeForHtml( Who.getJavaVmVersion() )#
					</td>
				</tr>
				<tr>
					<th>
						Operating System
					</th>
					<td>
						#encodeForHtml( Who.getOpSystemVendor() )# #encodeForHtml( Who.getOpSystemVersion() )#
					</td>
				</tr>
				<tr>
					<th>
						System Name
					</th>
					<td>
						#encodeForHtml( Who.getOpSystemName() )#
					</td>
				</tr>
			</table>

		</div><!---

		---><div class="memory panel">

			<h2>Heap &amp; Non-Heap Memory</h2>

			<cfif memory.TotalMemory gt 0>

				<cfset currentValue = min(int((memory.UsedMemory / memory.TotalMemory) * 100), 100)>
				<cfset maximumValue = (100 - currentValue)>

				<div class="heap bar">
					<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
					<span class="size">#Util.stringifyBytes(memory.UsedMemory)# / #Util.stringifyBytes(memory.TotalMemory)#</span>
				</div>

			<cfelse>

				<cfset currentValue = 0>
				<cfset maximumValue = 100>

				<div class="heap bar">
					<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
					<span class="size">#Util.stringifyBytes(usedMemory)#</span>
				</div>

			</cfif>

			<cfloop array="#memory.MemoryPool#" index="pool">

				<cfset poolUsage       = pool.getUsage()>
				<cfset poolTotalMemory = poolUsage.getMax()>
				<cfset poolUsedMemory  = max(0, poolUsage.getUsed())>
				<cfif poolTotalMemory lte 0>
					<cfset poolTotalMemory = memory.TotalMemory>
				</cfif>

				<cfif poolTotalMemory gt 0>

					<cfset currentValue = min(int((poolUsedMemory / poolTotalMemory) * 100), 100)>
					<cfset maximumValue = (100 - currentValue)>

					<h3>
						#encodeForHtml( pool.getName() )#
						<small class="lowlight">(#encodeForHtml( pool.getType().toString() )#)</small>
					</h3>

					<div class="bar mini">
						<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
						<span class="size">#Util.stringifyBytes(poolUsedMemory)# / #Util.stringifyBytes(poolTotalMemory)#</span>
					</div>

				<cfelse>

					<cfset currentValue = 0>
					<cfset maximumValue = 100>

					<h3>
						#encodeForHtml( pool.getName() )#
						<small class="lowlight">(#encodeForHtml( pool.getType().toString() )#)</small>
					</h3>

					<div class="bar mini">
						<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
						<span class="size">#Util.stringifyBytes(poolUsedMemory)#</span>
					</div>

				</cfif>

			</cfloop>

			<form method="post" class="action">

				<label>
					<input type="checkbox" required />
					Confirm GC
				</label>

				<button type="submit" name="gc">
					Force Garbage Collection
				</button>

			</form>

		</div><!---

		---><div class="apps panel">

			<h2>Applications</h2>

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

		</div><!---

		---><div class="scopes panel">

			<h2>SERVER Scope</h2>

			<table class="full">
				<thead>
					<tr>
						<th>Key</th>
						<th>Value</th>
					</tr>
				</thead>
				<tbody>
					<cfset LOCAL.i = 0>
					<cfloop collection="#SERVER#" item="key">

						<cfif Admin.isReservedServerKey(key)>
							<cfcontinue>
						</cfif>
						<cfset LOCAL.i += 1>

						<cfset value = SERVER[key]>

						<tr>
							<td class="nobr">
								#encodeForHtml(key)#
							</td>
							<td class="nobr">
								<cfif isSimpleValue(value)>

									<cfif len(value) gt 32>
										#encodeForHtml( left(value, 32) )#&##8230;
									<cfelse>
										#encodeForHtml( value)#
									</cfif>

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

		</div>

	</section>

	<script>

		var selects = document.querySelectorAll('select[name="operator"]');
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

</cfoutput>