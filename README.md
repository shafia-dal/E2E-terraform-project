## Terraform Infrastructure Deployment

This repository is designed to automate the creation and management of infrastructure using Terraform. It is intended to be used from a dedicated deployment server. The deployment server clones this repository and executes the Terraform scripts to provision resources.
## 📌 Project Overview

This infrastructure is fully automated using **Terraform** and deployed through a **deployment server**.  
The server clones this repository and runs the Terraform scripts to provision and manage the entire AWS environment.

## 🌐 Infrastructure Overview

This project implements a **CI/CD-enabled AWS Infrastructure** using **Terraform** to automate the deployment and management of cloud resources. Below is the flow and components involved:
![[project.svg]]

### 🟢 **Workflow Overview**

1. **Developer Workflow**
    - Developers push application code to a **GitHub Repository**.
    - The **Deployment Server** pulls the Terraform code from GitHub and runs it to provision
     infrastructure.
     
2. **CI/CD Pipeline (CodeBuild & CodeDeploy)**
    - **CodeBuild** fetches code from GitHub, builds the application, and packages it.
    - **CodeDeploy** deploys the built application to EC2 instances inside an **Auto Scaling Group**.
    
3. **Application Infrastructure**
    - The infrastructure is deployed inside a **VPC** with **Private Subnets** to enhance security.
    - An **Application Load Balancer (ALB)** is used to distribute user traffic across multiple EC2 instances.
    - **Route 53** manages the domain and routes user requests to the Load Balancer.
    
4. **Backend Services**
    - **Amazon RDS**: Stores application data in a managed relational database.
    - **Amazon EFS**: Provides shared storage for EC2 instances.
    - **ElastiCache Redis**: Improves application performance by caching frequently accessed data.
    
5. **Security**
    - The infrastructure uses appropriate **Security Groups** to control traffic flow between components.
    - Only required ports are allowed for communication.
    - **Private subnets** are used for databases and storage systems to avoid direct internet exposure.
## Getting Started

### Prerequisites

* **AWS Account:** You need an active AWS account with appropriate permissions to create and manage resources.
* **Terraform:** Terraform CLI must be installed on the deployment server. You can download and install it from the official Terraform website.
* **AWS CLI:** The AWS Command Line Interface (CLI) should be installed and configured on the deployment server with the necessary credentials to access your AWS account.
* **Git:** Git must be installed on the deployment server to clone this repository.

### Deployment Steps

1.  **Clone the Repository:**
```bash
git clone <repository_url>
cd <repository_name>
```
1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
    This command initializes the Terraform working directory, downloads the necessary provider plugins, and sets up the backend.
    
2.  **Plan the Infrastructure:**
    ```bash
    terraform plan
    ```
    This command creates an execution plan, showing you what changes Terraform will make to your infrastructure. Review the plan carefully.
    
3.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    This command applies the changes described in the execution plan, creating or modifying your infrastructure. You will be prompted to confirm the changes before they are applied.
    
4.  **Destroy the Infrastructure (if needed):**
    ```bash
    terraform destroy
    ```
    This command destroys all the resources managed by Terraform in the current working directory. Use with caution.


### **Key AWS Services Used**

| **Component**                 | **Purpose**                                   |
| ----------------------------- | --------------------------------------------- |
| **GitHub**                    | Stores application and Terraform code         |
| **CodeBuild**                 | Builds the application from source code       |
| **CodeDeploy**                | Automates deployment of the application       |
| **VPC**                       | Provides isolated network environment         |
| **EC2 (Auto Scaling Group)**  | Hosts the application servers                 |
| **Application Load Balancer** | Distributes incoming traffic to EC2 instances |
| **Route 53**                  | Provides DNS and domain routing               |
| **Amazon RDS**                | Manages relational database service           |
| **Amazon EFS**                | Provides shared file storage for EC2          |
| **ElastiCache Redis**         | Improves app performance with caching         |

### Infrastructure Components

The following AWS resources are provisioned using Terraform modules:

