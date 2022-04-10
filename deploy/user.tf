# resource "null_resource" "user_provisioner" {

#     provisioner "local-exec" {
#         command = "/bin/bash user_provisioner.sh"

#         environment = {
#             endpoint = "${var.rustack_api_endpoint}"
#             bearer = "${var.rustack_root_token}"
#             username = "${var.prefix}-${random_string.learn.result}"
#             login = "${var.prefix}-${random_string.learn.result}"
#             domain = "${var.rustack_domain}"
#             email = "junk@nsalab.org"
#             entity = "${var.rustack_entity}"
#             type = "client"
#             role = "client_user"
#             project = "${resource.rustack_project.project.id}"
#         }
#     }

#     provisioner "local-exec" {
#         command = "/bin/bash user_deprovisioner.sh"
#         when = destroy
#    }

#     depends_on = [
#       resource.rustack_project.project
#   ]
# }

# data "external" "user" {
#   program = ["/bin/bash", "user_data_provider.sh"]

#   query = {
#     endpoint = "${var.rustack_api_endpoint}"
#     bearer = "${var.rustack_root_token}"
#     login = "${var.prefix}-${random_string.learn.result}"
#   }

#   depends_on = [
#       null_resource.user_provisioner
#   ]
# }

provider "restapi" {
  # Default provider for rest API to avoid error on destroy WRT uri argument
  # https://github.com/hashicorp/terraform/issues/21330
  uri                  = "dummy"
}

provider "restapi" {
  alias                = "restapi_headers"
  uri                  = "${var.rustack_api_endpoint}/v1"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.rustack_root_token}"
  }
}

provider "restapi" {
  alias = "restapi_patch"
  uri                  = "${var.rustack_api_endpoint}/v1"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.rustack_root_token}"
  }
  
  create_method  = "PATCH"
  update_method  = "PATCH"
  destroy_method = "PATCH"
}

resource "restapi_object" "user" {
  depends_on = [
      resource.rustack_project.project
  ]
  provider = restapi.restapi_headers
  path = "/account"
  data = <<-EOT
  {
      "username":"${var.prefix}-${random_string.learn.result}",
      "login":"${var.prefix}-${random_string.learn.result}",
      "domain": "${var.rustack_domain}",
      "email": "junk@nsalab.org",
      "phone": "",
      "is_activated":true,
      "is_banned":false,
      "roles":[],
      "entities": [
              {
                  "id": "${var.rustack_entity}",
                  "type": "client",
                  "role": "client_user"
              }
      ]
  }
  EOT
}

resource "restapi_object" "password" {
  depends_on = [
      resource.restapi_object.user
  ]
  provider = restapi.restapi_patch
  path = "/account/${restapi_object.user.api_data.id}/reset_password"
  data = ""
}
/*



locals {
  user = jsondecode(base64decode(data.external.user.result["base64_encoded"]))
}

data "external" "member" {
  program = ["/bin/bash", "user_member_provider.sh"]

  query = {
    endpoint = "${var.rustack_api_endpoint}"
    bearer = "${var.rustack_root_token}"
    user_id = data.external.user.id
  }

  depends_on = [
      data.external.user
  ]
}


output "user" {
  #value = data.external.user.result.id
  # дата провайдеры, которых мы заслужили
  value = jsondecode(base64decode(data.external.user.result["base64_encoded"]))
}
*/
