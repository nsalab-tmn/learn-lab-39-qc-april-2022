

output "learn_rg" {
  value       = "https://${random_string.learn.result}.${var.lab_instance}.${var.dns_root}"
  description = "Main resource group"
  depends_on  = []
}

output "learn_user" {
  value       = data.external.user.result.login
  description = "Main User"
  depends_on  = []
}

output "learn_password" {
  value       = data.external.user.result.password
  description = "Main Password"
  sensitive = false
  depends_on  = []
}

output "web_service" {
  value       = data.external.web_service_availability.result
  depends_on  = [
    data.external.web_service_availability
  ]
}

/*



output "dynamic-params" {
  value = {
    "${var.lab_instance}-${var.prefix}"= {
      "project_id" = resource.rustack_project.project.id
      "project_name" = resource.rustack_project.project.name

    }
  }
}




*/