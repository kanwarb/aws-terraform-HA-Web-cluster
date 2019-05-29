variable "name" { default = "dynamic-aws-creds-consumer" }
variable "path" { default = "s3://kb-terraform-state/producer/s3/terraform.tfstate" }
variable "ttl"  { default = "1" }
variable "server_port" { default ="8080" }
variable "vault_http_address" { default = "http://127.0.0.1:8200" }

variable "app_consumer_tfstate" { default = "s3://kb-terraform-state/consumer/s3/app/terraform.tfstate" }
variable "db_consumer_tfstate" { default = "s3://kb-terraform-state/consumer/s3/db/terraform.tfstate" }
