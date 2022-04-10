
resource "rustack_vm" "ubuntu16" {
    vdc_id = resource.rustack_vdc.vdc.id

    name = "EVE-NG"
    cpu = 2
    ram = 4

    template_id = data.rustack_template.ubuntu16.id

    user_data = templatefile("${path.module}/user_data.tpl", { 
        admin_pass  = data.external.password.result.password, 
        s3_access_key   = var.s3_access_key,
        s3_secret_key   = var.s3_secret_key, 
        s3_bucket_images= var.s3_bucket_images,
        s3_bucket_labs  = var.s3_bucket_labs,
        s3_endpoint     = var.s3_endpoint 
        }
    )
    #user_data = file("./user_data.yaml")

    system_disk {
        size = 10
        storage_profile_id = data.rustack_storage_profile.ssd.id
    }

    port {
        network_id = data.rustack_network.service_network.id
        firewall_templates = [
            data.rustack_firewall_template.allow_default.id,
            data.rustack_firewall_template.allow_all_ingress.id,
        ]
    }

    floating = true
    depends_on = [
        resource.rustack_router.default_router,
    ]
}


