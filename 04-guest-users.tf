####################################
# Title: Guest Users
# Description: Uncomment to add Guest Users to your Terraform test environment, based on users with the "type" parameter set to "Guest" in your users.csv file.
# NOTE: Uncomment and update "user_email_address" to an external email you control to run this.
####################################

# Create guest users - deactivated by default
/*resource "azuread_invitation" "guests" {
  for_each = { for user in local.users : user.first_name => user if user.type == "Guest" }
  user_display_name  = "${each.value.first_name} ${each.value.last_name}"

# Update this value to invited email address
  user_email_address = "test@test.com" 
  redirect_url       = "https://portal.azure.com"

  message {
    body                  = format("[%s] Hello %s %s! You are invited to join my Azure tenant!",random_pet.suffix.id,each.value.first_name,each.value.last_name)
  }
}*/