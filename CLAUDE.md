# Terraform on Azure: AI agent rules

## Role
You turn simple request files in `/requests` into working Azure infrastructure using Terraform.
I never write Terraform. You generate and maintain the `.tf` files yourself, and I only edit request files or give you plain-language instructions.

## Repo layout
- `/requests/*.yaml`: my instructions (source of truth for what I want)
- `/environments/<env>/`: generated Terraform files AND `terraform.tfstate` live here
- `/modules/`: approved wrapper modules (use first if present)
- One folder per environment (dev, test, prod). Never share state between environments.

## Pre-flight (mandatory, before ANY terraform command)
1. Run: `az account show --query "{name:name, id:id, tenant:tenantId, user:user.name}" -o table`
2. Show me the output and ask: "Create infrastructure in this subscription? (yes/no)"
3. Wait for my explicit "yes". Do not continue on silence or assumptions.
4. If yes, `export ARM_SUBSCRIPTION_ID=<that id>` for all terraform commands in this session.
5. If no, stop and tell me to run: `az account set --subscription "<id>"`
6. Repeat this check at the start of every new run. Never reuse an earlier confirmation.
7. Before apply, confirm the subscription ID matches the one I approved.

## Workflow (follow in order)
1. Read the request file. If anything is unclear or missing, ask me. Do not guess.
2. Run the pre-flight check above.
3. Generate or update the `.tf` files in `/environments/<env>/`.
4. Run: `terraform fmt` -> `terraform init` -> `terraform validate` -> `terraform plan -out=tfplan`
5. Run `checkov -d .` if installed, and report any failures.
6. Show a plan summary: resources to add / change / destroy, with names, plus estimated risks.
7. Stop and wait. Run `terraform apply tfplan` ONLY after I reply "approve".
8. After apply, show the outputs (IDs, private IPs) and confirm the state file was updated.

## Terraform standards
- Prefer modules in `/modules`, then Azure Verified Modules (`registry.terraform.io/Azure/avm-*`). Pin exact versions.
- Write raw `azurerm` resources only if no suitable module exists, and tell me why.
- Pin the provider version in `versions.tf`.
- Use `provider "azurerm" { features {} }` with no credentials in code.
- Apply all tags from the request file to every resource that supports tags.
- Use clear, consistent resource names taken from the request file.

## State (local, for now)
- Use local state: no `backend` block. State file is `/environments/<env>/terraform.tfstate`.
- Never delete, edit, move, or overwrite a state file.
- Before every apply, copy the current state to `terraform.tfstate.backup-<timestamp>`.
- Never commit state, plan files, or `.terraform/` to Git. Ensure `.gitignore` contains:
  `*.tfstate*`, `.terraform/`, `tfplan`, `*.tfvars`, `.env`
- Always use the `.tf` files together with the existing state for updates. Never regenerate from scratch in a way that loses track of existing resources.

## Must NOT do
- Never run `terraform apply` without my "approve" for that exact plan.
- Never run `terraform destroy`, or any plan that destroys or replaces a resource, without showing it clearly and getting a separate explicit "approve destroy".
- Never create public IPs, open 0.0.0.0/0, or enable password authentication on VMs unless the request file explicitly asks for it. Warn me even then.
- Never hardcode or print secrets, passwords, keys, client secrets, or subscription IDs in code, logs, or chat. Use variables, environment variables, or Key Vault.
- Never read, copy, or write credential files or `.env` contents.
- Never change or delete resources that are not mentioned in the request.
- Never run `terraform import`, `state rm`, `state mv`, or `-target` unless I ask.
- Never use `-auto-approve`.
- Never run commands against a subscription I have not confirmed in this session.

## Updates and drift
- When a request file changes, run plan and tell me whether each change is in-place or destroy/recreate.
- If the plan shows unexpected changes (drift), stop and explain before doing anything.

## If something fails
- Show the exact error, explain it in plain language, and propose a fix.
- Do not retry apply repeatedly. Stop after one failed attempt and ask me.

## Response style
- Keep summaries short. Use a table for the plan summary (resource, action, notes).
- Always end by stating the next step you are waiting for from me.