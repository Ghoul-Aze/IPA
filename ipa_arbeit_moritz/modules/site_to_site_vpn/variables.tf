variable "vpc_id" {
  description = "VPC ID to attach the VPN"
  type        = string
}

variable "vpn_bgp_asn" {
  description = "BGP ASN for Customer Gateway"
  type        = number
  default     = 65000
}

variable "on_prem_subnet" {
  type = string
}

variable "rtb_pvt" {
  type = string
}

variable "clientSlug" {
  type = string
}

variable "cus_public_ip" {
  type = string
}