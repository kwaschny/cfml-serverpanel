<cfsetting enableCFoutputOnly="true">

<cfset Who = new Who(SERVER)>

<!--- HTML --->
<cfoutput>

	<div class="server">

		<h2>
			About
		</h2>

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

	</div>

</cfoutput>
