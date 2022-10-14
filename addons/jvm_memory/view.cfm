<cfsetting enableCFoutputOnly="true">

<cfset memory = ATTRIBUTES.admin.getMemoryStats()>

<!--- HTML --->
<cfoutput>

	<div class="jvm_memory">

		<h2>
			Heap &amp; Non-Heap Memory
		</h2>

		<cfif memory.TotalMemory gt 0>

			<cfset currentValue = min(int((memory.UsedMemory / memory.TotalMemory) * 100), 100)>
			<cfset maximumValue = (100 - currentValue)>

			<div class="heap bar">
				<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
				<span class="size">#REQUEST.Util.stringifyBytes(memory.UsedMemory)# / #REQUEST.Util.stringifyBytes(memory.TotalMemory)#</span>
			</div>

		<cfelse>

			<cfset currentValue = 0>
			<cfset maximumValue = 100>

			<div class="heap bar">
				<span class="current" style="width: #currentValue#%;"></span><span class="maximum" style="width: #maximumValue#%;"></span>
				<span class="size">#REQUEST.Util.stringifyBytes(usedMemory)#</span>
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
					<span class="size">#REQUEST.Util.stringifyBytes(poolUsedMemory)# / #REQUEST.Util.stringifyBytes(poolTotalMemory)#</span>
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
					<span class="size">#REQUEST.Util.stringifyBytes(poolUsedMemory)#</span>
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

		<style>

			.panel .jvm_memory {
				min-width: 192px;
			}

				.panel .jvm_memory .bar {
					border: 1px solid ##80D2FF;
					height: 40px;
					margin-bottom: 8px;
					position: relative;
				}

					.panel .jvm_memory .bar.mini {
						height: 24px;
					}
						.panel .jvm_memory .bar.mini .size {
							white-space: nowrap;
							top: 0;
						}

					.panel .jvm_memory .bar .current,
					.panel .jvm_memory .bar .maximum {
						display: inline-block;
						height: 100%;
					}
					.panel .jvm_memory .bar .current {
						background-color: ##B3E5FF;
					}
					.panel .jvm_memory .bar .maximum {
						background-color: ##E5F6FF;
					}

					.panel .jvm_memory .bar .size {
						position: absolute;
						right: 4px;
						top: 8px;
					}

		</style>

	</div>

</cfoutput>
