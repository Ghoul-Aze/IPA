resource "aws_instance" "default_ec2" {
  ami                    = "ami-028b6050b1ac14536"
  instance_type          = var.instance_type
  subnet_id              = var.pvt_sbn_id
  vpc_security_group_ids = [var.sgp_id]
  key_name               = "IPA_Moritz"
  user_data = templatefile("modules/ec2/Cloudinit/InitScript.txt", {
    DomainName        = "${var.clientSlug}.local"
    DomainNetBIOSName = var.clientSlug
    pvt_ip_subnet     = var.pvt_ip_subnet
  })
  get_password_data = true
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = {
      Name     = "${var.clientSlug}-ec2-dmc-01-root"
      Snapshot = "true"
    }
  }

  ebs_block_device {
    volume_size = 50
    volume_type = "gp3"
    device_name = "/dev/sdf"
    tags = {
      Name     = "${var.clientSlug}-ec2-dmc-01-ebs"
      Snapshot = "true"
    }
  }
  private_ip = var.ec2_pvt_ip
  tags = {
    Name = "${var.clientSlug}-ec2-dmc-01-tf"
  }
}
