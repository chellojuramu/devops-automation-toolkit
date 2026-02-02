# 🛠️ DevOps Automation Toolkit  
### From Scripting Fundamentals to Microservices Orchestration

This repository serves as a comprehensive professional portfolio of **Infrastructure as Code (IaC)** and **Configuration Management**. It documents a structured progression from advanced Linux shell scripting to the end-to-end automated deployment of a **production-grade microservices architecture (RoboShop) on AWS**.

---

## 🌟 Project Highlights

- **Full-Stack Orchestration**  
  Automated deployment of 7+ microservices built using GoLang, Python, Java, and Node.js.

- **MNC-Standard Engineering Practices**  
  Implemented Idempotency, Error Trapping, and Dynamic Configuration Management using SystemD and Environment Variables.

- **Hybrid Database Integration**  
  Seamless configuration and automation of MongoDB, Redis, MySQL, and RabbitMQ within a private VPC.

- **Professional Observability**  
  Centralized logging with SyslogIdentifier and journalctl for real-time debugging and monitoring.

---

## 📂 Repository Structure

The repository is divided into two core learning and implementation phases:

---

### 1. bash_scripts/ – Fundamentals & Logic

This module demonstrates mastery of Linux internals and scripting best practices required for senior DevOps roles:

- **Idempotency & Logic**  
  Advanced `if-elif-else` patterns and reusable functions for package installation.

- **Security**  
  Implementation of secure user input handling and automated password generation (`user_creator.sh`).

- **Robustness**  
  Usage of `set -e` and `trap` to ensure scripts fail gracefully during execution errors.

---

### 2. aws-automation/ – RoboShop Microservices

The capstone project: A complete automation suite for the RoboShop E-commerce platform.

- **Frontend**  
  Nginx Reverse Proxy configuration with dynamic internal DNS resolution.

- **Backend**  
  Build and deployment automation for:
  - GoLang (Dispatch)
  - Java (Shipping)
  - Python (Payment)
  - Node.js (Cart / User / Catalogue)

- **Database Layer**  
  Automated schema loading and cluster initialization for both SQL and NoSQL databases.

---

## 🚀 Engineering Standards (MNC Ready)

### 🔐 Zero-Secret Footprint

To adhere to professional security audits:

- No credentials or hostnames are hardcoded  
- All sensitive data is injected at runtime using:

**Positional Parameters**
```bash
sudo sh mysql.sh <db_password>
```

**Environment Files**
```
/etc/roboshop/*.env
```

This ensures complete separation between configuration and application logic.

---

### 🔄 Idempotency

Every script is built with the **“Run-Again Philosophy”**:

- Safe to execute multiple times  
- Prevents duplicate users, services, and configurations  
- Validates existing system states before performing any action  

Example:
- Checking for existing user using `id roboshop`
- Conditional database initialization  
- Package installation checks  

---

## 🎯 Final Objective

This repository demonstrates:

- Real-world DevOps automation standards  
- Enterprise-grade deployment methodology  
- Production-ready scripting and configuration management  

A complete journey from **Linux shell scripting fundamentals → AWS microservices automation.**

---

### Happy Automating! 🚀
