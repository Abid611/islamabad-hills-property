# 🏠 Islamabad Hills Property Management - Salesforce Application

This project is designed to provide real-world experience in developing a full-fledged Salesforce application. It's ideal for developers aiming to enhance their skills in Apex, Lightning Web Components (LWC), integrations, and automation within the Salesforce ecosystem.

---

## 📌 Project Overview

The Islamabad Hills Property Management application facilitates the management of rental properties, tenants, and contracts. It incorporates features like property availability checks, contract creation, tenant management, and automated notifications, providing a holistic solution for property management needs.

---

## 🧰 Technologies & Tools Used

- Salesforce Platform (Developer Edition)
- Apex (Triggers, Batch Apex, Queueable, Scheduler)
- Lightning Web Components (LWC)
- REST API Integrations
- Named Credentials & Auth Providers
- Git & GitHub for version control

---

## 🏗️ Key Features Implemented

### 🔐 Salesforce Administration

- Custom Objects: `Property__c`, `Tenant__c`, `Rental_Contract__c`


### ⚙️ Apex Development

- Triggers for automated field updates and validations
- Batch Apex for processing large datasets (e.g., contract expirations)
- Queueable Apex for sending asynchronous email notifications
- Scheduler classes to automate daily tasks
- REST API callouts to external Salesforce orgs for property availability and contract creation

### 🌐 Lightning Web Components (LWC)

- Dynamic property listing with filters based on rent amount and property type
- Tenant lookup functionality with navigation to create new tenant records
- Modal forms for contract creation with real-time validations
- Integration with Apex controllers for data retrieval and processing

### 🔄 Integrations

- External API call to check property availability in a secondary Salesforce org
- API call to create rental contracts and retrieve Ejari numbers
- Automated email notifications to tenants with contract details and Ejari numbers

---

## 🧪 Testing & Code Coverage

- Comprehensive test classes covering all Apex logic
- Use of mock responses for testing API callouts
- Achieved over 90% code coverage across the application

---

## 👨‍💻 Author

Abid Ullah
Salesforce Developer  
