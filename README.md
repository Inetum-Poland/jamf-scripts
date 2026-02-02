# Jamf Pro Scripts

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)
![Jamf Pro](https://img.shields.io/badge/Jamf-Pro-blue)
![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)

A collection of small, focused automation scripts for Jamf Pro–managed macOS environments.

Each script lives in its own folder with dedicated documentation and can be used independently.

---

## Scripts

| Script | Description |
|------|-------------|
| [Jamf Device Compliance Prompt](./Jamf-Device-Compliance-Prompt/) | Prompts end users via Jamf Self Service to complete Device Compliance registration. |
| [Set Computer Name](./Set%20Computer%20Name/) | Automatically sets the Mac computer name using a configurable prefix and zero-padded Jamf Pro ID. |

---

## Usage

Each script is self-contained.

To use a script:
1. Navigate to its folder
2. Review the README for requirements and configuration
3. Deploy using Jamf Pro (policy, Self Service, or extension attribute as appropriate)

---

## Repository Structure

```text
.
├── Jamf-Device-Compliance-Prompt/
│   ├── Jamf Device Compliance Prompt.sh
│   └── README.md
├── Set Computer Name/
│   ├── About Mac/
│   │   ├── About Mac.mobileconfig
│   │   └── About Mac.json
│   ├── Set Computer Name.sh
│   └── README.md
└── LICENSE
```

---

## Contribution

Contributions are welcome! To contribute, [create a fork](https://github.com/Inetum-Poland/jamf-scripts/fork) of this repository, commit and push changes to a branch of your fork, and then submit a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request). Your changes will be reviewed by a project maintainer.

Contributions don’t have to be code; we appreciate any help in answering [issues](https://github.com/Inetum-Poland/jamf-scripts/issues).

---

## Credits

[**Jamf Pro Scripts**](https://github.com/Inetum-Poland/jamf-scripts) were created by the **Apple Business Unit** at **Inetum Polska Sp. z o.o.**

This repository is licensed under the MIT License.

Each script may be copied, modified, and used independently under the same terms.
