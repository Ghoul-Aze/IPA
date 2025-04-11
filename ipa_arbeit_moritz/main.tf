terraform {
  backend "s3" {
    bucket = "gitlab-terraform-state-dev1"
    key    = "aws-ipa-deployment-state"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ad = {
      source  = "hashicorp/ad"
      version = "0.5.0"
    }
  }
}

locals {
  clients            = csvdecode(file("KundenKonfig.csv"))
  users_ad           = csvdecode(file("Benutzerliste.csv"))
  clients_with_users = { for client in local.clients : client.cus_name => merge(client, try(local.users_ad[client.cus_name], {})) }
  output_vpc_id      = { for clientName, vpc in module.vpc : clientName => vpc.vpc_id }
  output_pvt_sbn_id  = { for clientName, vpc in module.vpc : clientName => vpc.pvt_sbn_id }
  output_pub_sbn_id  = { for clientName, vpc in module.vpc : clientName => vpc.pub_sbn_id }
  output_rtb_pvt     = { for clientName, vpc in module.vpc : clientName => vpc.rtb_pvt }
  output_sgp_id      = { for clientName, security_group in module.security_group : clientName => security_group.sgp_id }
}
# Call for modules
module "vpc" {
  source   = "./modules/vpc"
  for_each = { for client in local.clients : client.cus_name => client }

  # Passed variables
  clientName         = each.value.cus_name
  clientSlug         = each.value.kundenkuerzel
  vpc_cidr_ip_subnet = each.value.vpc_cidr_ip_subnet
  pvt_ip_subnet      = each.value.pvt_ip_subnet
  pub_ip_subnet      = each.value.pub_ip_subnet
  on_prem_subnet     = each.value.on_prem_subnet
}

module "security_group" {
  source     = "./modules/security_group"
  depends_on = [module.vpc]
  for_each   = { for client in local.clients : client.cus_name => client }

  # Passed variables
  cus_public_ip  = each.value.cus_public_ip
  clientSlug     = each.value.kundenkuerzel
  on_prem_subnet = each.value.on_prem_subnet
  vpc_id         = local.output_vpc_id[each.key]
}

module "ec2" {
  source     = "./modules/ec2"
  depends_on = [module.vpc]
  for_each   = { for client in local.clients : client.cus_name => client }

  # Passed variables
  instance_type = each.value.instance_type
  clientSlug    = each.value.kundenkuerzel
  clientName    = each.value.cus_name
  ec2_pvt_ip    = each.value.ec2_instance_pvt_ip
  pvt_ip_subnet = each.value.pvt_ip_subnet
  vpc_id        = local.output_vpc_id[each.key]
  pvt_sbn_id    = local.output_pvt_sbn_id[each.key]
  sgp_id        = local.output_sgp_id[each.key]
}

module "site_to_site_vpn" {
  source     = "./modules/site_to_site_vpn"
  depends_on = [module.vpc]
  for_each   = { for client in local.clients : client.cus_name => client }

  # Passed variables
  on_prem_subnet = each.value.on_prem_subnet
  clientSlug     = each.value.kundenkuerzel
  cus_public_ip  = each.value.cus_public_ip
  vpc_id         = local.output_vpc_id[each.key]
  rtb_pvt        = local.output_rtb_pvt[each.key]
}

module "lifecycle" {
  source     = "./modules/lifecycle"
  depends_on = [module.vpc, module.ec2]
  for_each   = { for client in local.clients : client.cus_name => client }

  # Passed variables
  clientName = each.value.cus_name
  clientSlug = each.value.kundenkuerzel
}

/*
module "ad" {
  source     = "./modules/active_directory_user_creation"
  depends_on = [module.vpc, module.ec2]
  for_each   = local.clients_with_users

  # Passed variables
  benutzername                       = try(each.value.benutzername, null)
  vorname                            = try(each.value.vorname, null)
  nachname                           = try(each.value.nachname, null)
  cusNameBenutzer                    = try(each.value.cus_name_benutzer, null)
  gruppe                             = try(each.value.gruppe, null)
  clientName                         = each.value.cus_name
  clientSlug                         = each.value.kundenkuerzel
  ec2_pvt_ip                         = each.value.ec2_instance_pvt_ip
  must_change_password_at_next_logon = false
  enabled                            = true
}
*/