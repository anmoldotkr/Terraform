---

# 🧩 Terraform State Management — Full Summary (Beginner Friendly)

---

## 🧱 Basic Terraform State Commands

| Command                            | What it Does                                                                                               |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `terraform state list`             | Shows all resources Terraform is currently managing (from the state file).                                 |
| `terraform state show <resource>`  | Shows detailed info about that specific resource.                                                          |
| `terraform state rm <resource>`    | Removes that resource from Terraform’s control (Terraform “forgets” it, but resource still exists in AWS). |
| `terraform state mv <src> <dest>`  | Renames or moves a resource inside the state file.                                                         |
| `terraform import <resource> <id>` | Tells Terraform to track an existing resource that was created manually or lost from the state.            |

---

## 🔍 Explore the State

When you run:

```bash
terraform state list
```

You might see:

```
aws_s3_bucket.state_mt_s3
```

Then check the resource details:

```bash
terraform state show aws_s3_bucket.state_mt_s3
```

You’ll see all the values Terraform knows — like bucket name, region, tags, ARN, etc.
👉 These are the values Terraform uses to decide **what to create, change, or delete** next time you run `terraform plan`.

---

## ⚙️ Modify the Resource in Code

Suppose your config is:

```hcl
resource "aws_s3_bucket" "state_mt_s3" {
  bucket = "terra-st-s3"

  tags = {
    Name        = "terra-st-s3"
  }
}
```

Now you update it:

```hcl
tags = {
  Name        = "terra-st-s3"
  Environment = "dev"
}
```

Run:

```bash
terraform plan
```

Terraform will show something like:

```
~ tags = {
      + Environment = "dev"
    }
```

✅ This means:
Terraform compared your **code** (desired state) with your **state file** (current known state)
→ and found that the tag is missing → so it plans to **add** it.

---

## 🧨 Manual Deletion (Drift)

### What happens if you delete something manually?

Example:

* You delete the S3 bucket manually from the AWS Console.
* Then you run `terraform plan`.

Terraform will:

1. Refresh its state from AWS.
2. See that the bucket is **gone**.
3. Plan to **create** it again (because it still exists in your `.tf` code).

💡 Important:

* Terraform **does not delete from the state immediately** when you remove something in AWS.
* It detects that it’s missing and **recreates** it to match your code.

But if you **remove the resource from your Terraform code**, then Terraform will plan to **destroy** it (because now it exists only in state, not in config).

---

### 🧠 So in short:

> * If **AWS changes manually →** Terraform fixes it (recreates).
> * If **Terraform code changes →** Terraform updates or deletes based on code.

---

## 🧩 Step 6 — Re-Import Resource (Easy Explanation)

Now imagine this situation 👇

You had a bucket managed by Terraform earlier:

```hcl
resource "aws_s3_bucket" "state_mt_s3" {
  bucket = "terra-st-s3"
}
```

Later, you removed it from the code, or ran:

```bash
terraform state rm aws_s3_bucket.state_mt_s3
```

Now Terraform **forgets** it — but the bucket **still exists in AWS**.

---

### 🔹 Problem:

Terraform doesn’t know about it anymore (it’s not in state file).

### 🔹 Solution:

Use `terraform import` to **tell Terraform to remember it again**.

Example:

```bash
terraform import 'aws_s3_bucket.state_mt_s3["dev"]' terra-st-s3-dev
```

---

### 🔹 Important Notes:

1. The resource block **must exist** in your `.tf` file — Terraform imports into that configuration.
2. `terraform import` **only updates the state file** — it doesn’t change or recreate anything in AWS.
3. After import, always run:

   ```bash
   terraform plan
   ```

   to make sure your code and real AWS setup match.
4. If plan shows differences (like tags missing), then run:

   ```bash
   terraform apply
   ```

   to sync them.

---

### 🧠 Real-Life Example:

Let’s say you manually created an S3 bucket in AWS.
You want Terraform to manage it now.

Steps:

1. Write the bucket resource block in `.tf` file.
2. Run:

   ```bash
   terraform import aws_s3_bucket.my_bucket my-existing-bucket-name
   ```
3. Terraform now knows about that bucket and adds it to the **state file**.

---

### ✅ Why Import is Useful:

* When you **manually created** something before Terraform.
* When you **lost state accidentally** and want to reconnect it.
* When you **moved state** between projects and need to re-sync.

---

### 🧠 Simple Way to Remember

