resource "rustack_project" "project" {
    name =  "${var.lab_instance}-${var.prefix}-${random_string.learn.result}"
}