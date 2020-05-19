# Splunkbase Download Utility

This utility provides a convenient method for Splunk administrators to download Splunkbase apps from the command line. This allows downloading apps for inspection/validation, staging apps for later installation, or installing apps while Splunk is unavailable, and saves the additional step of transferring apps from another system. It can also be integrated into build scripts for education or development Splunk deployments in order to automate the installation of apps.

## Getting Started

Using this utility is as simple as downloading the script and running it. A few very straightforward dependencies are listed below, along with a copy-and-paste command to pull the script down.

### Prerequisites

A few basic requirements are all that's needed:

 - POSIX-compatible shell
 - Relatively modern release of curl
 - Outbound HTTPS access
 - An account on Splunkbase

This was tested with BusyBox 1.31.1 ash and curl 7.67.0 on Alpine Linux 3.11.6.

### Installation

Simply clone the repository, make the script executable, and run it:

```
git clone https://github.com/tfrederick74656/splunkbase-download.git && \
cd splunkbase-download/ && \
chmod +x ./splunkbase-download.sh
```

Alternatively, you can download the script directly if you don't have/want to use git:

```
curl -L -O -J \
'https://github.com/tfrederick74656/splunkbase-download/releases/download/v1.0.0/splunkbase-download.sh' && \
chmod +x ./splunkbase-download.sh
```

## Usage

This utility can be run in two modes: *download* and *authenticate*. Authenticate mode accepts a username and password to Splunkbase, and returns a session token. Download mode accepts an app ID, app version, and session token, and downloads the application package to disk. 

### Instructions

```
Splunkbase App Console Download Utility 1.0.0
Usage: ./splunkbase-download.sh MODE ARGUMENTS...

Mode:
	a|auth|authenticate	Authenticate and return sid/SSOID cookies
	d|down|download		Download an app by ID and version

Authenticate Mode:
	./splunkbase-download.sh authenticate username password

	username			Splunkbase username
	password			Splunkbase password

Download Mode:
	./splunkbase-download.sh download app_id app_version sid ssoid
	./splunkbase-download.sh download app_id app_version sessionid

	app_id				The numerical Splunk app ID
	app_version			The Splunk app version, usually x.y.z
	sid					SID cookie value
	ssoid				SSOID cookie value
	sessionid			SESSIONID cookie value
```

### Download Mode

In download mode, you supply the app information (ID and version) along with a valid session token (sid+SSOID or sessionid), and the script downloads the app package. The complete app package is written to the current directory with the server-supplied filename, typically *app-name_version.tgz*. The standard curl progress/output is printed to the comamnd line.

Identifying the Splunkbase app to download requires two pieces of information: `app_id` and `app_version`. The former is typically a 3 or 4 digit number, and can be located in the app's Splunkbase URL, e.g. *https://splunkbase.splunk.com/app/**1234**/* The latter is located in the right-hand column of the app's Splunkbase page, typically in semantic versioning format *x.y.z*. Note that some older apps deviate from this format; you should use exactly what apppears on Splunkbase as the value for the `app_version` argument.

Valid session tokens are both `sid` and `SSOID`, or alternatively `sessionid`. Using the authenticate mode of this script provides an easy, command-line native way to retrieve these values. Alternatively, signing in to Splunkbase from a web browser will generate the above tokens. You should be able to retrieve these by viewing the site's cookies in any modern browser's native privacy tools. Personally, I use the open source [EditThisCookie](http://www.editthiscookie.com/) extension in Google Chrome to make this even easier.

Currently, this utility will download a single app at a time. To download multiple apps or automate setup/configuration of a Splunk deployment, you can create a list of app ID and app versions, and execute this utility in a loop for each one. Future versions may natively include this functionality.

### Authenticate Mode

In authenticate mode, you supply credentials (username and password) for Splunkbase, and the script return a session token that can be used to authenticate multiple app downloads. The script uses curl to perform an encrypted POST to Splunk's Okta `auth` endpoint. The complete response is captured, and the following fields are parsed out and printed to standard output:

|Field|Description|
|--|--|
|`sid` and `SSOID`|Session tokens required to download an app|
|`status_code`|Numeric return value of the request. Should be an HTTP status code, but this comes from the payload, not from the header, so this is not guaranteed.|
|`status`|String return value of the request. Typically *success* or *error*.|
|`msg`|Friendly status message displayed to the user. Typically *Please check your username and password and try again* or *Successfully authenticated user*.|

To easily reference your `sid` and `SSOID` when running in download mode, you can write the output to a file, and assign the values to variables:

```
./splunkbase-download.sh authenticate username password > session.txt
sid=$(grep sid session.txt | cut -f3)
SSOID=$(grep SSOID session.txt | cut -f3)
./spluinkbase-download app_id app_version $sid $SSOID
```

**Important**: As with any shell script, use caution not to expose plaintext credentials on the command line, as they may be stored in your shell's history or system logs and accessible to others. If this is a concern, log in from a web browser, obtain your `sid` and `SSOID` cookie values, and use these directly with the download mode. Be sure to log out of your web browser afterward to invalidate the session token, as this can be valid for more than a week, depending on the session. 

## Contributing

Questions, comments, and pull requests are welcome. Please note however, as this is a side project, there may be a significant delay in my response.

## Versioning

I use [SemVer](https://semver.org/) for versioning. For a complete version history, see the [tags on this repository](https://github.com/tfrederick74656/splunkbase-download/tags).

## Disclaimer

This utility uses a service provided by Splunk. Please read the following prior to use:

 - Splunk® is a trademark or registered trademark of Splunk Inc. in the United States and other countries.
 - Use of the Splunk website is subject to the [Splunk Website Terms and Conditions of Use](https://www.splunk.com/view/SP-CAAAAAH).
 - Apps from Splunkbase are individually licensed and subject to the terms and conditions of their respective licenses.
 - The author of this tool takes no responsibility for your use of Splunk products and services.
 
By using this utility, you acknowledge that you have read and understand all of the above statements and agree to abide and be bound by them.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
