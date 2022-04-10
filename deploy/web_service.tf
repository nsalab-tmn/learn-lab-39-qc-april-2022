data "external" "web_service_availability" {
  program = ["/bin/bash", "web_keepalive_provider.sh"]

  query = {
    url         = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
    filter      = "200 OK"
    counter     = 200
    sleep       = 5
  }

  depends_on = [
      resource.rustack_vm.ubuntu16,
      resource.null_resource.dns_provisioner
  ]
}

resource "null_resource" "web_service_kickstarter" {

    provisioner "local-exec" {
        command = "/bin/bash web_service_kickstart.sh"

        environment = {
            endpoint = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
            login = "admin"
            old_password = "eve"
            new_password = jsondecode(restapi_object.password.api_response).password
            lab = "nat-test.unl"

        }
    }

    depends_on = [
      data.external.web_service_availability
  ]
}