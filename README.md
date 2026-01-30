DevOps Automation Toolkit

A growing collection of production-style automation scripts and infrastructure helpers designed to simplify real-world DevOps and SRE tasks.

This repository goes beyond basic scripting and focuses on how automation is written and used in real environments.

🎯 Why this repository exists

In production systems, DevOps engineers don’t just run commands.

They:

automate repeatable work

handle failures safely

log everything for debugging

design scripts that can be re-run without breaking systems

This toolkit is built with that exact mindset.

If you are:

Preparing for DevOps / SRE interviews

Working with Linux and cloud servers

Learning automation the right way

Transitioning into DevOps from another role

This repository is for you.

🧠 Key Concepts Covered

This project focuses on core DevOps principles, not just tools:

Linux system administration automation

Bash scripting best practices

Root access validation and safety checks

Idempotent operations (safe re-runs)

Exit status handling ($?)

Reusable functions

Centralized logging (/var/log)

Fail-fast execution patterns

Error tracking using trap and $LINENO

Systemd service automation

Cloud automation using AWS CLI

📂 Repository Structure
devops-automation-toolkit/
├── bash_scripts/              # Linux & Bash automation
│   ├── user input handling
│   ├── package installation
│   ├── logging & validation
│   ├── idempotent scripts
│   └── error handling patterns
│
├── aws-automation/            # Cloud automation (AWS CLI)
│   ├── roboshop.sh            # EC2 + Route53 automation
│   ├── mongodb.sh             # MongoDB installation & config
│   ├── catalogue.sh           # App deployment automation
│   ├── catalogue.service      # systemd service definition
│   └── mongo.repo             # MongoDB repository config
│
├── README.md
├── LICENSE
└── .gitignore

⚙️ Platforms & Tools Used

Linux (Ubuntu, RHEL-based systems)

Bash

AWS CLI

EC2, Route53

systemd

MongoDB

Node.js

🚀 How to use this repository

Each script is:

self-contained

well-structured

written with learning and reuse in mind

You can:

run scripts directly on servers

read them to understand real-world automation

adapt them for your own projects

🔮 What’s coming next

This repository will continue to grow with:

more AWS automation

environment-specific scripts

improved error handling patterns

production-style deployment workflows

🤝 Contributions & Feedback

Suggestions, improvements, and feedback are always welcome.
This repository is meant to learn, practice, and improve together.
