####################################
# Title: Users
# Description: Create Entra ID users based on random names in users.csv.
####################################

# Configure the Azure Providers
provider "azuread" {}
provider "azurerm" {
  features {}
}

########## Initialize ##########
# Retrieve domain information
data "azuread_domains" "default" {
  only_initial = true
}

# Add random password generator.
# Note that in this current setup, all users will have a secure password - but the same password. This password will be stored in .tfstate.
resource "random_password" "password" {
  length           = 22
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file("${path.module}/users.csv"))
}

# Create random deployment name
resource "random_pet" "suffix" {
  length = 2
}

########## Entra User Creation ##########
resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user if user.type == "Member" }
  
  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    local.domain_name
  )

  # This should use random_password above, more secure than the demo which set a non-random password
  password = random_password.password.result
  force_password_change = true
  
  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
  street_address = random_pet.suffix.id
}