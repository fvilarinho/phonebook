# Credentials filename.
variable "credentialsFilename" {
  type = string
  default = ".credentials"
}

# Settings filename.
variable "settingsFilename" {
  type = string
  default = "settings.json"
}

# SSH private key filename.
variable "privateKeyFilename" {
  type = string
  default = ".id_rsa"
}

# TLS certificate key filename.
variable "certificateKeyFilename" {
  type = string
  default = "etc/cert.key"
}

# TLS certificate filename.
variable "certificateFilename" {
  type = string
  default = "etc/cert.pem"
}