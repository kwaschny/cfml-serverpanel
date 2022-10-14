# ColdFusion/Lucee Server Panel
A webpage that displays useful information about the server and shows a snapshot of the current live state.

![Screenshot](/screenshot.png?raw=true)

## Features/Panels

### Server Information
General information about the current server JVM.

### Memory Pool
Heap & Non-Heap usage of the current JVM. You can trigger a manual Garbage Collection (for development purpose).

### Applications & Sessions
All running applications and the number of sessions alive. Note that in case of Lucee, applications are only listed if there is at least one variable stored in the `APPLICATION` scope. You can also stop listed applications. ColdFusion 2016+ is not yet supported.

### SERVER scope variables
List of all custom `SERVER` scope variables. You can also remove them (for development purpose).

## Installation
Just drop all files in a folder and expose it like a regular website.

### Set username and/or password or disable authentication
By default, access to the Server Panel requires an authentication (via Basic Auth). If you do not specify anything, access to Server Panel will throw an exception: `You did not specify username and/or password for Basic Auth.`

To set up the authentication, open `/auth.cfm` and set:
```
<cfset requiredUsername = "">
<cfset requiredPassword = "">
```
Note that you can provide username/password, only username or only password. Make sure `requireBasicAuth` is still set to `true`.

-----

If you do not need authentication, open `/auth.cfm` and set:
```
<cfset requireBasicAuth = false>
```

### Set administration password
Since application-, session- and server-scope information are only available through the ColdFusion/Lucee administration API, you will need to set the password for it. Otherwise it will throw an exception: `You did not specify the server admin password.`

To set the administration API password, open `/config.cfm` and set:
```
<!--- enter server admin password --->
<cfset CALLER[ATTRIBUTES.variable]["cfAdminPassword"] = "">
```

### (optional) Set datasource for database related addons
To set the datasource, open `/config.cfm` and set:
```
<!--- enter datasource to query against database --->
<cfset CALLER[ATTRIBUTES.variable]["cfDatasource"] = "">
```

### (optional) Add/Remove and sort addons
Addons are loaded from the `/addons/` folder. You can exclude addons by prefixing the addon's folder with an underscore `_` or add/remove (comment/uncomment) the folder's name in `/index.cfm`:

```
<cfset addOnOrder = [
	"cf_requests",
	"jvm_memory",
	"iis_iptable",
	"cf_apps",
	"mysql_pools",
	"mysql_queries",
	"server",
	"mysql_monitor",
	"cf_scopes"
]>
```

This also allows you to change the order of appearance.

### (optional) Add custom hostnames to resolve owned/known servers
IP addresses and hostnames can be mapped when being displayed in addons. Just edit the map at the bottom of `/Util.cfc`:

```
<cfset VARIABLES.HOSTS = {
	"192.168.0.1": "My Server"
}>
```

This will change occurrences of `192.168.0.1` into `My Server`.

## /echo.cfm
This file exists for monitoring reasons only. Feel free to delete the file if you don't need it.

## Troubleshooting

### InaccessibleObjectException
If you encounter `java.lang.reflect.InaccessibleObjectException: Unable to make public com.sun.management.internal.HotSpotThreadImpl(sun.management.VMManagement) accessible: module jdk.management does not "exports com.sun.management.internal" to unnamed module` with Adobe ColdFusion, you need to expose the required package by adding the following argument to `/cfusion/bin/jvm.config`:
```
--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED
```
A server restart is required after modifying the `jvm.config`.
