<cfsetting enableCFoutputOnly="true">

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
					#encodeForHtml( ATTRIBUTES.who.getColdFusionVendor() )# #encodeForHtml( ATTRIBUTES.who.getColdFusionVersion() )#
				</td>
			</tr>
			<tr>
				<th>
					Servlet Engine
				</th>
				<td>
					#encodeForHtml( ATTRIBUTES.who.getServlet() )#
				</td>
			</tr>
			<tr>
				<th>
					Java Runtime
				</th>
				<td>
					#encodeForHtml( ATTRIBUTES.who.getJavaRuntimeVendor() )# #encodeForHtml( ATTRIBUTES.who.getJavaRuntimeVersion() )#
				</td>
			</tr>
			<tr>
				<th>
					Java VM
				</th>
				<td>
					#encodeForHtml( ATTRIBUTES.who.getJavaVmVendor() )# #encodeForHtml( ATTRIBUTES.who.getJavaVmVersion() )#
				</td>
			</tr>
			<tr>
				<th>
					Operating System
				</th>
				<td>
					#encodeForHtml( ATTRIBUTES.who.getOpSystemVendor() )# #encodeForHtml( ATTRIBUTES.who.getOpSystemVersion() )#
				</td>
			</tr>
			<tr>
				<th>
					System Name
				</th>
				<td>
					#encodeForHtml( ATTRIBUTES.who.getOpSystemName() )#
				</td>
			</tr>
		</table>

	</div>

</cfoutput>
