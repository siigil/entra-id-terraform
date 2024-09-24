####################################
# Title: Administrative Units
# Description: Examples of configuring "hidden membership" and "restricted management" AUs in Terraform, and adding users to them based on department names. Change "u.department" below to modify who is added if you have different department names.
# NOTE: Administrative Unit scoped role assignments require P1 licensing. No lines below reference scoped role assignments, however, so you shouldn't need to comment anything out here.
####################################

########## Entra Hidden AU Creation ##########
resource "azuread_administrative_unit" "hidden" {
  display_name              = "TF Hidden AU"
  description               = "Terraform hidden membership AU"
  hidden_membership_enabled = true
}

resource "azuread_administrative_unit_member" "hidden" {
  for_each = { for u in local.users: u.first_name => u if u.department == "Executive" }
  administrative_unit_object_id = azuread_administrative_unit.hidden.id
  member_object_id              = azuread_user.users[each.key].id
  depends_on = [azuread_user.users]
}

########## Entra Restricted AU Creation ##########
# As restricted management AUs are not yet supported in TF, we need to take some manual steps here
# But this is simpler than working out built-in support, as most of Azure AD Terraform's actions are made through Hamilton, the SDK Terraform uses

# 1. Use az CLI to fetch a token for the web request. Terraform already relies on az CLI so it should be ok to assume this is present. 
# --query, --output are key for data.external's expected formatting.
data "external" "bearer_token" {
    program = ["az", "account", "get-access-token", "--resource-type", "ms-graph", "--query","{accesstoken:accessToken}", "--output", "json"]
}

# 2. Make a manual HTTP request to the Graph API /beta/ endpoint to create an Administrative Unit, with the token we just fetched.
data "http" "administrative_unit_restricted" {
  # Restricted AUs are only on the /beta/ endpoint right now, they're in Preview
  url            = "https://graph.microsoft.com/beta/administrativeUnits"
  method         = "POST"
  request_headers = {
    Content-Type = "application/json"
    ConsistencyLevel= "eventual"
    # Using the token we just fetched
    Authorization = "Bearer ${data.external.bearer_token.result["accesstoken"]}"
  }
  # Parameters of the requested AU
  request_body = jsonencode({  
        "displayName": "TF Restricted AU",  
        "description": "Terraform restricted management AU",  
        # This is the restricted management parameter
        "isMemberManagementRestricted": true 
    } 
  )
 }  

# 3. Assign members with Terraform methods as we now have an AU ID to work with.
resource "azuread_administrative_unit_member" "restricted" {
  for_each = { for u in local.users: u.first_name => u if u.department == "Sourcing" }
  # Fetch the AU object ID from the Graph HTTP response, in place of from an AU object
  administrative_unit_object_id = jsondecode(data.http.administrative_unit_restricted.response_body).id
  member_object_id              = azuread_user.users[each.key].id
  depends_on = [azuread_user.users]
}