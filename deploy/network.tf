resource "rustack_router" "default_router" {
  vdc_id =  resource.rustack_vdc.vdc.id
  name = "Роутер"
  networks = [
    data.rustack_network.service_network.id
  ]
  system = true
}