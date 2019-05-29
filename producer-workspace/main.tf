variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "name"           { default = "dynamic-aws-creds-producer" }

terraform {
  backend "s3" {
    bucket = "${var.my-state}"
    region = "us-east-1"
    key = "${producer_file_location_on_s3}"
    encrypt = "true"
#    path = "terraform.tfstate"
  }
}

provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  path       = "${var.name}-bucket"

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds     = "240"
}

resource "vault_aws_secret_backend_role" "producer" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "${var.name}-role"
  credential_type = "iam_user"
  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "backend" {
  value = "${vault_aws_secret_backend.aws.path}"
}

output "role" {
  value = "${vault_aws_secret_backend_role.producer.name}"
}

