# 💰 AWS Cost Optimization Toolkit

## 📌 Overview
This repository contains a collection of automation scripts designed to identify, report, and manage AWS resource usage. The primary goal is **FinOps & Cost Optimization**—ensuring that cloud costs are minimized by detecting unused or "zombie" resources.

## 🛠 Prerequisites
Before running these scripts, ensure your environment has the following tools installed:

| Tool | Purpose | Installation (RHEL/CentOS) |
| :--- | :--- | :--- |
| **AWS CLI v2** | To interact with AWS services | [Official Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| **JQ** | To parse JSON output into readable reports | `sudo dnf install jq -y` |
| **MSMTP** | To send HTML email alerts | `sudo dnf install msmtp -y` |

## 📂 Scripts Inventory

| Script Name | Function | Frequency |
| :--- | :--- | :--- |
| `aws_resource_tracker.sh` | Generates a consolidated daily report of **S3, EC2, Lambda, IAM, and EBS** usage. Alerts on "Available" (unused) volumes. | Daily (Cron) |
| `mail.sh` | A utility script that sends HTML-formatted emails. Used by other scripts to deliver reports. | On-Demand |
| *(Future)* `clean_snapshots.sh` | *Planned: Delete snapshots older than 30 days.* | Monthly |
| *(Future)* `release_eips.sh` | *Planned: Release unattached Elastic IPs.* | Weekly |

## ⚙️ Configuration

### 1. Email Setup (MSMTP)
Ensure your `/etc/msmtprc` is configured with your SMTP provider (e.g., Gmail App Password). These scripts use `msmtp` to send HTML reports.

### 2. Template Customization
The `template.html` file controls the look and feel of the email reports.
- **Do not rename** `template.html` (it is linked to `mail.sh`).
- You can modify the CSS in `<style>` tags to match your company branding.

## 🚀 How to Run

### Manual Execution
To run the main resource tracker manually:

```bash
cd aws-cost-optimization
chmod +x *.sh
./aws_resource_tracker.sh