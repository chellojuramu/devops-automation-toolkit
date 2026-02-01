# AWS Automation – RoboShop

This directory contains **end-to-end automation scripts** to provision AWS infrastructure and deploy the **RoboShop microservices application** using real-world DevOps practices.

The goal is to move from **manual server setup** to **repeatable, reliable automation**.

---

## 🚀 What this project does

- Provisions EC2 instances using **AWS CLI**
- Automatically creates DNS records using **Route53**
- Installs and configures core services:
  - MongoDB
  - Redis
  - Frontend (Nginx)
  - Catalogue service
  - User service
- Manages applications using **systemd services**
- Adds logging and validation to every step

---

## 🔐 Configuration approach (Important)

All application configuration is handled using **external environment files**, not hardcoded values.

This follows **production best practices**:
- Secrets are not committed to Git
- Scripts stay reusable across environments
- Configuration can change without touching code

Before starting services, environment files must be created **on the server**.

Example:
- `/etc/roboshop/catalogue.env`
- `/etc/roboshop/user.env`

These files are loaded using `EnvironmentFile` in systemd services.

---

## ▶️ How to use (high level)

1. Provision infrastructure using AWS CLI automation
2. Configure database and cache services
3. Create required environment files on the instance
4. Deploy application services
5. Configure frontend and reverse proxy

---

## 🧠 Key DevOps concepts practiced

- Infrastructure as Code (AWS CLI)
- systemd service automation
- Externalized configuration
- Idempotent scripting
- Logging and validation
- Real microservice deployment workflow

---

This folder represents **hands-on DevOps automation**, built step by step from class learning and real practice.
