#!/usr/bin/env sh

# Global Variables
readonly BASE_AUTH_URL='https://account.splunk.com/api/v1/okta/auth'
readonly BASE_DOWN_URL='http://splunkbase.splunk.com/app/$APPID/release/$APPVER/download/'
readonly USAGE_INSTRUCTIONS='Splunkbase App Console Download Utility 1.0.0
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
	sid				SID cookie value
	ssoid				SSOID cookie value
	sessionid			SESSIONID cookie value
'

# Authenticate aginst Splunk's website (Okta) and return 'sid' and "SSOID' cookies.
# Also return the 'status_code', 'status', and 'msg' fields from the server's reply.
authenticate() {
	readonly RESPONSE=$(curl -s -v -X POST \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d "{
		\"username\": \"$1\",
		\"password\": \"$2\"
	}" "$(eval 'echo $BASE_AUTH_URL')" 2>&1)
	echo -e "status_code\t$(echo "$RESPONSE" | sed -nr "s/.*\"status_code\": ([0-9]+),.*/\1/p")"
	echo -e "status\t\t$(echo "$RESPONSE" | sed -nr "s/.*\"status\": \"([^\"]+)\",.*/\1/p")"
	echo -e "msg\t\t$(echo "$RESPONSE" | sed -nr "s/.*\"msg\": \"([^\"]+)\",.*/\1/p")"
	echo -e "sid\t\t$(echo "$RESPONSE" | sed -nr "s/.*set-cookie: sid=([^;]+);.*/\1/p")"
	echo -e "SSOID\t\t$(echo "$RESPONSE" | sed -nr "s/.*\"ssoid_cookie\": \"([^\"]+)\",.*/\1/p")"
}

# Download an app from Splunkbase give the app ID, app version, and session cookies.
# Acceptable session cookies are 'sid' and 'SSOID', or alternatively 'sessionid'.
download() {
	readonly APPID="$2"
	readonly APPVER="$3"
	if [ "$1" ]; then
		readonly COOKIE="sid=$4; SSOSID=$5"
	else
		readonly COOKIE="sessionid=$4"
	fi
	curl --cookie "$COOKIE" -L -O -J "$(eval "echo $BASE_DOWN_URL")"
}

# Print the useage instructions to the console
usage() {
	echo "$USAGE_INSTRUCTIONS"
}

# Main Menu
case "$1" in
	a|auth|authenticate)
		if [ "$#" -eq 3 ]; then
			authenticate "$2" "$3"
		else
			echo -e "Error: The authenticate mode requires exactly 2 arguments\n"
			usage
			exit 1
		fi
		;;
	d|down|download)
		case "$#" in
			4)	download 0 "$2" "$3" "$4";;
			5)	download 1 "$2" "$3" "$4" "$5";;
			*)
				echo -e "Error: The download mode requires 3 or 4 arguments\n"
				usage
				exit 1
				;;
		esac
		;;
	*)	usage;;
esac
