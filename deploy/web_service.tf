data "external" "web_service_availability" {
  program = ["/usr/bin/bash", "web_keepalive_provider.sh"]

  query = {
    url         = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
    filter      = "EVE"
    counter     = 200
    sleep       = 5
  }

  depends_on = [
      resource.rustack_vm.ubuntu16,
      resource.null_resource.dns_provisioner
  ]
}