
# 🌍 Terraform Notes – The Complete Guide for Beginners

> Author: **Deepakraj Ravi**  
> Use Case: A structured and practical Terraform reference for DevOps practitioners and learners.

---

## ✅ What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool developed by HashiCorp that enables you to **define, provision, and manage infrastructure** in a safe, repeatable way using a simple configuration language called **HCL (HashiCorp Configuration Language).**

---

## 🚀 What Can You Do With Terraform?

- **Manage any kind of infrastructure** across multiple providers like AWS, Azure, GCP, etc.
- **Track infrastructure changes** using a state file (`terraform.tfstate`).
- **Automate provisioning and changes** in your infrastructure.
- **Version control infrastructure** (excluding state files) using Git.
- **Standardize and collaborate** on infrastructure as code with teams.

---

## 🔄 Terraform Lifecycle

1. **Write Configuration**  
   Use `.tf` files written in HCL to describe the desired infrastructure. Documentation is well-maintained on the [Terraform Docs](https://registry.terraform.io/).

2. **Initialize**  
   Run `terraform init` to download the required provider plugins and initialize the working directory.

3. **Plan (Dry Run)**  
   Use `terraform plan` to preview changes **without applying** them. This helps you review what Terraform intends to do.

4. **Apply**  
   Run `terraform apply` to provision the defined infrastructure. It updates the **state file** after execution.

5. **Destroy**  
   Use `terraform destroy` to remove all infrastructure resources defined in the configuration.

---

## 🛠️ Common Terraform Commands

```bash
terraform init       # Initialize Terraform project
terraform plan       # Show execution plan
terraform apply      # Apply the changes
terraform destroy    # Destroy all infrastructure
```

---

## 🧱 Terraform File Structure

```bash
main.tf         → Main configuration file (provider & resources)
input.tf        → Input variables
output.tf       → Output values after deployment
terraform.tfstate → Auto-generated file that stores the infrastructure state
```

- 🔒 **Best Practice**: Never version-control `terraform.tfstate`. Store it in a **remote backend (e.g., S3)** instead.

---

## 🔐 State File Management

- Terraform uses the **state file** as the single source of truth.
- Store it in a **centralized location** (e.g., S3 bucket) with **read-only access for users**.
- Terraform should have **write access** to update it after every apply.
- For **safe concurrent use**, lock it using **DynamoDB**.

```hcl
# backend config for remote state
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
```

---

## 📁 Example `main.tf` – Basic AWS Instance

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```

🔁 The provider block (e.g., AWS region) remains the same for most files unless the infrastructure or environment changes.

---

## 🧮 Variables and Outputs

### Input Variables – `input.tf`

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

### Output Values – `output.tf`

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

---

## 🔀 Using Modules

Modules are reusable Terraform components. They help organize large Terraform projects and reduce duplication.

```hcl
module "ec2_instance" {
  source = "./modules/ec2"
  instance_type = var.instance_type
}
```

---

## 🗂️ Isolate and Organize Terraform Scripts

- Break Terraform into **logical directories** by service or component.
- Helps reduce the **blast radius** during changes.
- Keeps the infrastructure **modular and maintainable**.

---

## 🌐 Remote State Setup

1. Create an **S3 bucket** for storing state files.
2. Create a **DynamoDB table** to lock state during concurrent operations.
3. Define the remote backend in the `terraform` block of your local `main.tf`.

> ✅ Best Practice: Keep Terraform configuration in Git (version control) and store state separately in a remote backend.

---

## ⚙️ Terraform Roles & Responsibilities

- **Main.tf** → Resource definitions and providers.
- **Remote State** → S3 + DynamoDB for lock.
- **Local Execution** → Terraform CLI.
- **Version Control** → Exclude state file (`.gitignore`).

---

## ❌ Common Problems with Terraform

1. **Single Source of Truth**  
   - The state file is the only record of current infra. If it’s lost or corrupted, recovery is difficult.

2. **Manual Drift**  
   - Changes made directly in the cloud console are **not detected** unless explicitly refreshed.

3. **Not GitOps Friendly**  
   - Poor native integration with GitOps tools like **ArgoCD or Flux**.

4. **Complexity at Scale**  
   - Without modules and workspaces, managing large infrastructure can become chaotic.

5. **Not for Configuration Management**  
   - Terraform is meant for provisioning, not managing software/configurations on provisioned systems (use Ansible for that).

---

## 📦 Final Structure Example

```
terraform-project/
│
├── main.tf
├── input.tf
├── output.tf
├── variables.tf
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── backend/
    └── s3_dynamodb.tf
```

---

## ✅ Summary

| Feature                | Description                                                |
|------------------------|------------------------------------------------------------|
| Infrastructure Type    | Cloud, on-prem, hybrid                                     |
| Language               | HCL (HashiCorp Configuration Language)                     |
| Main File              | `main.tf`                                                  |
| Variable File          | `input.tf` or `variables.tf`                               |
| Output File            | `output.tf`                                                |
| State File             | `terraform.tfstate` (store in S3, lock with DynamoDB)      |
| Tool for Config Mgmt   | Use Ansible, not Terraform                                 |
| GitOps Compatibility   | Lacks native support                                       |

---

### 🙌 That's it! You're now equipped with a solid foundation to work with Terraform confidently.
