resource "rustack_project" "project" {
    name =  "${var.lab_instance}-${random_string.learn.result}"
}