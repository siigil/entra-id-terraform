####################################
# Title: Permissions
# Description: Assign a variety of permissions to users, based on the "entra" and "rbac" entries for each user in users.csv. Role names must exist as built-in roles.
# NOTE: Group role assignments are handled in 03-groups.tf
####################################

########## Entra Role Assignment ##########
# Create subset of users with an assigned entra role
locals {
  entra_role_users = { for user in local.users : user.first_name => user if user.entra != "None" }
  rbac_role_users = { for user in local.users : user.first_name => user if user.rbac != "None" }
}

# Initialize role templates for needed roles in entra, & fetch object IDs for all
resource "azuread_directory_role" "setup" {
  for_each = { for role in local.entra_role_users : role.entra => role }
  display_name = each.key
}

# Create role assignments for each user that had an entra set
resource "azuread_directory_role_assignment" "assignments" {
  
  # Create a key-value map of user shortname for all users with an Entra role set
  for_each = { for user in local.entra_role_users : user.first_name => user }
  
  # Fetch role id to assign & assign it to the ad user
  # There's a lot happening here. The part in [] is getting the role friendlyname for each user; the outer part is getting the id for that role.
  role_id = azuread_directory_role.setup[local.entra_role_users[each.key].entra].id
  
  # Fetch each user id from AAD user data based on user firstname from entra_role_users (based on for_each mapping)
  principal_object_id = azuread_user.users[each.key].id
}
########## RBAC Role Assignment ##########

# Fetch subscriptions
data "azurerm_subscriptions" "available" {
}

# Assign RBAC roles to users
resource "azurerm_role_assignment" "assignments" {
  # For now, assign RBAC assignment scope to the first available subscription
  scope                = data.azurerm_subscriptions.available.subscriptions[0].id
  
  # Create a key-value map of user shortname for all users with an RBAC role set
  for_each = { for user in local.rbac_role_users : user.first_name => user }
  
  # Set builtin role name to be assigned
  role_definition_name = each.value.rbac
  
  # Fetch each user id from AAD user data based on user firstname from rbac_role_users (based on for_each mapping)
  principal_id = azuread_user.users[each.key].id
}