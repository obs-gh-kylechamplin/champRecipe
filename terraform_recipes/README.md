# Terraform Recipes
Observe has a Terraform provider, that is fairly well documented here:

[https://docs.observeinc.com/en/latest/content/terraform/generated/index.html]



## terraform_rbac.tf
This contains a few examples of dealing with the [Observe RBAC system](https://docs.observeinc.com/en/latest/content/reference/rbac/rbacIntro.html). One of the thornier cases to deal with is applying RBAC statements to lists of users. So, there is a specific example of that. Note that this combines content in [gql_recipies](../gql_recipes/) to source the data as JSON from Observe, prune it with `jq`, and then write it to a file that will be read by Terraform.

Please run the script `observe_gql.sh` first, which will generate and copy the required json files into this directory (terraform_recipes) that are referenced in the terraform files.