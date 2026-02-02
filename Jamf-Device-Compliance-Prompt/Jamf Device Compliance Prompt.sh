#!/bin/zsh
# shellcheck shell=bash

# Mobile Device Apps Report
# Inetum Polska Sp. z o.o.
# Author: Dawid Konopnicki
# Revision: 20260119

# ===============================================================
# Jamf Pro – Prompt user to run Self Service policy
# ===============================================================
#
# This script displays a macOS dialog to the currently logged-in user
# and, after confirmation, opens Jamf Self Service directly to a
# specific policy using a deep link.
#
# Typical use cases:
# - Device compliance registration (Azure AD / Entra ID)
# - Required post-enrollment setup steps
# - User-driven remediation workflows
#
# The script is intended to be executed from Jamf Pro as part of a
# policy, where the policy ID to open is provided as a script parameter.
#
# ---------------------------------------------------------------
# Requirements:
# - macOS
# - Jamf Pro–managed device
# - Jamf Self Service installed
#
# Jamf Script Parameters:
#   Parameter 4 = POLICY_ID (required)
# ---------------------------------------------------------------
#

# REQUIRED:
# The ID of the Jamf Pro policy that should be opened in Self Service.
# This value must be provided as Script Parameter 4 in Jamf Pro.
POLICY_ID="${4:-}"

# Customize this text to match your organization’s wording.
DIALOG="Please finish setting up your computer by running the Register Mac Device with Entra ID in Self Service. Click OK to get started!"

# Abort early if the required parameter is missing.
if [[ -z "${POLICY_ID}" ]]; then
	echo "ERROR: POLICY_ID not provided. Set Script Parameter 4 in Jamf Pro."
	exit 1
fi

# Identify the currently logged-in GUI user.
LOGGED_IN_USER="$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && !/loginwindow/ { print $3 }')"

if [[ -z "${LOGGED_IN_USER}" ]]; then
	echo "ERROR: Unable to determine logged-in user."
	exit 1
fi

# Path to the Self Service branding image.
ICON="/Users/${LOGGED_IN_USER}/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"

# Jamf stores the Self Service app path in its preferences.
# This allows support for renamed or relocated Self Service apps.
SELF_SERVICE_PATH="$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_app_path 2>/dev/null)"

if [[ -z "${SELF_SERVICE_PATH}" ]]; then
	SELF_SERVICE_PATH="$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_plus_path 2>/dev/null)"
	if [[ -z "${SELF_SERVICE_PATH}" ]]; then
		echo "Couldn't extract Self Service path."
		exit 1
	fi
fi

# Read the bundle display name from the app’s Info.plist.
# Self Service vs Self Service+ variant.
SELF_SERVICE_VARIANT="$(/usr/bin/defaults read "${SELF_SERVICE_PATH}/Contents/Info.plist" CFBundleName 2>/dev/null)"

#If a branded icon exists, include it in the dialog.
#Otherwise, fall back to a standard dialog to avoid errors.
if [[ -f "${ICON}" ]]; then
	ANSWER=$(
		osascript <<EOF
  button returned of (display dialog "$DIALOG" buttons {"OK"} default button 1 with icon POSIX file "$ICON")
EOF
	)
else
	ANSWER="$(
		/usr/bin/osascript <<EOF
  button returned of (display dialog "${DIALOG}" buttons {"OK"} default button 1)
EOF
	)"
fi

if [[ "${ANSWER}" == "OK" ]]; then

	# If Self Service is already running, terminate it.
	# This ensures the deep link opens reliably
	if [[ $(pgrep "Self Service" | grep -c .) -gt 2 ]]; then
		/usr/bin/pkill "Self Service"
	fi

	# Determine which URL scheme to use as it differs depending on Self Service Variant.
	if [[ "$SELF_SERVICE_VARIANT" == *"+"* ]]; then
		URL_SCHEME="selfservicecapability"
	else
		URL_SCHEME="jamfselfservice"
	fi

	# Open Self Service directly to the specified policy.
	/usr/bin/su "${LOGGED_IN_USER}" -c "/usr/bin/open \"${URL_SCHEME}://content?entity=policy&id=${POLICY_ID}&action=view\""
fi

exit 0
