# ColdFusion/Lucee Server Panel
A webpage that displays useful information about the server JVM and offers some administrative controls.

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

To set up the authentication, open `auth.cfm` and set:
```
<cfset requiredUsername = "your username">
<cfset requiredPassword = "your password">
```
Note that you can provide either username or password. Make sure `requireBasicAuth` is still set to `true`.

-----

To disable the authentication permanently, open `auth.cfm` and set:
```
<cfset requireBasicAuth = false>
```

### Set administration password
Since application-, session- and server-scope information are only available through the ColdFusion/Lucee administration API, you will need to set the password for it. Otherwise it will throw an exception: `You did not specify the server admin password.`

To set the administration API password, open `config.cfm` and set:
```
<cfset CALLER[ATTRIBUTES.variable] = "your admin password">
```

## echo.cfm
This file exists for monitoring reasons only. Feel free to delete the file if you don't need it.