# DevOps Automation Toolkit

A collection of **production-grade Bash automation scripts** designed to simplify day-to-day Linux and DevOps operations.

This repository focuses on **real-world system administration tasks**, following **SRE best practices** such as:
- Idempotency
- Error handling
- Logging
- Safe automation

---

## 🎯 Why this repository exists

In real environments, DevOps engineers don’t just *run commands* —  
they **automate safely**, **log everything**, and **fail fast** when something goes wrong.

This toolkit is built with that mindset.

If you are:
- Preparing for DevOps / SRE interviews  
- Working on Linux servers daily  
- Learning how to write **clean, reusable shell scripts**

This repo is for you.

---

## 🧠 Key Concepts Covered

This repository intentionally focuses on **foundational DevOps principles**, not just syntax:

- Bash scripting best practices
- Root access validation
- Secure user input handling
- Package installation automation
- Idempotent operations (safe re-runs)
- Exit status checks (`$?`)
- Reusable functions
- Centralized logging (`/var/log`)
- Fail-fast execution using `set -e`
- Error tracking with `trap` and `$LINENO`
- Production-style script structure

---

## 📂 Repository Structure

```text
devops-automation-toolkit/
├── bash_scripts/
│   ├── 01-user-input-read.sh               # Secure user input handling
│   ├── 03-install-packages.sh               # Basic package installation
│   ├── 04-install-packages-logging.sh       # Installation with logging
│   ├── 14-install-packages-idempotent.sh    # Idempotent package installs
│   ├── 15-set-e-package-install.sh           # Fail-fast automation (set -e)
│   ├── 17-set-e-trap-idempotent-installer.sh # trap + detailed error reporting
│   ├── user_creator.sh                      # Automated Linux user creation
│   └── variables.sh                         # Bash variables & fundamentals
├── README.md
├── LICENSE
└── .gitignore
