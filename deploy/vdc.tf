resource "rustack_vdc" "vdc" {
    name = "VDC-${random_string.learn.result}"
    project_id = resource.rustack_project.project.id
    hypervisor_id = data.rustack_hypervisor.kvm.id
}