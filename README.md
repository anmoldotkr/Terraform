
# 🌍 Terraform

## 🔹 What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool created by **HashiCorp**.
It allows you to define, provision, and manage infrastructure in a declarative way.

* Configuration files can be written in:

  * **HCL (HashiCorp Configuration Language)** → commonly used (`.tf` files)
  * **JSON**

---

## 🔹 What is HashiCorp?

HashiCorp is a software company that builds tools for cloud infrastructure management, such as:

* Terraform (IaC)
* Vault (secrets management)
* Consul (service networking)
* Nomad (workload orchestration)

---

## 🔹 What is HCL?

HCL (**HashiCorp Configuration Language**) is a domain-specific language used to write Terraform configuration files.

* File extension: **`.tf`**
* Designed to be **human-readable & machine-friendly**

---

## 🔹 Why Terraform?

### 🚫 Without Terraform (Manual Setup)

* You log in to AWS Console
* Create resources manually (EC2, RDS, S3, IAM, Security Groups)
* Repeat for staging, production, etc.
* Any change requires repeating steps → **error-prone & time-consuming**

### ✅ With Terraform (Automated Setup)

* Define resources in code
* Reuse across environments (Dev, Stage, Prod)
* Version control infra configs
* Run once → deploy automatically

---

## 🔹 Terraform Syntax

### General Syntax

```hcl
block_type "resource_type" "resource_name" {
  argument1 = value
  argument2 = value
}
```

* **Block** → Top-level structure (e.g., `resource`, `provider`, `variable`)
* **Arguments** → Define values inside a block (e.g., `bucket`, `filename`)
* **Attributes** → Values available **after** resource creation (e.g., ARN of an S3 bucket)

---

## 🔹 Example 1: Create Local File

```hcl
resource "local_file" "my_file" {
  filename = "automate.txt"
  content  = "This text file is created by terraform"
}
```

### Notes:

* **resource** → block type
* **local\_file** → resource type (from **local provider**)
* **my\_file** → resource name (must be unique within the module)
* `filename` & `content` → arguments

---

## 🔹 Terraform Commands

1. `terraform init` → Initialize provider plugins
2. `terraform validate` → Check syntax
3. `terraform plan` → Preview changes
4. `terraform apply` → Apply changes (creates resources)
5. `terraform destroy` → Delete resources

---

## 🔹 Example 2: Create AWS S3 Bucket

### Prerequisites:

* AWS CLI installed & configured
* AWS provider set up in Terraform

### `provider.tf` (to define cloud provider)

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### `s3.tf` (to create bucket)

```hcl
resource "aws_s3_bucket" "mybkt" {
  bucket = "my-terraform-bucket"
}
```

---

## 🔹 Why `provider.tf`?

* Defines which provider Terraform should use (AWS, GCP, Azure, etc.)
* Without it, Terraform won’t know where to create resources

---

## 🔹 File Organization

* Not mandatory, but best practice:

  * `provider.tf` → provider config
  * `variables.tf` → input variables
  * `main.tf` → resources
  * `terraform.tfvars` → variable values
  * `outputs.tf` → outputs

---

## 🔹 String Interpolation

Used to insert **dynamic values** into strings:

```hcl
resource "aws_s3_bucket" "mybkt" {
  bucket = "my-terraform-${var.environment}-bucket"
}
```

If `var.environment = "dev"` → bucket = `my-terraform-dev-bucket`

---

## 🔹 Variables

Make code reusable and dynamic.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

Usage: `${var.environment}`

---

## 🔹 Count

Used to create multiple resources dynamically.

```hcl
resource "aws_instance" "servers" {
  count = 3
  ami   = "ami-123456"
  type  = "t2.micro"
}
```

* Creates **3 EC2 instances**
* `count.index` → current index (starts at 0)

---

## 🔹 element() Function

Selects an item from a list by index.

