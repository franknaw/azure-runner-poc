### POC for provisioning a GitHub runner 

***

Run the following.
* terraform init
* terraform plan -var-file="poc.tfvars"

***

Supporting modules.
* [Azure-Simple-Network](https://github.com/franknaw/azure-simple-network)
* [azure-Private-Key](https://github.com/franknaw/azure-private-key)
* [Azure-Simple-Bastion](https://github.com/franknaw/azure-simple-bastion)
* [Azure-Simple-GitHub-Runner](https://github.com/franknaw/azure-simple-github-runner)