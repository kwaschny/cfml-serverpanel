<cfsetting enableCFoutputOnly="true">

<cfset isLazy = (
	structKeyExists(ATTRIBUTES, "lazy") and
	isBoolean(ATTRIBUTES.lazy) and
	ATTRIBUTES.lazy
)>

<cfif isLazy>
	<cfset cpu = { Cores: "…", Utilization: "…", UtilType: "" }>
<cfelse>
	<cfset cpu = ATTRIBUTES.admin.getCpuStats()>
</cfif>

<cfset isUsage = (cpu.UtilType eq "%")>
<cfset isLoad  = (cpu.UtilType eq "L")>

<cfset disks = ATTRIBUTES.admin.getDiskStats()>

<!--- HTML --->
<cfoutput>

	<div class="os">

		<!--- BEGIN: cpu --->

			<cfif isUsage>

				<cfset currentValue = cpu.Utilization>
				<cfset maximumValue = (100 - currentValue)>

				<h2>
					Usage <small class="lowlight">on #cpu.Cores# Cores</small>
				</h2>

				<div class="load bar">
					<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
					<span class="size">#cpu.Utilization#&nbsp;%</span>
				</div>

			<cfelseif isLoad>

				<cfset currentValue = min(int((cpu.Utilization / max(1, (cpu.Cores / 2))) * 100), 100)>
				<cfset maximumValue = (100 - currentValue)>

				<h2>
					Load <small class="lowlight">on #cpu.Cores# Cores</small>
				</h2>

				<div class="load bar">
					<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
					<span class="size">#cpu.Utilization#</span>
				</div>

			<cfelse>

				<h2>
					…
				</h2>

				<div class="load bar">
					<span class="current" style="width: 50%;"></span><span class="maximum" style="width: 50%;"></span>
					<span class="size">…</span>
				</div>

			</cfif>

		<!--- END: cpu --->

		<!--- BEGIN: disks --->

			<h2>
				Disks <small class="lowlight">#REQUEST.Util.stringifyBytes(disks[1].Total - disks[1].Free)# / #REQUEST.Util.stringifyBytes(disks[1].Total)#</small>
			</h2>

			<cfloop from="2" to="#arrayLen(disks)#" index="i">

				<cfset disk = disks[i]>

				<cfif disk.Total gt 0>
					<cfset currentValue = min(int(((disk.Total - disk.Free) / disk.Total) * 100), 100)>
				<cfelse>
					<cfset currentValue = 100>
				</cfif>
				<cfset maximumValue = (100 - currentValue)>

				<h3>
					#encodeForHtml(disk.Name)#
				</h3>

				<div class="disk bar">
					<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
					<span class="size">#REQUEST.Util.stringifyBytes(disk.Total - disk.Free)# / #REQUEST.Util.stringifyBytes(disk.Total)#</span>
				</div>

			</cfloop>

		<!--- END: disks --->

		<style>

			.panel .os {
				min-width: 192px;
			}

				.panel .os .bar {
					border: 1px solid ##80D2FF;
					height: 40px;
					margin-bottom: 8px;
					position: relative;
				}

					.panel .os .bar .current,
					.panel .os .bar .maximum {
						display: inline-block;
						height: 100%;
					}
					.panel .os .bar .current {
						background-color: ##B3E5FF;
					}
					.panel .os .bar .maximum {
						background-color: ##E5F6FF;
					}

					.panel .os .bar .size {
						position: absolute;
						right: 4px;
						top: 8px;
					}

		</style>

	</div>

</cfoutput>
