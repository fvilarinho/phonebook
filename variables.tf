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

variable "privateKeyFilename" {
  type = string
  default = ".id_rsa"
}

variable "certificateKeyFilename" {
  type = string
  default = "etc/cert.key"
}

variable "certificateFilename" {
  type = string
  default = "etc/cert.pem"
}