```hcl
variable "cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "aws_subnet" "example" {
  count      = 2
  cidr_block = element(var.cidr_blocks, count.index)
}
```

* Subnet 0 → `10.0.1.0/24`
* Subnet 1 → `10.0.2.0/24`

---

# 🎯 Quick Recap

* **Terraform** = IaC tool by HashiCorp
* **HCL** = Language to write `.tf` files
* **Blocks** = Building units (`resource`, `provider`, `variable`)
* **Arguments** = Defined before execution
* **Attributes** = Computed after execution
* **Commands** = init → validate → plan → apply → destroy
* **Best Practice** = Organize files (`provider.tf`, `main.tf`, etc.)


# Loops in Terraform
1. count (simplest Loop)
- creates multiple copies of the same resource.
- Use count.index (starts at 0).

Example create 3 EC2:
resource "aws_instance" "server"{
  count = 3
  ami  = "ami-12345"
  instance_type  = "t2.micro"
  tags = {
    Name = "server-${count.index}"
  }
}

output: server-0,server-1,server-2

2. for_each (loop over maps or sets)
- Better than count when you want to work with named items instead of indexes.

variable "bucket_name" {
  default = ["dev-bucket", "stage-bucket", "prod-bucket"]
}

resource "aws_s3_bucket" "ex" {
  for_each = toset(var.bucketname)
  bucket = each.value
}
**Meta-arguments** are special arguments you can use with resources, modules, and other Terraform blocks. They don’t directly configure a resource itself, but instead control **how Terraform manages that resource**.

Some common **meta-arguments** in Terraform:

1. **`count`**

   * Lets you create multiple instances of the same resource.

   ```hcl
   resource "aws_instance" "example" {
     count = 3
     ami           = "ami-123456"
     instance_type = "t2.micro"
   }
   ```

   → Creates 3 EC2 instances.

---

2. **`for_each`**

   * Similar to `count`, but works with maps or sets of strings.

   ```hcl
   resource "aws_s3_bucket" "example" {
     for_each = toset(["logs", "data", "images"])
     bucket   = "${each.key}-bucket"
   }
   ```

   → Creates 3 buckets with names `logs-bucket`, `data-bucket`, `images-bucket`.

---

3. **`provider`**

   * Lets you choose which provider configuration to use.

   ```hcl
   resource "aws_instance" "example" {
     provider      = aws.us_east
     ami           = "ami-123456"
     instance_type = "t2.micro"
   }
   ```

---

4. **`depends_on`**

   * Explicitly sets dependencies between resources.

   ```hcl
   resource "aws_instance" "example" {
     ami           = "ami-123456"
     instance_type = "t2.micro"
     depends_on    = [aws_s3_bucket.example]
   }
   ```

---

5. **`lifecycle`**

   * Controls how Terraform handles resource updates/deletions.

   ```hcl
   resource "aws_instance" "example" {
     ami           = "ami-123456"
     instance_type = "t2.micro"

     lifecycle {
       prevent_destroy = true
       ignore_changes  = [tags]
     }
   }
   ```

---

✅ In short: **Meta-arguments are special arguments that modify Terraform’s behavior when creating, updating, or destroying resources.**

# 🌍 Terraform State & State Management

---

## 🧭 Overview

Terraform **state** is the *backbone* of Terraform’s infrastructure management.  
It keeps track of the real-world resources Terraform manages and ensures consistent planning, creation, and updates.

---

## 🧠 What is Terraform State?

Terraform stores the details of all created resources in a **state file**, usually named:

terraform.tfstate
This file acts as the **source of truth** for Terraform.

### Terraform uses it to:

- Record resources created, their IDs, ARNs, attributes, etc.
- Compare what exists (state) with what’s defined in `.tf` files.
- Decide what to **create**, **update**, or **destroy**.

---

## 🪣 Local State (Default Behavior)

When you run:

```bash
terraform init
terraform apply

Terraform automatically creates a local state file:
```bash
terraform.tfstate

