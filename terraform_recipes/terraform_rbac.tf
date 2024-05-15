### Initial Setup
### Note that this can also be done
### via environment variables
### export OBSERVE_CUSTOMER=
### export OBSERVE_API_TOKEN=
### export OBSERVE_DOMAIN=
### but inline settings override envars

## provider "observe" {
##   customer  = ""
##   api_token = ""
##   domain = ""
## }



### Example of creating RBAC statements/permissions
### and assigning them to an existing group
## Fetch object info for a group called  "MINIMAL LISTER"

data "observe_rbac_group" "min_lister" {
    name = "MINIMAL LISTER"
}

## Object type permission example worksheet, view only
resource "observe_rbac_statement" "minimal_reader_worksheet" {
  subject { group = data.observe_rbac_group.min_lister.oid }
  object { 
    type = "worksheet"
  }
  role = "Viewer"
}


## Object type permission example dashboards, 
## This lets all users in this group create and edit 
## all worksheets in this customer
resource "observe_rbac_statement" "minimal_reader_dashboard" {
  subject { group = data.observe_rbac_group.min_lister.oid }
  object { 
    type = "dashboard"
  }
  role = "Editor"
}



### Example of adding users that are 
### stored in a file. We are copying 
### the files from the gql_recipes directory

## Pull in a list of user "objects" via a direct dump
## of the users GQL API - see observe_gql.sh
## These users objects will be used as locals

locals {
  user_data  = jsondecode(file("observe_user_list.json"))

}

## Attempt to look up users via TF
## by passing in each email from our 
## local "users" objects
## This requires looping

data "observe_user" "allUsers" {
  for_each = {
    for user in local.user_data : user.email => user
  }
  email = each.value.email

}

## With our new observe_user data object
## we can iterate through each user there
## and add them to this group

## add all users to our minimal lister group
resource "observe_rbac_group_member" "minimal_lister_members" {
  for_each = { for user in data.observe_user.allUsers : user.oid => user}
  member {
    user = each.value.oid
  }
  group = data.observe_rbac_group.min_lister.oid
  description = "Add all users to base Minimal Lister"
}



##  Example of creating a new group via TF
##  derived from this example: 
##  https://docs.observeinc.com/en/latest/content/workspaces/rbac-terra.html#create-an-engineering-group


# define a resource of type observe_rbac_group
# and give it the name "minimal reader"
resource "observe_rbac_group" "minimal_reader" {
 name = "MINIMAL READER"
 description = "CREATED VIA TERRAFORM"
}


## create an RBAC statement for allowing
## the "View" (aka read only acccess) role to 
## all dashboard objects
resource "observe_rbac_statement" "minimal_reader_permissions" {
  subject { group = observe_rbac_group.minimal_reader.oid }
  object { 
    type = "dashboard"
  }
  role = "Viewer"
}


## let's add a single user to that group
## by looking up the user by their email
data "observe_user" "example" {
  email = "kyle.champlin+creditlimittest@observeinc.com"
}


## take the user and group we looked up
## and then add that user 
resource "observe_rbac_group_member" "add_user_to_minimal_reader" {
  group = observe_rbac_group.minimal_reader.oid
  description = "Add user to minimal reader group"
  member {
    user = data.observe_user.example.oid
  }
}
