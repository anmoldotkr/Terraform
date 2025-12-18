

````md
## Terraform Workspaces

**Documentation Reference:**  
https://www.env0.com/blog/terraform-workspaces-guide-examples-commands-and-best-practices

### Overview

Terraform workspaces allow you to create **multiple isolated environments** (such as `dev`, `stage`, and `prod`) using the **same Terraform configuration**.  
Each workspace maintains its **own separate state file**, enabling environment isolation without duplicating Terraform code.

This approach reduces operational overhead and keeps infrastructure definitions consistent across environments.

---

### In a Nutshell

- A workspace represents a **separate instance of your infrastructure**
- All workspaces share the **same Terraform configuration**
- Each workspace has its **own independent state**
- Ideal for managing multiple environments with minimal duplication

---

### Terraform Workspace Commands

#### Available Subcommands

```bash
terraform workspace list      # List all workspaces
terraform workspace new       # Create a new workspace
terraform workspace select    # Switch to a workspace
terraform workspace show      # Show current workspace
terraform workspace delete    # Delete a workspace
````

---

### Common Workspace Operations

#### 1. Create a new workspace

```bash
terraform workspace new <name>
```

Example:

```bash
terraform workspace new dev
terraform workspace new stage
```

---

#### 2. List all workspaces

```bash
terraform workspace list
```

---

#### 3. Select an existing workspace

```bash
terraform workspace select <name>
```

Example:

```bash
terraform workspace select dev
```

---

#### 4. Show the current workspace

```bash
terraform workspace show
```

---

#### 5. Delete a workspace

```bash
terraform workspace delete <name>
```

Example:

```bash
terraform workspace delete dev
```

---

### When to Use Terraform Workspaces

* Managing **multiple environments** (dev, stage, prod)
* **Isolating Terraform state** per environment
* Reducing **code duplication**
* Quickly switching between environments using the same infrastructure definitions

---
