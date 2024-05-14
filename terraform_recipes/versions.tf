terraform {
  required_providers {
    observe = {
      source  = "terraform.observeinc.com/observeinc/observe"
      version = "~> 0.14.9"
    }
  }
  required_version = ">= 1.0"
}

## boilerplate setup for getting the default workspace value
## workspaces should be considered 1:1 with tenant/customer ID
data "observe_workspace" "default" {
  name = "Default"
}