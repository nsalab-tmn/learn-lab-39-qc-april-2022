# resource "null_resource" "dns_provisioner" {

#   provisioner "local-exec" {
#     command = "/bin/bash dns_provisioner.sh"

#     environment = {
#       endpoint   = "${var.rustack_api_endpoint}"
#       bearer     = "${var.rustack_admin_token}"
#       zone       = "${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
#       project    = "${resource.rustack_project.project.id}"
#       ip_address = "${resource.rustack_vm.ubuntu16.floating_ip}"
#     }
#   }
#   provisioner "local-exec" {
#     command = "/bin/bash dns_deprovisioner.sh"
#     when    = destroy
#   }

#   depends_on = [
#     resource.rustack_vm.ubuntu16
#   ]

# }

resource "restapi_object" "dns_zone" {
  depends_on = [
    resource.rustack_vm.ubuntu16
  ]
  provider = restapi.restapi_admin
  path     = "/dns"
  data     = <<-EOT
  {
    "project": "${resource.rustack_project.project.id}",
    "name": "${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
  }
  EOT
}


resource "restapi_object" "dns_a" {
  depends_on = [
    resource.restapi_object.dns_zone
  ]
  provider = restapi.restapi_admin
  path     = "/dns/${restapi_object.dns_zone.api_data.id}/record"
  data     = <<-EOT
  {
    "type": "A",
    "host": "@",
    "ttl": 86400,
    "data": "${resource.rustack_vm.ubuntu16.floating_ip}"
  }
  EOT
}