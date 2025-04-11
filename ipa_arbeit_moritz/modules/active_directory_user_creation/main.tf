# OU Creation
resource "ad_ou" "rootOU" {
  name = var.clientName
  path = "DC=${var.clientName},DC=local"
}

resource "ad_ou" "groupsOU" {
  name = "Gruppen"
  path = ad_ou.rootOU.distinguished_name
}

resource "ad_ou" "usersOU" {
  name = "Benutzer"
  path = ad_ou.rootOU.distinguished_name
}

resource "ad_ou" "clientsOU" {
  name = "Clients"
  path = ad_ou.rootOU.distinguished_name
}

resource "ad_ou" "workstationOU" {
  name = "Workstations"
  path = ad_ou.clientsOU.distinguished_name
}

resource "ad_ou" "printerOU" {
  name = "Drucker"
  path = ad_ou.clientsOU.distinguished_name
}

# Active Directory User Creation
resource "ad_user" "user" {
  principal_name         = "${var.benutzername}@${var.clientName}.local"
  sam_account_name       = var.benutzername
  display_name           = "${var.vorname} ${var.nachname}"
  container              = ad_ou.users_ou.distinguished_name
  password_never_expires = false
  pwd_last_set           = 0
}

# Active Directory Group Creation
resource "ad_group" "group" {
  name             = "GRP_${var.gruppe}"
  sam_account_name = "GRP_${var.gruppe}"
  category         = "security"
  container        = ad_ou.rootOU.groupsOU.distinguished_name
}

resource "ad_group_membership" "user_memberships" {
  group_id      = ad_group.group["GRP_${each.value.gruppe}"].distinguished_name
  group_members = [ad_user.user.distinguished_name]
}