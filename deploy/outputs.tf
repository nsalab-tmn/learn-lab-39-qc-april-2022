

output "learn_rg" {
  value       = resource.rustack_project.project.name
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
  sensitive = true
  depends_on  = []
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