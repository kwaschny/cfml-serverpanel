<cfsetting enableCFoutputOnly="true">

<!--- BEGIN: retrieve data --->

	<cfif ATTRIBUTES.admin.isAdobeCF()>

		<cfset reqFilter = "(^qtp[0-9]+|\-exec\-[0-9]+$)">
		<cfset pgkPrefix = "coldfusion.">

	<cfelseif ATTRIBUTES.admin.isLuceeCF()>

		<cfset reqFilter = "(^qtp[0-9]+|\-exec\-[0-9]+$)">
		<cfset pgkPrefix = "lucee.">

	<cfelse>
		<cfset reqFilter = "">
		<cfset pgkPrefix = "">
	</cfif>

	<cfset threadStats = ATTRIBUTES.admin.getThreadStats(
		filter:   reqFilter,
		maxDepth: 100
	)>
	<cfset threadInfos = threadStats.Threads>

	<!--- BEGIN: filter for requests --->

		<cfset currentThreadID = createObject("java", "java.lang.Thread").currentThread().getID()>

		<cfset cfRequests = []>
		<cfloop array="#threadInfos#" index="threadInfo">

			<!--- exclude this thread from appearing as request --->
			<cfif threadInfo.getThreadId() eq currentThreadID>
				<cfcontinue>
			</cfif>

			<cfset stacktrace = threadInfo.getStackTrace()>

			<cfset isRequest = false>
			<cfloop array="#stacktrace#" index="entry">

				<cfset className = entry.getClassName()>

				<cfif className contains pgkPrefix>
					<cfset isRequest = true>
					<cfbreak>
				</cfif>

			</cfloop>

			<cfif isRequest>
				<cfset cfRequests.add(threadInfo)>
			</cfif>

		</cfloop>

	<!--- END: filter for requests --->

<!--- END: retrieve data --->

<cfset cssClassDL = ( (threadStats.Deadlocks gt 0) ? "critical" : "fine" )>
<cfset cssClassBL = ( (threadStats.Blocked   gt 0) ? "critical" : "fine" )>

<!--- HTML --->
<cfoutput>

	<div class="cf_requests">

		<h2>
			Active Requests <small class="lowlight">#arrayLen(cfRequests)#</small>
		</h2>

		<table class="stats">
			<tr>
				<td>Threads</td>
				<td class="number">#threadStats.Count#</td>
				<td>Daemons</td>
				<td class="number">#threadStats.Daemons#</td>
				<td class="#cssClassDL#">Deadlocks</td>
				<td class="#cssClassDL# number">#threadStats.Deadlocks#</td>
			</tr>
			<tr>
				<td>RUNNABLE</td>
				<td class="number">#threadStats.Runnable#</td>
				<td>WAITING</td>
				<td class="number">#threadStats.Waiting#</td>
				<td class="#cssClassBL#">BLOCKED</td>
				<td class="#cssClassBL# number">#threadStats.Blocked#</td>
			</tr>
		</table>

		<cfloop array="#cfRequests#" index="threadInfo">

			<cfset stacktrace = threadInfo.getStackTrace()>

			<div class="request">
				<h3 class="thread">
					<span class="thread-id">#threadInfo.getThreadId()#:</span>
					<span class="thread-name">#encodeForHtml( threadInfo.getThreadName() )#</span>
				</h3>
				<table class="full trace">
					<cfloop array="#stacktrace#" index="entry">

						<cfset fileName = entry.getFileName()>

						<cfif isNull(fileName) or (not reFindNoCase("\.cf[cm]$", fileName))>
							<cfcontinue>
						</cfif>

						<cfset methodName = entry.getMethodName()>
						<cfset className  = entry.getClassName()>

						<cfswitch expression="#methodName#">
							<cfcase value="runFunction">
								<cfset className = reReplace(listLast(className, "$"), "^func", "")>
							</cfcase>
							<cfcase value="runPage">
								<cfset className = "">
							</cfcase>
							<cfdefaultcase>
								<cfcontinue>
							</cfdefaultcase>
						</cfswitch>

						<tr>
							<td class="operation">
								#encodeForHtml(className)#
							</td>
							<td class="file">
								#encodeForHtml(fileName)#<code class="line">:#entry.getLineNumber()#</code>
							</td>
						</tr>

					</cfloop>
				</table>
				<div onclick="cf_requests_expandStacktrace(this)" class="stacktrace collapsed">
					<code>
						<cfloop array="#stacktrace#" index="entry">
							<br><span class="class">at #encodeForHtml( entry.getClassName() )#</span>.<span class="method">#encodeForHtml( entry.getMethodName() )#</span> <span class="file">(#encodeForHtml( entry.getFileName() )#:#entry.getLineNumber()#</span>)
						</cfloop>
					</code>
				</div>
			</div>

		</cfloop>

		<style>

			.panel .cf_requests .request {
				border: 1px solid ##80D2FF;
				margin-top: 16px;
				padding: 8px 16px;
			}

			.panel .cf_requests .stats td:nth-child(odd) {
				border-right: none;
				color: ##A0A0A0;
			}
			.panel .cf_requests .stats td:nth-child(even) {
				border-left: none;
			}

			.panel .cf_requests .stats td.fine {
				color: ##00A000;
			}
			.panel .cf_requests .stats td.critical {
				color: ##F00000;
			}

			.panel .cf_requests h3 {
				font-weight: bold;
				margin-bottom: 16px;
			}

				.panel .cf_requests h3 .thread-id {
					color: ##0000FF;
				}

			.panel .cf_requests .trace {
				display: block;
				font-size: 80%;
				margin-bottom: 0;
				overflow: auto;
			}

			.panel .cf_requests .stacktrace {
				cursor: default;
				font-size: 80%;
				line-height: 1.4;
				overflow: auto;
				white-space: nowrap;
			}
				.panel .cf_requests .stacktrace.collapsed {
					cursor: pointer;
					max-height: 128px;
					overflow: hidden;
					position: relative;
				}
					.panel .cf_requests .stacktrace.collapsed:after {
						background-image: linear-gradient(to bottom, rgba(250, 250, 250, 0), rgba(250, 250, 250, 1) 90%);
						bottom: 0;
						content: "";
						height: 4em;
						left: 0;
						position: absolute;
						width: 100%;
						z-index: 1;
					}

		</style>

		<script>

			function cf_requests_expandStacktrace(container) {

				container.classList.remove('collapsed');
			};

		</script>

	</div>

</cfoutput>
