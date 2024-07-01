# This recipe is for creating a new RBAC group
# setting a minimal policy for that group
# and then setting that group as the "workspace rbac default group"
# When this is done, any user that attempts to log in 
# via SAML, if the SAML assertion contains groups that 
# do not match any named groups in Observe
# they will be assigned to this new "rbac default group"
# functionally, this means they will not be able to log in
# and will recieve a "Unable to load the workspace" error.
  
resource "observe_rbac_group" "no_access" {
    name = "NO ACCESS GROUP"
    description = "DEFAULT GROUP"
}

# Attach a minimal policy that elides 
# access to anything and MUST NEVER have fallback perms
resource "observe_rbac_statement" "no_access_bookmark" {
  subject { group = resource.observe_rbac_group.no_access.oid }
  object { 
    type = "bookmark"
  }
  role = "Lister"
}

resource "observe_rbac_default_group" "default_no_access" {
  group = resource.observe_rbac_group.no_access.oid
}
