# Entra ID Terraform Examples

## Purpose
This repository is a simple collection of simple Terraform examples working with the `azuread` resource provider to create configurations in a demo Entra ID environment, based off values in the file `users.csv`. The file is configured by default with a handful of random user names and roles, but can be updated to create your own environment configuration.

The goal of presenting content in this way is to make it easy for someone to quickly set up a simple Entra ID test environment, debug issues, and adapt to their own needs without too much effort. Other projects may be a better fit if you'd like a more complex environment!

Think of this as a "toy" repo on using Terraform with Entra ID.

## Structure
The following Entra ID configurations are created based on `users.csv`:
- `01-users.tf`: Users
- `02-permissions.tf`: Entra ID & Azure RBAC role assignments
- `03-groups.tf`: Groups & Dynamic Groups
- `04-guest-users.tf`: Guest Users
- `05-administrative-units.tf`: Administrative Units (restricted management & hidden membership)

This structure of multiple, numbered files is to make it simpler for someone new to Terraform and the `azuread` provider to understand how the pieces of a configuration work to create different settings and objects.

Each file has comments I made while working with these configurations, and notes on requirements for implementation.

## Usage
1. Enable Entra ID P1 licensing, or comment out features requiring it in `03-groups.tf`.
2. Ensure you are logged in as a Global Administrator by executing `az login --allow-no-subscriptions` from a terminal session.
3. From this folder, execute `terraform init` + `terraform apply`. Type "yes" to apply.
4. Explore your environment in the Azure Portal (https://portal.azure.com/), or modify `users.csv` and repeat Step 3 to see how you can modify the environment by changing this sheet.
5. When you are done, execute `terraform destroy`.

## Further Resources
- Introduction to Azure in Terraform: https://developer.hashicorp.com/terraform/tutorials/azure-get-started
- Terraform's `azuread` provider documentation: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
- Create more complex environments with security misconfigurations: https://github.com/mvelazc0/BadZure