resource "random_password" "phonebook_database" {
  length  = 16
  special = false
}

resource "random_password" "phonebook_cluster" {
  length = 16
}