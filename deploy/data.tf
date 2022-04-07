data "rustack_hypervisor" "kvm" {
    project_id = resource.rustack_project.project.id
    name = "KVM"
}

data "rustack_network" "service_network" {
    vdc_id = resource.rustack_vdc.vdc.id
    name = "Сеть"
}

data "rustack_storage_profile" "ssd" {
    vdc_id = resource.rustack_vdc.vdc.id
    name = "ssd"
}

data "rustack_firewall_template" "allow_default" {
    vdc_id = resource.rustack_vdc.vdc.id
    name = "По-умолчанию"
}

data "rustack_firewall_template" "allow_all_ingress" {
    vdc_id = resource.rustack_vdc.vdc.id
    name = "Разрешить входящий трафик"
}

data "rustack_template" "ubuntu16" {
    vdc_id = resource.rustack_vdc.vdc.id
    name = "Ubuntu 16.04"
}

/*
data "rustack_template" "debian10" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Debian 10"
}

data "rustack_template" "ubuntu18" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Ubuntu 18.04"
}

data "rustack_template" "ubuntu20" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Ubuntu 20.04"
}

data "rustack_template" "win2019" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Windows Server 2019 Standard"
}

data "rustack_template" "centos8" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Centos 8"
}



data "rustack_firewall_template" "allow_web" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Разрешить WEB"
}

data "rustack_firewall_template" "allow_ssh" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Разрешить SSH"
}


*/