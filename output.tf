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
  value = "ssh -i bastion.pem adminuser@${module.bastion.bastion_public_ip}"
}

# output "private_ssh" {
#   value = "ssh -i runner.pem -o ProxyCommand='ssh -W %h:%p -i bastion.pem adminuser@${module.bastion.bastion_public_ip}' adminuser@${module.runner.private_ip}"
# }

output "private_ssh" {
  value = "ssh -i bastion.pem -o ProxyCommand='ssh -W %h:%p -i runner.pem adminuser@${module.runner.private_ip}' adminuser@${module.bastion.bastion_public_ip}"
}

# output "ssh_keys" {
#     description = "Map of ssh keys defined by var.hosts."
#     value = module.pem.ssh_keys
# }