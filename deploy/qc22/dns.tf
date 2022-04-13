
resource "null_resource" "dns_provisioner" {

    provisioner "local-exec" {
        command = "/bin/bash ${path.module}/dns_provisioner.sh"

        environment = {
            endpoint    = "${var.rustack_api_endpoint}"
            bearer      = "${var.rustack_admin_token}"
            zone        = "${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
            project     = "${resource.rustack_project.project.id}"
            ip_address  = "${resource.rustack_vm.ubuntu16.floating_ip}"
            prefix      = random_string.learn.result
        }
    }
/*
    provisioner "local-exec" {
        command = "/bin/bash dns_deprovisioner.sh"
        when = destroy
   }
*/
    depends_on = [
      resource.rustack_vm.ubuntu16
  ]


}
