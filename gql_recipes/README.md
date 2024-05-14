# GQL Recipes
This part of the repo contains a lot of hacked together examples, typically starting with cURL based approaches, and then some python as time permits. 

## observe_gql.sh

This shell script requires that you have both `cURL` and `jq` installed. This script also requires that you set the proper environment variables called out here [https://docs.observeinc.com/en/latest/content/terraform/generated/index.html](Observe Provider). These are the same environment variables required to successfully use Terraform.

# get all users
observe_user_list.json

# get all RBAC groups
observe_group_list.json

# get all dataset metadata
observe_dataset_list.json