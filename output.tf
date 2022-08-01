# output "id" {
#   value = module.linux_virtual_machine.virtual_machine_id
# }

# output "name" {
#   value = module.linux_virtual_machine.virtual_machine_name
# }

# output "vm_admin_login" {
#   value = module.linux_virtual_machine.admin_username
# }

# output "admin_ssh_key" {
#   value     = module.linux_virtual_machine.admin_ssh_key
#   sensitive = true
# }

# output "subscription" {
#   value = data.azurerm_subscription.current
# }

# output "vnet" {
#     value =  module.vnet
# }

# output "bastion" {
#     value = module.bastion
# }

output "bastion_ssh" {
  value = "ssh -i .terraform/modules/pem/bastion.pem ${var.username}@${module.bastion.public_ip}"
}

output "private_ssh" {
  value = "ssh -i .terraform/modules/pem/bastion.pem -o ProxyCommand='ssh -W %h:%p -i .terraform/modules/pem/runner.pem ${var.username}@${module.runner.private_ip}' ${var.username}@${module.bastion.public_ip}"
}

