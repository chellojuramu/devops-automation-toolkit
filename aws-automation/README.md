# RoboShop Microservices Deployment Automation (AWS)

This repository contains a professional-grade DevOps automation toolkit designed to bootstrap, configure, and deploy the multi-tier **RoboShop microservices application** on **RHEL / Amazon Linux 9**.

---

## 🚀 Architectural Overview

The project automates a distributed system consisting of:

- **Node.js**
- **Java**
- **Python**
- **GoLang**

These services are integrated with distributed backend systems such as:

- MongoDB  
- MySQL  
- Redis  
- RabbitMQ  

---

## 🛠 Features & Engineering Standards

### 🔹 Idempotency  
All scripts are designed to be run multiple times without causing:

- System inconsistencies  
- Duplicate users  
- Duplicate directories  

### 🔹 Zero-Secret Footprint  
- No credentials or hostnames are hardcoded  
- All secrets are passed dynamically  
- Environment-specific configurations are managed using localized `.env` files  

### 🔹 Decoupled Configuration  
- Uses **SystemD EnvironmentFile**  
- Keeps application logic separate from environment configuration  

### 🔹 Centralized Logging  
- All automation logs are stored under: /var/log/shell-roboshop/

- Enables easy debugging and auditability  

### 🔹 Defensive Scripting  
- Root user validation  
- Real-time execution checks  
- Proper error handling at each step  

---

## 📖 Deployment Guide

### 1. Prerequisites

Before executing the deployment scripts, the following **environment files must be created** on target instances.

This ensures a clean separation between automation logic and environment-specific configuration.

| Service  | Required File Path             | Key Variables to Include |
|--------|--------------------------------|--------------------------|
| Cart / User | `/etc/roboshop/cart.env`      | REDIS_HOST, CATALOGUE_HOST, CATALOGUE_PORT |
| Shipping | `/etc/roboshop/shipping.env`  | CART_ENDPOINT, DB_HOST |
| Payment  | `/etc/roboshop/payment.env`   | CART_HOST, USER_HOST, AMQP_HOST, AMQP_USER, AMQP_PASS |
| Dispatch | `/etc/roboshop/dispatch.env`  | AMQP_HOST, AMQP_USER, AMQP_PASS |

---

### 2. Execution & Argument Passing

To maintain high security, sensitive credentials and dynamic endpoints are passed as positional parameters at runtime.

#### Usage Pattern:
## 📂 Repository Structure

```plaintext
aws-automation/
├── common.sh       # Reusable functions (Validation, Logging, User Creation)
├── mongodb.sh      # NoSQL Database setup
├── mysql.sh        # SQL Database setup & password parameterization
├── redis.sh        # In-memory cache configuration
├── rabbitmq.sh     # Message broker setup & idempotent user management
├── catalogue.sh    # Node.js backend setup
├── cart.sh         # Node.js backend setup
├── user.sh         # Node.js backend setup
├── shipping.sh     # Java/Maven build & schema loading
├── payment.sh      # Python/uWSGI application deployment
└── dispatch.sh     # GoLang binary compilation & deployment
```



