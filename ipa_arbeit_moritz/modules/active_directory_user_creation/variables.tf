variable "benutzername" {
  type = string
}

variable "vorname" {
  type = string
}

variable "nachname" {
  type = string
}

variable "cusNameBenutzer" {
  type = string
}

variable "ec2_pvt_ip" {
  type    = string
  default = "172.20.2.25"
}

variable "clientName" {
  type    = string
  default = "IPA"
}

variable "clientSlug" {
  type    = string
  default = "IPA"
}

variable "gruppe" {
  type = string
}