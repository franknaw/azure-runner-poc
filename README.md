### POC for provisioning a Self Hosted GitHub runner 

***

The GitHub runner POC is desinged to configure a runner at the organizational level and needs a fresh runner token added to the "poc.tfvars" file.
* Instruction to generate a runner token - https://docs.github.com/en/rest/actions/self-hosted-runners

***

Run the following.
* terraform init
* terraform plan -var-file="poc.tfvars"
* add the runner token to "poc.tfvars"
* terraform apply -var-file="poc.tfvars"


***

Supporting modules.
* [Azure-Simple-Network](https://github.com/franknaw/azure-simple-network)
* [Azure-Private-Key](https://github.com/franknaw/azure-private-key)
* [Azure-Simple-Bastion](https://github.com/franknaw/azure-simple-bastion)
* [Azure-Simple-GitHub-Runner](https://github.com/franknaw/azure-simple-github-runner)