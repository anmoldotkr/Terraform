


################ Terraform state Management Question's: ###################
--------------------------------------------------------------------------------

| Command                            | Purpose                                              |
| ---------------------------------- | ---------------------------------------------------- |
| `terraform state list`             | Lists resources in state.                            |
| `terraform state show <resource>`  | View details of a resource.                          |
| `terraform state rm <resource>`    | Remove a resource from state (Terraform forgets it). |
| `terraform state mv <src> <dest>`  | Rename or move resources in state.                   |
| `terraform import <resource> <id>` | Bring existing infra into Terraform state.           |



**Explore the State:**
-> terraform state list
Output will show: = aws_s3_bucket.state_mt_s3


Then inspect the resource:
terraform state show aws_s3_bucket.state_mt_s3


Notice all attributes — tags, region, bucket ARN, etc.
These values are what Terraform will use next time you change something.

**Modify the Resource state**
example

resource "aws_s3_bucket" "state_mt_s3" {
  bucket = "terra-st-s3"

  tags = {
    Name        = "terra-st-s3"
    Environment = "dev"
  }
}
terraform plan
**Output**
~ tags = {
      + Environment = "dev"
    }
Terraform compared your config vs. state file — and realized it needs to update tags.

**manual deletion / drift in terraform**

 “What Happens When You Delete a Resource Manually”

**What you did:**

* Deleted the S3 bucket manually from the AWS Console.
* Then ran `terraform plan` or `terraform apply`.

**What happened:**

* Terraform refreshed its state and noticed the bucket no longer exists in AWS.
* It removed that bucket from its state automatically.
* The plan showed a **create action (`+`)**, not a destroy (`-`), because the bucket was already gone.
* On `apply`, Terraform recreated the bucket to match your configuration.

**What you learned:**

* Terraform **trusts its state file** but refreshes it before planning.
* Manual changes in AWS cause **drift**.
* When Terraform detects a missing resource, it simply **recreates** it.
* The `-` destroy action appears only when *you remove the resource from your Terraform code*, not when it disappears in AWS.

---

So in short:

> **If AWS changes manually → Terraform fixes it by recreating.
> If Terraform code changes → Terraform plans a destroy or update.**


------

### 🧩 Question

> I originally had a Terraform configuration that created one S3 bucket (`terra-st-s3`).
> Later, I deleted that resource block from my Terraform code and replaced it with a `for_each` loop to create two new buckets (`terra-st-s3-dev` and `terra-st-s3-prod`).
>
> When I ran `terraform plan`, Terraform showed that it would delete the old bucket and create the new ones.
>
> My question is:
> **Does Terraform decide to delete the old bucket and create the new ones based on the Terraform state file?**

---

### ✅ Ideal Answer

Yes — Terraform makes those decisions **based entirely on the Terraform state file**.

Here’s how it works step-by-step:

1. **Terraform state** is the source of truth that records which resources Terraform currently manages — including their IDs, attributes, and metadata.
2. When you run `terraform plan`, Terraform compares two things:

   * Your **current configuration files (.tf)** → what you *want* to exist
   * Your **state file (terraform.tfstate)** → what Terraform *believes* currently exists
3. In your case:

   * The old bucket (`terra-st-s3`) existed in the state file but was no longer defined in your configuration → Terraform planned to **destroy** it.
   * The two new buckets (`terra-st-s3-dev` and `terra-st-s3-prod`) were in your configuration but not in the state file → Terraform planned to **create** them.
4. After `terraform apply`, Terraform updated the state file — removing the old bucket’s entry and adding entries for the new ones.

So yes:

> **Terraform uses the state file to understand the current known infrastructure, detect differences between configuration and reality, and plan the necessary actions (create, update, or destroy) to make them match.**

---

**Re-Import Resource in state file**

