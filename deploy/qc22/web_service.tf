
data "external" "web_service_availability" {
  program = ["/bin/bash", "${path.module}/web_keepalive_provider.sh"]

  query = {
    url         = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
    filter      = "200 OK"
    counter     = 200
    sleep       = 5
    prefix      = random_string.learn.result
  }

  depends_on = [
      resource.rustack_vm.ubuntu16,
      resource.null_resource.dns_provisioner
  ]

}

resource "null_resource" "web_service_kickstarter" {

    provisioner "local-exec" {
        command = "/bin/bash ${path.module}/web_service_kickstart.sh"

        environment = {
            endpoint        = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
            login           = "admin"
            old_password    = "eve"
            new_password    = random_string.eve_passwd.result
            lab             = "qc22.unl"
            prefix          = random_string.learn.result

        }
    }

    depends_on = [
      data.external.web_service_availability
  ]
}
