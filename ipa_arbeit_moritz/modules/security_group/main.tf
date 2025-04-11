resource "aws_security_group" "sgp" {
  description = "Security Group fuer die ${var.clientSlug}-ec2-dmc-01-tf Instanz"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.clientSlug}-sgp-dmc-tf"
  }
}

resource "aws_security_group_rule" "allow_inbound_ssh" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_rdp" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_dns" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_on_prem_subnet" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["${var.on_prem_subnet}"]
}

resource "aws_security_group_rule" "allow_inbound_icmp" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_ldap" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 389
  to_port           = 389
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_ldaps" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 636
  to_port           = 636
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_ldap2" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 3268
  to_port           = 3268
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_inbound_ldaps2" {
  security_group_id = aws_security_group.sgp.id
  type              = "ingress"
  from_port         = 3269
  to_port           = 3269
  protocol          = "tcp"
  cidr_blocks       = ["${var.cus_public_ip}/32"]
}

resource "aws_security_group_rule" "allow_outbound_all" {
  security_group_id = aws_security_group.sgp.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}