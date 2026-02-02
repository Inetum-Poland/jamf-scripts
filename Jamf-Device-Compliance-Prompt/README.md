# Jamf Pro – Device Compliance Prompt

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)
![Jamf Pro](https://img.shields.io/badge/Jamf-Pro-blue)
![Shell](https://img.shields.io/badge/shell-zsh-green)
![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)

A super simple zsh script for Jamf Pro that prompts the currently logged-in macOS user with a dialog, and (after they click **OK**) opens **Jamf Self Service** directly to a specific **policy** using a deep link.

## What this can be used for

Typical use cases:
- Device compliance / registration workflows (Azure AD / Entra ID)
- Required post-enrollment steps
- User-driven remediation (e.g., “click here to run the fix”)

## How it works (high level)

1. Jamf Pro runs the script (via policy).
2. The script detects the currently logged-in GUI user.
3. It displays a macOS dialog (optionally with the Self Service branding image if available).
4. When the user clicks **OK**, it opens Self Service (or Self Service+) to a specific policy ID via deep link.

<img width="488" height="232" alt="image" src="https://github.com/user-attachments/assets/51fa5dc0-69fb-4fb7-8ed4-d8fa4b4dca74" />


## Requirements

- macOS
- Jamf Pro–managed device
- Jamf Self Service installed (Self Service or Self Service+)

## Jamf Script Parameters

- **Parameter 4**: `POLICY_ID` *(required)*  
  This is the Jamf Pro Policy ID you want to open in Self Service.

If Parameter 4 is missing, the script exits with an error.

## Setup (Jamf Pro)

1. Upload the script to **Settings → Computer Management → Scripts**
2. In the policy where you run this script, set:
   - **Script Parameter 4** = the target **Policy ID**
3. (Optional) Customize the dialog text by editing the `DIALOG` variable in the script.

## Notes

- The script reads the Self Service app path from:
  - `/Library/Preferences/com.jamfsoftware.jamf.plist` (`self_service_app_path` or `self_service_plus_path`)
- It automatically selects the correct URL scheme depending on whether the app is **Self Service** or **Self Service+**
- If Self Service appears to be running, the script may terminate it first to make the deep link open reliably

## Example deep link behavior

When the user clicks **OK**, Self Service opens to:

`...://content?entity=policy&id=<POLICY_ID>&action=view`

## License

Licensed under the MIT License.
Copyright © 2026 Inetum Polska Sp. z o.o.
Authored by Dawid Konopnicki.
