# Create lifecycle role for dlm snapshot
resource "aws_iam_role" "snapshot_lifecycle_role" {
  name = "${var.clientSlug}_snapshot_lifecycle_role-tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create lifecycle policy permission for dlm snapshot role
resource "aws_iam_policy" "snapshot_lifecycle_policy" {
  name        = "${var.clientSlug}_Snapshot_Lifecycle_Policy-tf"
  description = "Erlaubt EC2 und DLM das verwalten von snapshots und volumes - verwaltet von Terraform"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeVolumes",
        "ec2:ModifyVolume",
        "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:CreateTags"],
      "Resource": "arn:aws:ec2:*::snapshot/*"
    }
  ]
}
EOF
}

# Attach dlm snapshot policy to role
resource "aws_iam_role_policy_attachment" "snapshot_lifecycle_attach" {
  policy_arn = aws_iam_policy.snapshot_lifecycle_policy.arn
  role       = aws_iam_role.snapshot_lifecycle_role.name
}

resource "aws_iam_instance_profile" "snapshot_instance_profile" {
  name = "${var.clientSlug}_SnapshotInstanceProfile"
  role = aws_iam_role.snapshot_lifecycle_role.name
}

# Configure DLM snapshot policy
resource "aws_dlm_lifecycle_policy" "snapshot_policy" {
  description        = "DLM lifecycle Policy verwaltet von Terraform"
  execution_role_arn = aws_iam_role.snapshot_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "${var.clientName} Backup Daily Schedule"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["01:00"]
      }

      retain_rule {
        count = 30
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}
