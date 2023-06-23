# Provision infrastructure for Confluent Platform deployment on Azure

## Pre requisites
* Azure resource group
* Azure application registration
* Azure identity
* Azure network
* SSH key pair

## Steps
### Environment variables
````shell
export ARM_CLIENT_ID="*** application id ***"
export ARM_CLIENT_SECRET="*** password ***"
export ARM_SUBSCRIPTION_ID="$ACCOUNT_ID"
export ARM_TENANT_ID="*** tenant ***"
````
### Terraform init
Specify the backend to be used
```shell
terraform init -backend-config "resource_group_name=migrations" \
 -backend-config "storage_account_name=migrationstfstateazure" \
 -backend-config "container_name=tfstate" \
 -backend-config "key=terraform.tfstate"
```

### Terraform validate
```shell
terraform validate
```

### Terraform plan
```shell
terraform plan -out main.tfplan
```

### Terraform apply
```shell
terraform apply "main.tfplan"
```