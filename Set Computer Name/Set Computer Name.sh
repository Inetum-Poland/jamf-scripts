#!/bin/zsh --no-rcs

# SET COMPUTER NAME
# Inetum Polska Sp. z o.o.
# Author: Bartłomiej Sojka
# Revision: 20250703

# Jamf Parameter Labels:
# 4. Computer Name prefix (default: MAC):
# 5. No. of digits after the prefix (default: 5):
# 6. [optional] Jamf Pro ID CP domain (string, default — com.domain.AboutMac):
# 7. [optional] Jamf Pro ID CP key (string, default — Jamf Pro ID):

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

[ -f /tmp/debug ] && set -x

# CONFIGURABLES: ———————————————————————————————————————————————————————————————————————————————————

# Smart Group regex example: ^PREFIX[0-9]{5}$
PREFIX="${4}"
DIGITS_NO="${5}"
CP_DOMAIN="${6}"
CP_KEY="${7}"

UPDATE_ASSET_TAG=true
TAG_VIRTUAL_MACHINES=true
VM_SUFFIX="-VM"

# PREREQUISITES: ———————————————————————————————————————————————————————————————————————————————————

[[ -z "${PREFIX}" ]] && PREFIX="MAC"
[[ -z "${DIGITS_NO}" ]] || [[ -n "${DIGITS_NO//[0-9]/}" ]] && DIGITS_NO=5
[[ -z "${CP_DOMAIN}" ]] && CP_DOMAIN="com.domain.AboutMac"
[[ -z "${CP_KEY}" ]] && CP_KEY="Jamf Pro ID"

JAMF=/usr/local/bin/jamf
[[ $(sysctl -n machdep.cpu.features kern.hv_vmm_present 2>/dev/null) =~ ((^|[^[:alnum:]])VMM([^[:alnum:]]|$)|^.*1$) ]] && VM=true || VM=false

# FUNCTIONS: ———————————————————————————————————————————————————————————————————————————————————————

function exitWith() {
	echo -e "${2}"
	exit "${1}"
}

function readPreference() {
	local DOMAIN="${1}"
	local KEY="${2}"
	local VALUE
	VALUE="$(osascript -l JavaScript \
		-e "ObjC.import('Foundation')" \
		-e 'ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName("'"${DOMAIN}"'").valueForKey("'"${KEY}"'"))' \
		2>/dev/null)"
	[[ -n "$VALUE" ]] && printf '%s' "${VALUE}" || return 1
}

function validateComputerName() {
	local COMPUTER_NAME="${1}"
	if [[ "${COMPUTER_NAME}" =~ ^"${PREFIX}"[[:digit:]]{"${DIGITS_NO}"}$ ]]; then
		return 0
	elif $TAG_VIRTUAL_MACHINES && [[ "${COMPUTER_NAME}" =~ ^"${PREFIX}"[[:digit:]]{"${DIGITS_NO}"}"${VM_SUFFIX}"$ ]]; then
		return 0
	else
		return 1
	fi
}

function addLeadingZeros() {
	local DIGITS=${1}
	local DIGITS_LENGTH=${#1}
	for ((i = 0; i < $((DIGITS_NO - DIGITS_LENGTH)); i++)); do
		DIGITS="0${DIGITS}"
	done
	echo "${DIGITS}"
}

function setComputerName() {
	local COMPUTER_NAME="${1}"
	echo "Changing computer name to \"${COMPUTER_NAME}\"."
	scutil --set ComputerName "${COMPUTER_NAME}"
	scutil --set LocalHostName "${COMPUTER_NAME// /-}"
	# Uncomment the line below and comment out the next to not enforce the HostName if it is not set (default in macOS):
	# scutil --get HostName &>/dev/null && scutil --set HostName "${COMPUTER_NAME// /-}"
	scutil --set HostName "${COMPUTER_NAME// /-}"
}

# SCRIPT: ——————————————————————————————————————————————————————————————————————————————————————————

COMPUTER_NAME="$(scutil --get ComputerName)"

if ! validateComputerName "${COMPUTER_NAME}"; then
	JSS_ID="$(readPreference "${CP_DOMAIN}" "${CP_KEY}")"
	if [[ -z "${JSS_ID}" ]] || [[ -n "${JSS_ID//[0-9]/}" ]]; then
		echo "Unable to obtain Jamf Pro ID from \"${CP_DOMAIN}\". Falling back to Recon…"
		JSS_ID="$(${JAMF} recon 2>/dev/null | awk -F'<|>' '/computer_id/ {print $3}')"
		[[ -z "${JSS_ID}" ]] || [[ -n "${JSS_ID//[0-9]/}" ]] && exitWith 1 "ERROR: Unable to obtain JSS ID from Recon\x21"
	fi

	DIGITS="$(addLeadingZeros "${JSS_ID}")"
	COMPUTER_NAME="${PREFIX}${DIGITS}"
	$VM && $TAG_VIRTUAL_MACHINES && COMPUTER_NAME="${COMPUTER_NAME}${VM_SUFFIX}"

	if validateComputerName "${COMPUTER_NAME}"; then
		setComputerName "${COMPUTER_NAME}"
	else
		exitWith 2 "ERROR: Failed to validate \"${COMPUTER_NAME}\" computer name/x21"
	fi
else
	echo "Current computer name \"${COMPUTER_NAME}\" successfully validated."
fi

if $UPDATE_ASSET_TAG && ! $VM; then
	${JAMF} recon -assetTag "${COMPUTER_NAME}" &>/dev/null && exitWith 0 "Updated the Asset Tag."
else
	${JAMF} recon &>/dev/null && exit 0
fi
