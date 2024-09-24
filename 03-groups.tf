####################################
# Title: Groups
# Description: Assign users to groups, based on the "department" and "job_title" entries for each user in users.csv.
# NOTE: Group role assignments and Dynamic Groups require P1 licensing.
####################################

########## Entra Group Creation ##########
# Create groups
resource "azuread_group" "it" {
  display_name = "IT"
  security_enabled = true
  # Assignable to Entra ID roles requires P1 licensing.
  assignable_to_role = true
}

resource "azuread_group" "engineers" {
  display_name = "Engineers"
  security_enabled = true
  # Assignable to Entra ID roles requires P1 licensing.
  assignable_to_role = true
}

resource "azuread_group" "distribution" {
  display_name = "Distribution"
  security_enabled = true
  # Assignable to Entra ID roles requires P1 licensing.
  assignable_to_role = true
}

# Dynamic Group requires P1 licensing
resource "azuread_group" "managers" {
  display_name = "Managers"
  security_enabled = true
  types            = ["DynamicMembership"]
  dynamic_membership {
    enabled = true
    # Need to reference jobTitle instead of job_title as this is the parameter name for the filter
    rule    = "user.jobTitle -eq \"Manager\""
  }
}

# Assign group members
resource "azuread_group_member" "it" {
  for_each = { for u in local.users: u.first_name => u if u.department == "IT" }
  group_object_id  = azuread_group.it.id
  member_object_id = azuread_user.users[each.key].id
  depends_on = [azuread_user.users]
}

resource "azuread_group_member" "engineers" {
  for_each = { for u in local.users: u.first_name => u if u.job_title == "Engineer" }
  group_object_id  = azuread_group.engineers.id
  member_object_id = azuread_user.users[each.key].id
  depends_on = [azuread_user.users]
}

resource "azuread_group_member" "distribution" {
  for_each = { for u in local.users: u.first_name => u if u.department == "Distribution" }
  group_object_id  = azuread_group.distribution.id
  member_object_id = azuread_user.users[each.key].id
  depends_on = [azuread_user.users]
}

########## Entra Group Role Assignment ##########
# Requires P1 licensing
# Initialize role templates for needed roles in entra
resource "azuread_directory_role" "group_setup" {
  display_name = "Global Reader"
}

# Create role assignments for each user that had an entra set
resource "azuread_directory_role_assignment" "group_assignments" {

  # Fetch role id to assign & assign it
  role_id = azuread_directory_role.group_setup.object_id

  # Fetch each user id from AAD user data based on user firstname from role_users (based on for_each mapping)
  principal_object_id = azuread_group.distribution.id
}