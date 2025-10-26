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

Would you like me to now add **Step 7 (Remote State with S3 + DynamoDB)** in the same simple style — like a continuation of these notes?
