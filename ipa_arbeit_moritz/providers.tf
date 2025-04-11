provider "aws" {
  region = "eu-central-2"
}

provider "ad" {
  winrm_hostname = "172.20.2.25"
  winrm_username = "Administrator"
  winrm_password = ""
}
