# Set Computer Name

[![License: MIT](https://img.shields.io/github/license/Inetum-Poland/jamf-scripts?color=yellow)](https://github.com/Inetum-Poland/jamf-scripts?tab=MIT-1-ov-file#)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](#)
[![MDM: Jamf Pro](https://img.shields.io/badge/MDM-Jamf%20Pro-blue)](#)
[![Shell](https://img.shields.io/badge/shell-zsh-green)](#)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](#)

**Jamf Pro script created by Inetum Poland that enforces a standardized computer naming convention based on the Jamf Pro ID.**

The script validates the current computer name and, if it does not match the expected format, automatically generates and applies a new name using a configurable prefix and zero-padded identifier. Optionally, it updates the Jamf asset tag to match the enforced computer name and/or adds a suffix for virtual machines.

To improve reliability and reduce unnecessary inventory updates, the script can retrieve the Jamf Pro computer ID from a supporting Configuration Profile based on a Jamf Custom Schema included in this repository.

---

## Overview

This solution consists of two components:

1. **Set Computer Name script**
   - Validates and enforces the computer naming convention
   - Uses the Jamf Pro computer ID as the unique identifier
2. **Supporting Configuration Profile**
   - Uses a Jamf Custom Schema
   - Stores device identifiers locally in a preference domain
   - Allows the script to read the Jamf Pro ID without relying on immediate `jamf recon`

While the script can fall back to `jamf recon` if needed, deploying the Configuration Profile is strongly recommended.

---

## Features

- Enforces a predictable computer naming scheme (e.g. `MAC00067`)
- Uses the **Jamf Pro ID** as the authoritative identifier
- Supports:
  - Custom computer name prefix
  - Configurable number of digits
  - Optional suffix for virtual machines
- Automatically sets:
  - `ComputerName`
  - `LocalHostName`
  - `HostName`
- Optionally updates the Jamf asset tag in Jamf Pro
- Safely skips renaming if the current computer name already matches the expected format

---

## Naming Convention

By default, computer names follow this format:
- Example (defaults):
`MAC00067`
- For virtual machines (if enabled):
`MAC00067-VM`
- The script validates computer names using a regular expression equivalent to:
`^PREFIX[0-9]{DIGITS}(-VM)?$`

---

## Script Configuration

The script is configured using **Jamf Pro script parameters**:

| Parameter | Description | Default |
|----------|-------------|---------|
| 4 | Computer name prefix | `MAC` |
| 5 | Number of digits after the prefix | `5` |
| 6 | Preference domain used by the Custom Schema | `com.domain.AboutMac` |
| 7 | Preference key containing the Jamf Pro ID | `Jamf Pro ID` |

Suggested parameter labels are provided at the beggining of the script.

Additional behavior is controlled internally in the script:

- Asset tag updates
- Virtual machine detection and suffixing

---

## Supporting Configuration Profile

A recommended Jamf Configuration Profile Custom Schema and .mobileconfig alternative are included in this repository.

### Purpose

The Configuration Profile stores device identifiers locally, allowing the script to:

- Retrieve the Jamf Pro computer ID without waiting for inventory submission
- Reduce dependency on `jamf recon`
- Improve reliability during enrollment and early provisioning stages

### Preference Domain

The script expects the Configuration Profile to write data to the following domain:
```com.domain.AboutMac```
The **Jamf Pro ID** key is required for full functionality.

---

## Deployment

### 1. Deploy the Configuration Profile

- Edit and upload the provided Configuration Profile to Jamf Pro
or
- Create a Configuration Profile using the schema
- Scope it to all devices where this script will be used

### 2. Deploy the Script

- Upload the script to Jamf Pro
- Configure parameters 4–7 as needed
- Add the script to a policy

**Recommended policy triggers:**
- Enrollment Complete
- Recurring check-in
- or Custom Trigger called during enrollment workflow (e.g. [Jamf Setup Manager](https://github.com/jamf/Setup-Manager)

> [!IMPORTANT]  
> The Configuration Profile should be installed **before** the script to avoid unnecessary fallback to `jamf recon`.

---

## Logging & Debugging

- Script output is available in Jamf policy logs
- To enable verbose shell debugging:
```touch /tmp/debug```

---

## Contribution

Contributions are welcome! To contribute, [create a fork](https://github.com/Inetum-Poland/jamf-scripts/fork) of this repository, commit and push changes to a branch of your fork, and then submit a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request). Your changes will be reviewed by a project maintainer.

Contributions don’t have to be code; we appreciate any help in answering [issues](https://github.com/Inetum-Poland/jamf-scripts/issues).

---

## Credits

[**Set Computer Name**](https://github.com/Inetum-Poland/jamf-scripts/Set%20Computer%20Name) was created by the **Apple Business Unit** at **Inetum Polska Sp. z o.o.**
Author: **Bartłomiej Sojka**

Designed for enterprise macOS environments using Jamf Pro, with an emphasis on deterministic naming and low-friction automation.