| Action               | What Happens                                            |
| -------------------- | ------------------------------------------------------- |
| `terraform state rm` | Terraform forgets about the resource, but AWS keeps it. |
| `terraform import`   | Terraform remembers it again (adds to state).           |

💬 In short:

> “`state rm` makes Terraform forget.
> `import` makes Terraform remember again.”

---

Perfect 👍
Let’s continue your **Terraform State Management Notes** — in the same clear, beginner-friendly format.

---

# 🧩 Step 7 — Remote State with S3 + DynamoDB

---

## 🧠 What is Remote State?

When you run Terraform, it saves all the info about your infrastructure (resources, IDs, dependencies, etc.) in a file called **`terraform.tfstate`**.

By default, this file is stored **locally** on your computer.
That’s fine for personal use — but not for teams.

If multiple people run Terraform on their own machines, their local state files can **get out of sync**, and that’s dangerous (one person’s apply can break another’s setup).

---

## 💡 The Solution — Remote State Backend

You can store your Terraform state **remotely** so that everyone shares one single source of truth.

For AWS users, the most common setup is:

* **S3 bucket** → stores the state file
* **DynamoDB table** → manages state locking (prevents two people from running Terraform at the same time)

---

### 🧱 Example: Create S3 and DynamoDB for State Management

```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"

  versioning {
    enabled = true
  }

  tags = {
    Name = "terraform-state-bucket"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-lock-table"
  }
}
```

---

### 🧰 Configure Your Backend

Now, tell Terraform to **use that S3 bucket and DynamoDB** to store and lock the state.

Create a new file `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

---

### ⚙️ Initialize Backend

Run:

```bash
terraform init
```

Terraform will:

* Move your local `terraform.tfstate` to the S3 bucket.
* Create a lock system in DynamoDB when running apply.
* After this, everyone who runs Terraform shares this same remote state.

---

### ✅ Why This is Important

| Benefit      | Explanation                                             |
| ------------ | ------------------------------------------------------- |
| Shared State | All users use the same state file from S3.              |
| Safety       | DynamoDB prevents two applies from happening at once.   |
| Recovery     | S3 versioning lets you roll back if state is corrupted. |
| Security     | You can enable encryption (SSE).                        |

---

### 🧠 Simple Analogy

> * S3 = **Shared hard drive** for the Terraform state.
> * DynamoDB = **Lock** on the door to make sure only one person edits at a time.

---

### 💬 In short:

> “S3 stores your Terraform memory.
> DynamoDB keeps it safe from being edited by two people at once.”

---

# 🧩 Step 8 — Terraform State Best Practices

---

## ✅ 1. Always Backup Your State

* Use **S3 versioning** or copy your local state file to a safe place before making big changes.
* Losing the state file = Terraform forgets what it created.

---

## ✅ 2. Never Edit State File Manually

* It’s JSON, but never open and edit it by hand.
* If you need changes, use:

  ```bash
  terraform state mv
  terraform state rm
  terraform import
  ```

  These are **safe** ways to modify the state.

---

## ✅ 3. Lock Your State

* Use **DynamoDB lock** or Terraform Cloud to prevent corruption.

---

## ✅ 4. Keep Code and State in Sync

* Never make manual changes in AWS without updating Terraform.
* Run `terraform plan` regularly to detect **drift** (differences between AWS and state).

---

## ✅ 5. Use Workspaces for Environments

* Use Terraform workspaces (`terraform workspace new dev`, `terraform workspace select prod`)
  to manage **dev/staging/prod** with separate state files.

---

## ✅ 6. Don’t Commit State Files to Git

* Add `terraform.tfstate` and `.terraform/` folders to your `.gitignore`.

---

## ✅ 7. Use `terraform refresh` (optional)

* Use this command to sync the state file with actual resources if you suspect drift.
  (It doesn’t apply changes, only updates the state.)

---

### 🧠 Final Summary

| Step | Concept               | What You Learned                                   |
| ---- | --------------------- | -------------------------------------------------- |
| 1–3  | Basic Commands        | List, show, modify, and inspect state.             |
| 4–5  | Drift & State Updates | Terraform compares code vs. state vs. AWS.         |
| 6    | Import                | Bring existing AWS resources into Terraform.       |
| 7    | Remote State          | Store shared state in S3 + use DynamoDB for locks. |
| 8    | Best Practices        | Keep state safe, synced, and versioned.            |

---

✅ **One-Liner Recap**

> Terraform State = Terraform’s memory of what it manages.
>
> Lose it — Terraform forgets your infra.
>
> Protect it with S3 + DynamoDB.
>
> Fix it using import and state commands.

---

