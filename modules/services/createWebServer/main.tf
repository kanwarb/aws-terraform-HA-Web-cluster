provider "vault" {
  address = "${var.vault_http_address}"
  skip_tls_verify = "true"
}

data "vault_generic_secret" "aws_iam_keys" {
   path = "aws/creds/my-role"
}

data "external" "region" {
	program = ["delay-vault-aws"]
}


data "terraform_remote_state" "producer" {
  backend = "s3"
   config {
    bucket = "kb-terraform-state"
    region = "us-east-1"
    key = "producer/s3/terraform.tfstate"
    encrypt = "true"
   }
}

data "vault_aws_access_credentials" "creds" {
  backend = "${data.terraform_remote_state.producer.backend}"
  role    = "${data.terraform_remote_state.producer.role}"
}

provider "aws" {
  region ="${data.external.region.result["region"]}"
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "all" {}


data "template_file" "user_data" {
   template = "${file("/root/devops/modules/services/createWebServer/user-data.sh")}"

   vars {
	server_port = "${var.server_port}"
	db_address  = "127.0.0.1" 
	db_port     = "3006"
   }
}

# Deploy cluster of Web Servers

resource "aws_launch_configuration" "webservers" {
   image_id  	 = "${data.aws_ami.ubuntu.id}"
   instance_type = "t2.micro"
   security_groups = ["${aws_security_group.webaccess.id}"]



	lifecycle {
	   create_before_destroy = true
	}
}

resource "aws_security_group" "webaccess" {
   name= "terraform-webserver-instance"

   ingress {
	from_port  = "${var.server_port}"
	to_port    = "${var.server_port}"
	protocol   = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
	create_before_destroy = true
    }

}

resource "aws_autoscaling_group" "webserver-asg" {

	launch_configuration 	= "${aws_launch_configuration.webservers.id}"
	availability_zones 	= ["${data.aws_availability_zones.all.names}"]

	load_balancers		= ["${aws_elb.webserver-elb.name}"]
	health_check_type	= "ELB"

  	min_size =2
	max_size =4
	
	tags {
		key = "Name"
		value= "terraform-asg-webservers"
		propagate_at_launch = true
	}
}

resource "aws_elb" "webserver-elb" {
   name		= "terraform-asg-webservers"
   availability_zones = ["${data.aws_availability_zones.all.names}"]
   security_groups    = ["${aws_security_group.elbsg.id}"] 
   listener {
	lb_port		= 80
	lb_protocol	= "http"
	instance_port	= "${var.server_port}"
	instance_protocol = "http"
   }
   health_check {
	healthy_threshold 	= 2
	unhealthy_threshold 	= 2
	timeout 		= 3
	interval		= 30
	target			="HTTP:${var.server_port}/"
   }
}

resource "aws_security_group" "elbsg" {
    name  = "terraform-elbsg"

    ingress {
	from_port	= 80
	to_port		= 80
	protocol	="tcp"
	cidr_blocks	=["0.0.0.0/0"]
    }
    egress {
	from_port	= 0
	to_port		= 0
	protocol	= "-1"
	cidr_blocks	=["0.0.0.0/0"]	
	
    }
}

