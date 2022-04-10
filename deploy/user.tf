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


resource "restapi_object" "user" {
  # depends_on = [
  #     resource.rustack_project.project
  # ]
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
  destroy_method = "PATCH"
  destroy_path = "/account/{id}/unregister"
}

resource "restapi_object" "userproject" {
  depends_on = [
      resource.restapi_object.user
  ]
  provider = restapi.restapi_headers
  create_method = "PUT"
  destroy_method = "DELETE"
  read_method = "GET"
  path = "/client/${element(jsondecode(restapi_object.user.api_response).entities,0).entity.id}/team/${element(jsondecode(restapi_object.user.api_response).entities,0).member_id}"
  read_path = "/client/${element(jsondecode(restapi_object.user.api_response).entities,0).entity.id}/team/${element(jsondecode(restapi_object.user.api_response).entities,0).member_id}"
  create_path = "/client/${element(jsondecode(restapi_object.user.api_response).entities,0).entity.id}/team/${element(jsondecode(restapi_object.user.api_response).entities,0).member_id}"
  destroy_path = "/client/${element(jsondecode(restapi_object.user.api_response).entities,0).entity.id}/team/${element(jsondecode(restapi_object.user.api_response).entities,0).member_id}"
  data = <<-EOT
  {
    "user": "${restapi_object.user.api_data.id}",
    "role": "client_user",
    "acl_list": [
      {
        "id": "${resource.rustack_project.project.id}",
        "type": "project"
      }
    ]
  }
  EOT
}

data "external" "password" {
  depends_on = [
      resource.restapi_object.user
  ]
  program = ["/bin/bash", "${path.module}/user_reset_password.sh"]
  query = {
    endpoint = var.rustack_api_endpoint
    user_id = restapi_object.user.api_data.id
    bearer = var.rustack_root_token
  }
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
