variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "pvt_sbn_id" {
  type = string
}

variable "clientSlug" {
  type    = string
  default = "IPA"
}

variable "sgp_id" {
  type = string
}

variable "clientName" {
  type    = string
  default = "IPA"
}

variable "ec2_pvt_ip" {
  type    = string
  default = "172.20.2.25"
}

variable "pvt_ip_subnet" {
  type = string
}