| Module Name            | Description                                                    |
|-----------------------|---------------------------------------------------------------|
| **VPC**               | Creates custom Virtual Private Cloud with subnets, routing, and NAT gateways |
| **EC2**               | Launches application servers within the VPC                    |
| **EFS**               | Creates an Elastic File System and attaches it to EC2 instances |
| **ASG (Auto Scaling Group)** | Manages EC2 instance scaling based on load          |
| **RDS**               | Creates a managed relational database in private subnet        |
| **Load Balancer (ALB)**| Distributes traffic to EC2 instances in ASG                  |

## Security Group Attachments

### EC2 & ALB

| Security Group         | Rule Type | Port                  | Source/Destination        | Purpose                                                |
| ---------------------- | --------- | --------------------- | ------------------------- | ------------------------------------------------------ |
| **EC2 Security Group** | Inbound   | 80, 443 (or app port) | **ALB Security Group**    | Accept traffic only from ALB                           |
| **EC2 Security Group** | Outbound  | All                   | 0.0.0.0/0 or anywhere     | Allow EC2 to send traffic outside (internet, DB, etc.) |
| **ALB Security Group** | Inbound   | 5000                  | **NextCLoud Application** | Allow public traffic from users to ALB                 |
| **ALB Security Group** | Outbound  | All                   | **EC2 Security Group**    | Forward traffic to EC2 instances (Target Group)        |
- **Public users** hit the **ALB** → ALB accepts traffic (Inbound: 80/443).
- ALB **forwards requests to EC2** → EC2 allows only traffic coming **from ALB SG** (secure & controlled).
- **EC2 instances can send outbound traffic freely** (updates, S3, DB, etc.).
- ALB can send outbound traffic only to **EC2 instances** on specific ports.

### EC2 & EFS

| Security Group                  | Rule Type | Port | Source/Destination                 | Purpose                                    |
| ------------------------------- | --------- | ---- | ---------------------------------- | ------------------------------------------ |
| **Instance Security Group**     | Outbound  | 2049 | Mount Target SG (or 0.0.0.0/0)     | Allows EC2 to initiate NFS connection      |
| **Instance Security Group**     | Inbound   | —    | —                                  | Not required (client doesn't need inbound) |
| **Mount Target Security Group** | Inbound   | 2049 | Instance Security Group            | Accepts NFS connections from EC2           |
| **Mount Target Security Group** | Outbound  | 2049 | Instance Security Group / Anywhere | Allows response traffic                    |
- **EC2 (App server)** wants to talk to **EFS**.
- EC2 has **outbound rule to EC2** on EFS port (so server can connect to file system).
- EFS has **inbound rule from EC2 SG** on  port 2049(so EFS accepts traffic only from EC2).
- **EFS outbound rule is open to port 2049** 

### EC2 & RDS

| Security Group         | Rule Type | Port                                     | Source/Destination      | Purpose                                      |
| ---------------------- | --------- | ---------------------------------------- | ----------------------- | -------------------------------------------- |
| **RDS Security Group** | Inbound   | 3306 (MySQL) / 5432 (Postgres) / DB Port | **EC2 Security Group**  | Allow DB traffic **only from EC2 instances** |
| **RDS Security Group** | Outbound  | All                                      | 0.0.0.0/0 (or anywhere) | Allow RDS to send responses or updates       |
| **EC2 Security Group** | Outbound  | DB Port                                  | **RDS Security Group**  | Allow EC2 to connect to RDS                  |
| **EC2 Security Group** | Inbound   | App Port                                 | ALB Security Group      | (Already defined in previous table)          |
- **EC2 (App server)** wants to talk to **RDS (Database)**.
- EC2 has **outbound rule to RDS SG** on DB port (so app can connect to DB).
- RDS SG has **inbound rule from EC2 SG** on DB port (so DB accepts traffic only from EC2).
- **RDS outbound rule is open (all)** → This is required so DB can reply to queries and connect to AWS services if needed.










