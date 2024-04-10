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
variable "sshPrivateKeyFilename" {
  type = string
  default = "~/.ssh/id_rsa"
}

# SSH public key filename.
variable "sshPublicKeyFilename" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

# TLS certificate key filename.
variable "certificateKeyFilename" {
  type = string
  default = "../etc/cert.key"
}

# TLS certificate filename.
variable "certificateFilename" {
  type = string
  default = "../etc/cert.pem"
}